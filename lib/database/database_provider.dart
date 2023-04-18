
import 'package:atividade1/model/ponto.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider{
  static const _dbName = 'cadastro_de_pontos_md.db';
  static const _dbVersion = 2;

  DatabaseProvider._init();

  static final DatabaseProvider instance = DatabaseProvider._init();

  Database? _database;

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async{
    String dataBasePath = await getDatabasesPath();
    String dbPath = '${dataBasePath}/$_dbName';
    return await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _onCreate,
      // onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db,int version) async{
    await db.execute(
        '''
    CREATE TABLE ${Ponto.NAME_TABLE}(
      ${Ponto.CAMPO_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${Ponto.CAMPO_NOME} TEXT NOT NULL,
      ${Ponto.CAMPO_DESCRICAO} TEXT NOT NULL,
      ${Ponto.CAMPO_DATA_CADASTRO} TEXT,
      ${Ponto.CAMPO_DIFERENCIAIS} TEXT NOT NULL
    );
    '''
    );
  }

  // Future<void> _onUpgrade(Database db,int oldVersion, int newVersion) async {
  //   switch(oldVersion){
  //     case 1:
  //       await db.execute('''
  //         ALTER TABLE ${Ponto.NAME_TABLE}
  //         ADD ${Tarefa.CAMPO_FINALIZADA} INTEGER NOT NULL DEFAULT 0;
  //       ''');
  //   }
  // }

  Future<void> close() async{
    if (_database != null){
      await _database!.close();
    }
  }

}