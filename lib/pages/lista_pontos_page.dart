import 'package:atividade1/dao/ponto_dao.dart';
import 'package:atividade1/pages/detalhes_ponto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:atividade1/model/ponto.dart';
import 'package:atividade1/pages/filtro_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/conteudo_form_dialog.dart';

class ListaPontosPage extends StatefulWidget{

  @override
  _ListaPontosPageState createState() => _ListaPontosPageState();

}
class _ListaPontosPageState extends State<ListaPontosPage>{

  static const ACAO_EDITAR = 'editar';
  static const ACAO_EXCLUIR = 'excluir';
  static const ACAO_VISUALIZAR = 'visualizar';

  final _pontos = <Ponto>[];
  final _dao = PontoDao();
  var _carregando = false;

  var _ultimoId = 1;

  @override
  void initState(){
    super.initState();
    _atualizarLista();
  }

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
                child: Text('Salvar'),
                onPressed: () {
                  if (key.currentState?.dadosValidados() != true) {
                    return;
                  }
                  Navigator.of(context).pop();
                  final novoPonto = key.currentState!.novoPonto;
                  _dao.salvar(novoPonto).then((success) {
                    if (success) {
                      _atualizarLista();
                    }
                  });
                },
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
    if (_carregando){
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: AlignmentDirectional.center,
            child: CircularProgressIndicator(),
          ),
          Align(
            alignment: AlignmentDirectional.center,
            child: Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text('Carregando',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          )
        ],
      );
    }

    if(_pontos.isEmpty){
      return const Center(
        child: Text('Nenhum ponto turístico cadastrado',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );
    }
    return ListView.separated(
      itemCount: _pontos.length,
      itemBuilder: (BuildContext context, int index){
        final ponto = _pontos[index];
        return PopupMenuButton<String>(
            child: ListTile(
              title: Text(
                '${ponto.nome}',
              ),
              subtitle: Text('${ponto.descricao}',
              ),
            ),
            itemBuilder: (BuildContext context) => _criarItensMenu(),
            onSelected: (String valorSelecinado){
              if(valorSelecinado == ACAO_EDITAR){
                _abrirForm(pontoAtual: ponto);
              }else if(valorSelecinado == ACAO_VISUALIZAR){
                _abrirPaginaDetalhesTarefa(ponto);
              }else{
                _excluir(ponto);
              }
            }
        );
      },
      separatorBuilder: (BuildContext context, int index) => Divider(),
    );
  }
  void _excluir(Ponto ponto){
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
                    if(ponto.id == null){
                      return;
                    }else{
                      _dao.remover(ponto.id).then((success){
                        if(success){
                          _atualizarLista();
                        }
                      });
                    }
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
        _atualizarLista();
        }
      }
    );
  }

  void _abrirPaginaDetalhesTarefa(Ponto ponto) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetalhesPontoPage(
              ponto: ponto,
          )
        ));
  }

  void _atualizarLista() async {
    setState(() {
      _carregando = true;
    });
    // Carregar os valores do SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final campoOrdenacao =
        prefs.getString(FiltroPage.chaveCampoOrdenacao) ?? Ponto.CAMPO_ID;
    final usarOrdemDecrescente =
        prefs.getBool(FiltroPage.chaveUsarOrdemDecrescente) == true;
    final filtroNome =
        prefs.getString(FiltroPage.chaveCampoNome) ?? '';
    final pontos = await _dao.listar(
      filtro: filtroNome,
      campoOrdenacao: campoOrdenacao,
      usarOrdemDecrescente: usarOrdemDecrescente,
    );
    setState(() {
      _carregando = false;
      _pontos.clear();
      if (pontos.isNotEmpty) {
        _pontos.addAll(pontos);
      }
    });
  }

}