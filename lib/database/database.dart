// ignore_for_file: implementation_imports

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:offline_first/base_model.dart';
import 'package:offline_first/utils/path_utils.dart';
import 'package:offline_first/utils/extensions.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/src/api/log_level.dart';
import 'package:sembast/src/finder_impl.dart';
import 'package:sembast_sqflite/sembast_sqflite.dart';
import 'package:sembast_web/sembast_web.dart' as w;
import 'package:sqflite/sqflite.dart' as sqflite;

typedef ValueResolver<T> = T Function(Map<String, dynamic>);

/// Holds all the write operations temporally, until [OfflineDatabase.commit] is executed.
Set<Future<void> Function(Transaction)> _operations = {};

/// Database metadata
const String dbName = 'cache.rxpin';
const int dbVersion = 1;

class OfflineDatabase {
  late Database _database;
  late DatabaseFactory _dbFactory;
  late String _dbPath;


  Future<void> init([String databaseName = dbName]) async {
    setLogging(enabled: true); // TODO:: Make use of FlavorConfig.instance.showDatabaseLog
    _dbFactory = kIsWeb ? w.databaseFactoryWeb : getDatabaseFactorySqflite(sqflite.databaseFactory);

    await _moveDatabaseFromOldToNewDir(databaseName);

    _dbPath = kIsWeb ? databaseName : join(await PathUtil().getDatabaseStorageDirPath(), databaseName);
    _database = await _openDatabase();
    print('Init successful');
  }

  void setLogging({required bool enabled}) {
    sembastLogLevel = enabled ? SembastLogLevel.verbose : SembastLogLevel.none;
  }

  Future<void> _moveDatabaseFromOldToNewDir(String databaseName) async {
    if (!kIsWeb) {
      final path = PathUtil();
      final oldDbPath = join(await path.getDocumentDirPath(), databaseName);
      final newDbPath = join(await path.getDatabaseStorageDirPath(), databaseName);

      final oldDbFile = File(oldDbPath);
      if (oldDbPath != newDbPath && await oldDbFile.exists()) {
        await oldDbFile.copy(newDbPath);
        await oldDbFile.delete();
      }
    }
  }

  Future<Database> _openDatabase() async {
    return _dbFactory.openDatabase(
      _dbPath,
      version: dbVersion,
      onVersionChanged: (Database db, int oldVersion, int newVersion) {
        // Write Migration Code Here
      },
    );
  }

  Future<void> resetDatabase() async {
    await _database.close();
    await _dbFactory.deleteDatabase(_dbPath);
    await init();
  }

  /// Opens a Sembast store.
  ///
  /// The name for store is either taken from the type assigned or [storeNameSuffix].
  ///
  /// e.g.
  /// openStore<HelpModel>() --->  HelpModel (Store Name)
  /// openStore('Test') --->  Test (Store Name)
  /// openStore<HelpModel>('Test') --->  HelpModelTest (Store Name)
  /// openStore() --->  throws failure
  Store<T> openStore<T extends BaseModel>([String storeNameSuffix = '']) => Store<T>(_database, storeNameSuffix);

  /// Clear all documents from all store

  /// Runs all the operation stored in [_operations] as an atomic transaction.
  Future<void> commitTransaction() async {
    await _database.transaction((transaction) async {
      for (final operation in _operations) {
        await operation(transaction);
      }
    });
    _operations.clear();
  }
}

class Store<T extends BaseModel> {
  late StoreRef<String, Map<String, dynamic>> _storeRef;
  final Database _db;
  bool _isTypeSafeStore = false;

  Store(this._db, String storeNameSuffix) {
    String storeName;
    if (T.toString() != 'BaseModel') {
      _isTypeSafeStore = true;
      storeName = '${T.toString()}$storeNameSuffix';
    } else if (storeNameSuffix.isNotEmpty) {
      storeName = storeNameSuffix;
    } else {
      print('Either give a type or a suffix, while opening store.');
      storeName = '';
      // throw Failure.dao('Either give a type or a suffix, while opening store.');
    }
    _storeRef = stringMapStoreFactory.store(storeName);
  }

  /// Insert or update a model with value from field marked as @primaryKey as key.
  ///
  /// If a model exists with the same primaryKey, it will be replaced with the passed model
  ///
  /// If no field is marked as @primaryKey, models will be added without any key.
  ///
  /// if [merge] is true and the field exists, data is merged
  ///
  /// Multiple insert operations should always be scoped inside a global transaction
  /// by enabling [runInTransaction], in order to improve performance drastically (~ 20 times).
  Future<void> insert(List<T> models, {bool clear = false, bool merge = true, bool runInTransaction = false}) async {
    assert(_isTypeSafeStore, 'Use `put`. Consider passing type if you still want to use insert.');

    if (runInTransaction) {
      // runs in globally created transaction
      _operations.add((t) => _insert(models, clear: clear, transaction: t, merge: merge));
    } else {
      await _db.transaction((t) async {
        // runs in newly created transaction
        await _insert(models, clear: clear, transaction: t, merge: merge);
      });
    }
  }

