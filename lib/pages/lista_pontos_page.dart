import 'dart:ffi';

import 'package:atividade1/dao/ponto_dao.dart';
import 'package:atividade1/pages/detalhes_ponto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:atividade1/model/ponto.dart';
import 'package:atividade1/pages/filtro_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_launcher/maps_launcher.dart';
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
  static const ACAO_ABRIR_MAPA = 'mapa';
  static const ACAO_DISTANCIA = 'distancia';

  bool pegouLocal = true;
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
    obterLocalizacaoAtual();
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
                      _atualizarLocal();
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
              subtitle: Text('${ponto.detalhes}',
              ),
            ),
            itemBuilder: (BuildContext context) => _criarItensMenu(),
            onSelected: (String valorSelecinado){
              if(valorSelecinado == ACAO_EDITAR){
                _abrirForm(pontoAtual: ponto);
              }else if(valorSelecinado == ACAO_VISUALIZAR) {
                _abrirPaginaDetalhesTarefa(ponto);
              }else if(valorSelecinado == ACAO_ABRIR_MAPA) {
                _abrirCoordenadasNoMapaExterno(ponto);
              }else if(valorSelecinado == ACAO_DISTANCIA){
                var dist = _distanciaEntre(ponto).toStringAsFixed(1);
                _mostrarMensagemDialogGeneric("Você está a ${dist} metros de distância do local.", "Distância");
              }else{
                _excluir(ponto);
              }
            }
        );
      },
      separatorBuilder: (BuildContext context, int index) => Divider(),
    );
  }

  void _atualizarLocal() async{
    if (pegouLocal == false){
      pegouLocal = true;
    }else{
      pegouLocal = false;
    }
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
        value: ACAO_ABRIR_MAPA,
        child: Row(
          children: [
            Icon(Icons.map, color: Colors.black),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text('Abrir no mapa externo'),
            )
          ],
        ),
      ),
      PopupMenuItem(
        value: ACAO_DISTANCIA,
        child: Row(
          children: [
            Icon(Icons.directions_run, color: Colors.black),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text('Pegar distância'),
            )
          ],
        ),
      ),
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
      obterLocalizacaoAtual();
    });
  }

  Position? localizacaoAtual;

  void obterLocalizacaoAtual() async {
    bool servicoHabilitado = await _servicoHabilitado();
    if(!servicoHabilitado){
      return;
    }
    bool permissoesPermitidas = await _permissoesPermitidas();
    if(!permissoesPermitidas){
      return;
    }
    localizacaoAtual = await Geolocator.getCurrentPosition();
    setState(() {
    });
  }
  void _abrirCoordenadasNoMapaExterno(ponto) {
    var lat = double.parse(ponto.latitude);
    var lon = double.parse(ponto.longitude);
    MapsLauncher.launchCoordinates(lat,lon);

  }

  double _distanciaEntre(ponto){
    var lat = double.parse(ponto.latitude);
    var lon = double.parse(ponto.longitude);
    final distancia = Geolocator.distanceBetween(localizacaoAtual!.latitude, localizacaoAtual!.longitude, lat, lon);
    return distancia;
  }

  Future<bool> _servicoHabilitado() async {
    bool servicoHabilotado = await Geolocator.isLocationServiceEnabled();
    if(!servicoHabilotado){
      await _mostrarMensagemDialog('Para utilizar esse recurso, você deverá habilitar o serviço de localização '
          'no dispositivo');
      Geolocator.openLocationSettings();
      return false;
    }
    return true;
  }

  Future<bool> _permissoesPermitidas() async {
    LocationPermission permissao = await Geolocator.checkPermission();
    if(permissao == LocationPermission.denied){
      permissao = await Geolocator.requestPermission();
      if(permissao == LocationPermission.denied){
        _mostrarMensagem('Não será possível utilizar o recusro por falta de permissão');
        return false;
      }
    }
    if(permissao == LocationPermission.deniedForever){
      await _mostrarMensagemDialog(
          'Para utilizar esse recurso, você deverá acessar as configurações '
              'do appe permitir a utilização do serviço de localização');
      Geolocator.openAppSettings();
      return false;
    }
    return true;
  }

  void _mostrarMensagem(String mensagem){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> _mostrarMensagemDialog(String mensagem) async{
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Atenção'),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarMensagemDialogGeneric(String mensagem, String titulo) async{
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}