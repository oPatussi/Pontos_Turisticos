import 'package:atividade1/dao/ponto_dao.dart';
import 'package:atividade1/pages/lista_pontos_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:atividade1/pages/maps_home.dart';
import 'package:maps_launcher/maps_launcher.dart';

import '../model/ponto.dart';

class ConteudoFormDialog extends StatefulWidget{
  final Ponto? pontoAtual;

  ConteudoFormDialog({Key? key, this.pontoAtual}) : super (key: key);

  @override
  ConteudoFormDialogState createState() => ConteudoFormDialogState();

}
class ConteudoFormDialogState extends State<ConteudoFormDialog> {

  MapsPageState mapsPageState = MapsPageState();
  final formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final detalhesController = TextEditingController();
  final dataCadastroController = TextEditingController();
  final diferenciaisController = TextEditingController();
  final _dateFormat = DateFormat('dd/MM/yyyy');
  final _controller = TextEditingController();

  String data = '';
  Position? _localizacaoAtual;
  bool pegouLocal = false;

  @override
  void initState(){
    super.initState();
    if (widget.pontoAtual != null){
      nomeController.text = widget.pontoAtual!.nome;
      detalhesController.text = widget.pontoAtual!.detalhes;
      dataCadastroController.text = widget.pontoAtual!.dataFormatada;
      diferenciaisController.text = widget.pontoAtual!.diferenciais;
    }
  }

  Widget build(BuildContext context){
    return Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nomeController,
              decoration: InputDecoration(labelText: 'Nome'),
              validator: (String? valor){
                if (valor == null || valor.isEmpty){
                  return 'Informe o nome do ponto';
                }
                return null;
              },
            ),TextFormField(
              controller: detalhesController,
              decoration: InputDecoration(labelText: 'Descição'),
              validator: (String? valor){
                if (valor == null || valor.isEmpty){
                  return 'Informe a descrição do ponto';
                }
                return null;
              },
            ),TextFormField(
              controller: diferenciaisController,
              decoration: InputDecoration(labelText: 'Diferenciais'),
              validator: (String? valor){
                if (valor == null || valor.isEmpty){
                  return 'Informe os diferenciais do ponto';
                }
                return null;
              },
            ),
            Row(
              children: [
                Text("Ponto cadastrado em: ${dataCadastroController.text.isEmpty ? _dateFormat.format(DateTime.now()): dataCadastroController.text}")
              ]
              ,
            ),
            ElevatedButton(
                onPressed: _obterLocalizacaoAtual,
                child: Text("Obter localização atual")
            ),
            ElevatedButton(
                onPressed: pegouLocal? _abrirCoordenadasNoMapaExterno: null,
                child: Text("Confirmar localização no mapa externo")
            ),
            Text("Caso o endereço esteja errado, procure no campo a baixo:"),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                    labelText: 'Endereço ou ponto de referencia',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.map),
                      tooltip: 'Abrir no mapa',
                      onPressed: _abrirNoMapaExterno,
                    )
                ),
              ),
            )
          ],
        )
    );
  }


  Ponto get novoPonto => Ponto(
    id: widget.pontoAtual?.id ?? 0,
    nome: nomeController.text,
    detalhes: detalhesController.text,
    diferenciais: diferenciaisController.text,
    latitude: _localizacaoAtual!.latitude.toString(),
    longitude: _localizacaoAtual!.longitude.toString(),
    dataCadastro: DateTime.now(),
  );

  bool dadosValidados() => formKey.currentState?.validate() == true;

  void _atualizarLocal() async{
    if (pegouLocal == false){
      pegouLocal = true;
    }else{
      pegouLocal = false;
    }
  }

  void _obterLocalizacaoAtual() async {
    print("clique");
    bool servicoHabilitado = await _servicoHabilitado();
    if(!servicoHabilitado){
      return;
    }
    _permissoesPermitidas();
    _localizacaoAtual = await Geolocator.getCurrentPosition();
    _atualizarLocal();
    setState(() {
    });

  }

  void _abrirCoordenadasNoMapaExterno() {
    if (_localizacaoAtual == null) {
      return;
    }
    MapsLauncher.launchCoordinates(
        _localizacaoAtual!.latitude, _localizacaoAtual!.longitude);
  }

  void _abrirNoMapaExterno(){
    if(_controller.text.trim().isEmpty){
      return;
    }
    MapsLauncher.launchQuery(_controller.text);
  }

  Future<bool> _servicoHabilitado() async {
    bool servicoHabilitado = await Geolocator.isLocationServiceEnabled();
    if(!servicoHabilitado){
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

}