  // Performs insert operation.
  Future<void> _insert(List<T> models, {bool clear = false, bool merge = false, required Transaction transaction}) async {
    if (clear) await _storeRef.delete(transaction);

    for (final model in models) {
      if (model.primaryKey.isNotNull) {
        await _storeRef.record(model.primaryKey!).put(transaction, model.toJson(), merge: merge);
      } else {
        await _storeRef.add(transaction, model.toJson());
      }
    }
  }

  /// Retrieves records from the [Store].
  ///
  /// Either use [primaryKey] or [finder] to filter records.
  Future<List<T>> fetch({
    required ValueResolver<T> resolve,
    String? primaryKey,
    Finder? finder,
  }) async {
    assert(
      primaryKey.isNull || finder.isNull,
      "Both 'primaryKey' and 'finder' can't be used at the same time.",
    );
    assert(_isTypeSafeStore, 'Use `get`. Consider passing type if you still want to use fetch.');

    if (primaryKey.isNotNull) {
      final record = await _storeRef.record(primaryKey!).get(_db);
      return [if (record.isNotNull) resolve(record!)];
    }
    final records = await _storeRef.find(_db, finder: finder);
    return records.map((record) => resolve(record.value)).toList();
  }

  /// Retrieves and groups data by [groupBy]
  ///
  /// This will return an empty map if [groupBy] does not exist in the model
  ///
  /// Given the following list:
  /// ```
  /// [
  ///   Animal(name: Cat, group: Feline),
  ///   Animal(name: Tiger, group: Feline),
  ///   Animal(name: Dog, group: Canine),
  ///   Animal(name: Wolf, group: Canine),
  /// ]
  /// ```
  ///
  /// This would be grouped by (Animal.group) as follows:
  ///
  /// ```
  /// {
  ///   Feline : [
  ///               Animal(name: Cat, group: Feline),
  ///               Animal(name: Tiger, group: Feline),
  ///            ],
  ///   Canine : [
  ///               Animal(name: Dog, group: Canine),
  ///               Animal(name: Wolf, group: Canine),
  ///            ],
  /// }
  /// ```
  Future<Map<String, List<T>>> fetchAndGroup({
    required ValueResolver<T> resolve,
    required String groupBy,
    Finder? finder,
  }) async {
    final result = <String, List<T>>{};
    final records = await _storeRef.find(_db, finder: finder);
    for (final record in records) {
      final rawModel = record.value;
      final String? groupByKey = rawModel[groupBy]?.toString();
      if (groupByKey != null) {
        final rawModels = result[groupByKey] ?? <T>[];
        result[groupByKey] = [...rawModels, resolve(rawModel)];
      }
    }

    return result;
  }

  /// Retrieves first record from the [Store].
  ///
  /// Either use [primaryKey] or [finder] to filter records.
  Future<T?> fetchFirst({
    required ValueResolver<T> resolve,
    String? primaryKey,
    Finder? finder,
  }) async {
    assert(
      primaryKey.isNull || finder.isNull,
      "Both 'primaryKey' and 'finder' can't be used at the same time.",
    );
    assert(_isTypeSafeStore, 'Use `get`. Consider passing type if you still want to use fetch.');

    if (primaryKey.isNotNull) {
      final record = await _storeRef.record(primaryKey!).get(_db);
      if (record.isNull) return null;
      return resolve(record!);
    }
    final record = await _storeRef.findFirst(_db, finder: finder);
    if (record.isNotNull) resolve(record!.value);

    return null;
  }

  Future delete({String? primaryKey, Finder? finder}) async {
    assert(
      primaryKey.isNull || finder.isNull,
      "Both 'primaryKey' and 'finder' can't be used at the same time.",
    );

    if (primaryKey.isNotNull) {
      return _storeRef.record(primaryKey!).delete(_db);
    }
    await _storeRef.delete(_db, finder: finder);
  }

  Future<void> put(Map<String, dynamic> data) async {
    assert(!_isTypeSafeStore, 'Use `insert`.  Consider removing type if you still want to use put.');

    await _storeRef.delete(_db);
    await _storeRef.add(_db, data);
  }

  Future<Map<String, dynamic>> get() async {
    assert(!_isTypeSafeStore, 'Use `fetch`.  Consider removing type if you still want to use get.');

    final record = await _storeRef.findFirst(_db);
    // if (record.isNullOrEmpty) throw Failure.dao('No data found in ${_storeRef.name}');
    return record!.value;
  }

  String get name => _storeRef.name;
}

extension FinderExtension on SembastFinder {
  SembastFinder copyWith({
    Filter? filter,
    List<SortOrder>? sortOrders,
    int? limit,
    int? offset,
    Boundary? start,
    Boundary? end,
  }) {
    return SembastFinder(
      filter: filter ?? this.filter,
      sortOrders: sortOrders ?? this.sortOrders,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }
}
