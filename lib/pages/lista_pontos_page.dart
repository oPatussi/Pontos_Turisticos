import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:atividade1/model/ponto.dart';
import 'package:atividade1/pages/filtro_page.dart';
import '../widgets/conteudo_form_dialog.dart';

class ListaPontosPage extends StatefulWidget{

  @override
  _ListaPontosPageState createState() => _ListaPontosPageState();

}
class _ListaPontosPageState extends State<ListaPontosPage>{

  static const ACAO_EDITAR = 'editar';
  static const ACAO_EXCLUIR = 'excluir';
  static const ACAO_VISUALIZAR = 'visualizar';

  final pontos = <Ponto>
  [
    Ponto(
      id: 1,
      nome: "Nome do ponto",
      descricao: "Descrição do ponto",
      diferenciais: 'Diferenciais do ponto',
      dataCadastro: DateTime.now(),
      ),
  ];

  var _ultimoId = 1;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: _criarAppBar(),
      body: _criarBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirForm,
        tooltip: 'Novo ponto turístico',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _abrirForm({Ponto? pontoAtual, int? index}){
    final key = GlobalKey<ConteudoFormDialogState>();
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text(pontoAtual == null ? 'Novo Ponto' : 'Ponto selecionado: ${pontoAtual.id}'),
            content: ConteudoFormDialog(key: key, pontoAtual: pontoAtual),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  if (key.currentState != null && key.currentState!.dadosValidados()){
                    setState(() {
                      final novoPonto = key.currentState!.novoPonto;
                      if(index == null){
                        novoPonto.id = ++_ultimoId;
                      }else{
                        pontos[index] = novoPonto;
                      }
                      pontos.add(novoPonto);
                    });
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Salvar'),
              ),
            ],
          );
        }
    );
  }
  AppBar _criarAppBar(){
    return AppBar(
      title: const Text('Lista de Pontos Turisticos'),
      actions: [
        IconButton(
            onPressed: _abrirPaginaFiltro,
            icon: const Icon(Icons.filter_list)),
      ],
    );
  }
  Widget _criarBody(){
    if(pontos.isEmpty){
      return const Center(
        child: Text('Nenhum ponto turístico cadastrado',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );
    }
    return ListView.separated(
      itemCount: pontos.length,
      itemBuilder: (BuildContext context, int index){
        final ponto = pontos[index];
        return PopupMenuButton<String>(
            child: ListTile(
              title: Text(ponto.nome),
              subtitle: Text('Inserido em - ${ponto.dataFormatada}'),
            ),
            itemBuilder: (BuildContext context) => _criarItensMenu(),
            onSelected: (String valorSelecinado){
              if(valorSelecinado == ACAO_EDITAR){
                _abrirForm(pontoAtual: ponto, index: index);
              }else if(valorSelecinado == ACAO_VISUALIZAR){
                _abrirForm(pontoAtual: ponto, index: index);
              }else{
                _excluir(index);
              }
            }
        );
      },
      separatorBuilder: (BuildContext context, int index) => Divider(),
    );
  }
  void _excluir(int indice){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.red,),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text('Atenção'),
                )
              ],
            ),
            content: Text('Esse registro será deletado permanentemente'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar')
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      pontos.removeAt(indice);
                    });
                  },
                  child: Text('OK')
              )
            ],
          );
        }
    );

  }
  List<PopupMenuEntry<String>> _criarItensMenu(){
    return[
      PopupMenuItem(
        value: ACAO_VISUALIZAR,
        child: Row(
          children: [
            Icon(Icons.launch, color: Colors.black),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text('Visualizar'),
            )
          ],
        ),
      ),
      PopupMenuItem(
        value: ACAO_EDITAR,
        child: Row(
          children: [
            Icon(Icons.edit, color: Colors.black),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text('Editar'),
            )
          ],
        ),
      ),
      PopupMenuItem(
        value: ACAO_EXCLUIR,
        child: Row(
          children: [
            Icon(Icons.delete, color: Colors.red),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text('Excluir'),
            )
          ],
        ),
      )
    ];
  }

  void _abrirPaginaFiltro(){
    final navigator = Navigator.of(context);
    navigator.pushNamed(FiltroPage.routeName).then((alterouValores) {
      if(alterouValores == true){
        ///filtro
        }
      }
    );

  }

}