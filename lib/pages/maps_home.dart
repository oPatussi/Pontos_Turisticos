import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_launcher/maps_launcher.dart';
class MapsPage extends StatefulWidget{
  MapsPage({Key? key}) : super(key: key);

  MapsPageState createState() => MapsPageState();
}

class MapsPageState extends State<MapsPage>{
  Position? localizacaoAtual;
  final _controller = TextEditingController();

  String get _textoLocalizacao => localizacaoAtual == null ? '' :
  'Latitude: ${localizacaoAtual!.latitude}   |   Longitude: ${localizacaoAtual!.longitude}';

  Widget build (BuildContext){
    return Scaffold(
      appBar: AppBar(title: Text('Testando Mapas')),
      body: _criarBody(),
    );
  }

  Widget _criarBody() => ListView(
    children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: ElevatedButton(
          child: Text('Obter Localização Atual'),
          onPressed: obterLocalizacaoAtual,
        ),
      ),
      if(localizacaoAtual != null)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(_textoLocalizacao),
              ),
              ElevatedButton(
                  onPressed: abrirCoordenadasNoMapaExterno,
                  child: Icon(Icons.map)
              ),
            ],
          ),
        ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
              labelText: 'Endereço ou ponto de referencia',
              suffixIcon: IconButton(
                icon: Icon(Icons.map),
                tooltip: 'Abrir no mapa',
                onPressed: abrirMapaExterno,
              )
          ),
        ),
      )
    ],
  );

  void obterLocalizacaoAtual() async {
    bool servicoHabilitado = await servicoMapHabilitado();
    if(!servicoHabilitado){
      return;
    }
    bool permissoesPermitidas = await permissoesMapPermitidas();
    if(!permissoesPermitidas){
      return;
    }
    localizacaoAtual = await Geolocator.getCurrentPosition();
    setState(() {
    });
  }

  void abrirMapaExterno(){
    if(_controller.text.trim().isEmpty){
      return;
    }
    MapsLauncher.launchQuery(_controller.text);
  }

  void abrirCoordenadasNoMapaExterno(){
    if(localizacaoAtual == null){
      return;
    }
    MapsLauncher.launchCoordinates(localizacaoAtual!.latitude, localizacaoAtual!.longitude);
  }


  Future<bool> servicoMapHabilitado() async {
    bool servicoHabilotado = await Geolocator.isLocationServiceEnabled();
    if(!servicoHabilotado){
      await _mostrarMensagemDialog('Para utilizar esse recurso, você deverá habilitar o serviço de localização '
          'no dispositivo');
      Geolocator.openLocationSettings();
      return false;
    }
    return true;
  }

  Future<bool> permissoesMapPermitidas() async {
    LocationPermission permissao = await Geolocator.checkPermission();
    if(permissao == LocationPermission.denied){
      permissao = await Geolocator.requestPermission();
      if(permissao == LocationPermission.denied){
        mostrarMapMensagem('Não será possível utilizar o recusro por falta de permissão');
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

  void mostrarMapMensagem(String mensagem){
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