import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter  Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  var currentUrl='';
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  late WebViewController controllerGlobal;
  var baseUrl='https://dummypay.publicdemo.xyz';
  /// set your required data on url like this
  ///    baseUrl = '$baseUrl/payment-mobile?customer_id=100&order_id=110$amount=200';
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) WebView.platform = AndroidWebView();

  }


  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        body: WillPopScope(
            onWillPop:()=>_exitApp(context),
            child:Stack(
              children: [
                WebView(
                  javascriptMode: JavascriptMode.unrestricted,
                  initialUrl: baseUrl,
                  userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_3 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13E233 Safari/601.1',
                  gestureNavigationEnabled: true,
                  onWebViewCreated: (WebViewController webViewController) {
                    _controller.future.then((value) => controllerGlobal = value);
                    _controller.complete(webViewController);
                  },
                  onPageStarted: (String url) {
                    print('Page started loading: $url');
                    setState(() {
                      _isLoading = true;
                    });
                    bool _isSuccess = url.contains('success') && url.contains(baseUrl);
                    bool _isFailed = url.contains('fail') && url.contains(baseUrl);
                    bool _isCancel = url.contains('cancel') && url.contains(baseUrl);
                    if(_isSuccess){
                      showSnackBar('Payment Success');
                      // Navigator.pushReplacementNamed(context, '');
                    }else if(_isFailed) {
                      showSnackBar('Payment Failed');
                      // Navigator.pushReplacementNamed(context, '');
                    }else if(_isCancel) {
                      showSnackBar('Payment Canceled');
                      // Navigator.pushReplacementNamed(context, '');
                    }
                  },

                  onPageFinished: (String url) {
                    print('Page finished loading: $url');
                    setState(() {
                      _isLoading = false;
                    });
                  },
                ),
                _isLoading ? Center(
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
                ) : const SizedBox.shrink(),
              ],
            ),


        ),
      ),
    );
  }

  void showSnackBar(String msg){

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg),));
  }

  Future<bool> _exitApp(BuildContext context) async {
    if (await controllerGlobal.canGoBack()) {
      controllerGlobal.goBack();
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }


}
