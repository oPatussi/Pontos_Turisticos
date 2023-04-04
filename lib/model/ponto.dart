import 'package:intl/intl.dart';

class Ponto{

  static const CAMPO_ID = 'id';
  static const CAMPO_NOME = 'nome';
  static const CAMPO_DESCRICAO = 'descricao';
  static const CAMPO_DATA_CADASTRO = 'dataCadastro';
  static const CAMPO_DIFERENCIAIS = 'diferenciais';

  int id;
  String nome;
  String descricao;
  DateTime? dataCadastro;
  String diferenciais;

  Ponto({required this.id,required this.nome, required this.descricao, this.dataCadastro, required this.diferenciais});

  String get dataFormatada{
    if(dataCadastro == null){
      return'';
    }else{
      return DateFormat('dd/MM/yyyy').format(dataCadastro!);
    }
  }
}