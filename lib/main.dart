import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// don't forget this line
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Remove the debug banner
      debugShowCheckedModeBanner: false,
      title: "Webview Exampe",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  // future to read and load the example html file
  Future<String> localLoader() async {
    return await rootBundle.loadString('assets/Sample.html');
  }

  Widget _buildWeightBtn() {
    return FutureBuilder<WebViewController>(
      future: _controller.future,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> controller) {
        if (controller.hasData) {
          return FloatingActionButton(
            onPressed: () async {
              String js = "e = document.activeElement;";
              js += "e.value = '99';";
              js += "f = Array.from(document.querySelectorAll('input'));";
              js += "i=f.indexOf(e);";
              js += "ne = f[i+1];";
              js += "ne.focus();";
              js += "ne.value='85';";
              js += "o = document.getElementById('output');";
              js += "o.innerHTML='Events executed:<br/>';";
              js += "o.innerHTML+='locate focused field and insert value 99.';";
              js += "o.innerHTML+='</br>';";
              js += "o.innerHTML+='locate next focusable input field.</br>';";
              js += "o.innerHTML+='insert value 85 on the second field.</br>';";
              js += "o.innerHTML+='write this text in a output div element.';";
              await controller.data!.evaluateJavascript(js);
            },
            child: Icon(Icons.auto_awesome),
          );
        }
        return Container();
      },
    );
  }

  Widget buildWebView(BuildContext context) {
    return FutureBuilder<String>(
      future: localLoader(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return WebView(
            initialUrl:
                new Uri.dataFromString(snapshot.data!, mimeType: 'text/html')
                    .toString(),
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller.complete(webViewController);
            },
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return CircularProgressIndicator();
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebView Example'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // the most important part of this example
        child: buildWebView(context),
      ),
      floatingActionButton: _buildWeightBtn(),
    );
  }
}
