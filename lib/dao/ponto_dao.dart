import 'package:atividade1/database/database_provider.dart';
import 'package:atividade1/model/ponto.dart';
import 'package:sqflite/sqflite.dart';

class PontoDao{

  final dbProvider = DatabaseProvider.instance;

  Future<bool> salvar(Ponto ponto) async{
    final db = await dbProvider.database;
    final valores = ponto.toMap();
    if(ponto.id == 0){
      ponto.id = await db.insert(Ponto.NAME_TABLE, valores);
      return true;
    }else{
      final registrosAtualizados = await db.update(
          Ponto.NAME_TABLE,
          valores,
          where: '${Ponto.CAMPO_ID} = ?',
          whereArgs: [ponto.id]);
      return registrosAtualizados > 0;
    }
  }

  Future<bool> remover (int id) async{
    final db = await dbProvider.database;
    final registrosAtualizados = await db.delete(
        Ponto.NAME_TABLE,
        where: '${Ponto.CAMPO_ID} = ?',
        whereArgs:[id]);
    return registrosAtualizados >0;
  }

  Future<List<Ponto>> listar({
    String filtro = '',
    String campoOrdenacao = Ponto.CAMPO_ID,
    bool usarOrdemDecrescente = false
  }) async{
    String? where;
    if (filtro.isNotEmpty){
      where = "UPPER(${Ponto.CAMPO_NOME}) LIKE '${filtro.toUpperCase()}%'";
    }
    var orderBy = campoOrdenacao;
    if(usarOrdemDecrescente){
      orderBy += ' DESC';
    }

    final db = await dbProvider.database;
    final resultado = await db.query(Ponto.NAME_TABLE,
        columns: [
          Ponto.CAMPO_ID,
          Ponto.CAMPO_NOME,
          Ponto.CAMPO_DETALHES,
          Ponto.CAMPO_DIFERENCIAIS,
          Ponto.CAMPO_DATA_CADASTRO,
          Ponto.CAMPO_LATITUDE,
          Ponto.CAMPO_LONGITUDE
        ],
        where: where,
        orderBy: orderBy);
    return resultado.map((m) => Ponto.fromMap(m)).toList();
  }

}