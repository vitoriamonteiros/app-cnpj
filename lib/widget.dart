import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _inputCNPJ = TextEditingController();
  final _inputRazao = TextEditingController();
  final _inputFantasia = TextEditingController();
  final _inputRaiz = TextEditingController();

  String _labelButton = 'Consultar CNPJ';

  void resetField() {
    _inputCNPJ.clear();
    _inputRazao.clear();
    _inputFantasia.clear();
    _inputRaiz.clear();
  }

  void setWaiting(String aCaption) {
    _labelButton = aCaption;
    setState(() {});
  }

  void setMsgError(String aTitulo, String aMessage) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.red,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(aTitulo,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ))
              ],
            ),
            content: Text(
              aMessage,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "OK",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          );
        });
  }

  void getRequestCNPJ(String aCNPJ) async {
    try {
      resetField();

      var dio = Dio();
      dio.options.connectTimeout = Duration(seconds: 5);
      dio.options.connectTimeout = Duration(seconds: 3);

      if (aCNPJ.length != 14) {
        setMsgError('CNPJ inválido!', 'CNPJ deve possuir 14 dígitos !');
        return;
      }

      setWaiting('Aguarde ....');
      var url = 'https://publica.cnpj.ws/cnpj/$aCNPJ';
      var response = await dio.get(url);

      if (response.data['erro'] != null) {
        setMsgError('Erro ao consultar CNPJ', 'CNPJ não encontrado !');
        setWaiting('Consultar CNPJ');
      }

      _inputRazao.text = response.data['razao_social'].toUpperCase();
      _inputFantasia.text = response.data['nome_fantasia'].toUpperCase();
      _inputRaiz.text = response.data['cnpj_raiz'].toUpperCase();

      setWaiting('Consultar CNPJ');
    } on Exception catch (erro) {
      setWaiting('Consulta CNPJ');
      setMsgError('Erro ao Consultar CNPJ', erro.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Image.asset(
                      'assets/cnpj.png',
                      width: 250,
                    ),
                    TextFormField(
                      controller: _inputCNPJ,
                      maxLength: 14,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue)),
                          labelText: 'CNPJ'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Digite o CNPJ";
                        }
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            getRequestCNPJ(_inputCNPJ.text);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_labelButton,
                                style: TextStyle(color: Colors.white))
                          ],
                        )),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _inputRazao,
                      enabled: false,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          labelText: 'Razao Social:'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: _inputFantasia,
                      enabled: false,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          labelText: 'Nome Fantasia:'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: _inputRaiz,
                      enabled: false,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          labelText: 'CNPJ Raiz:'),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
