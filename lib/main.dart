import 'package:flutter/material.dart';
import 'package:atividade1/pages/filtro_page.dart';
import 'package:atividade1/pages/lista_pontos_page.dart';

void main() {
  runApp(const GerenciadorDeTarefasPontos());
}

class GerenciadorDeTarefasPontos extends StatelessWidget {
  const GerenciadorDeTarefasPontos({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        primarySwatch: Colors.teal,
      ),
      home: ListaPontosPage(),
      routes: {
        FiltroPage.routeName: (BuildContext context)=> FiltroPage(),
      },
    );
  }
}



