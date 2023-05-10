import 'package:atividade1/pages/lista_pontos_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:atividade1/pages/maps_home.dart';

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
  final descricaoController = TextEditingController();
  final dataCadastroController = TextEditingController();
  final diferenciaisController = TextEditingController();
  final _dateFormat = DateFormat('dd/MM/yyyy');

  String data = '';

  @override
  void initState(){
    super.initState();
    if (widget.pontoAtual != null){
      nomeController.text = widget.pontoAtual!.nome;
      descricaoController.text = widget.pontoAtual!.descricao;
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
              controller: descricaoController,
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
            )
          ],
        )
    );
  }


  Ponto get novoPonto => Ponto(
    id: widget.pontoAtual?.id ?? 0,
    nome: nomeController.text,
    descricao: descricaoController.text,
    diferenciais: diferenciaisController.text,
    dataCadastro: DateTime.now(),
    latitude:
  );

  bool dadosValidados() => formKey.currentState?.validate() == true;

}