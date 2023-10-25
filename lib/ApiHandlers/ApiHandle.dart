import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:jost_pay_wallet/Values/utils.dart';

class ApiHandler {


  static Future<dynamic> post(body, url) async {

      _setHeadersPost() => {
            'Content-type': 'application/json',
            'Accept': 'application/json',
            'Authorization':
                '4fe0c4203533aa61c0fae455ac8d9d07cb237fbf5b8b1e92a783319c02fa5a8d'
          };

      // var baseUrl = Uri.http('139.59.88.239', '/api$url');
      var baseUrl = Uri.http(Utils.url, '/api$url');

      http.Response response = await http.post(
          baseUrl,
          headers: _setHeadersPost(),
          body: jsonEncode(body)
      );

      return response;

  }

  static Future<dynamic> post1(body, url) async {

    _setHeadersPost() => {
      'Content-type': 'application/json',
      //'Accept': 'application/json',
      'Authorization': '4fe0c4203533aa61c0fae455ac8d9d07cb237fbf5b8b1e92a783319c02fa5a8d'
    };

    // var baseUrl = Uri.http('139.59.88.239', '/api$url');
    var baseUrl = Uri.http('${Utils.url}', '/api$url');

    http.Response response = await http.post(
        baseUrl,
        headers: _setHeadersPost(),
        body: jsonEncode(body)
    );

    return response;

  }

  static Future<dynamic> postRcp(body, url) async {


    // print(body);

    // print(Uri.parse("https://rpc.ankr.com/polygon"));
    try {
      await http.post(
          Uri.parse("$url"),
          // headers: _setHeadersPost(),
          body: jsonEncode(body)
      );
      return true;

    }catch(e){
      return false;
    }

  }


  static Future<dynamic> get(url) async {

      // var baseUrl = Uri.http('139.59.88.239', '/api$url');
      var baseUrl = Uri.http('${Utils.url}', '/api$url');

      _setHeadersGet() => {
            'Content-type': 'application/json',
            'Authorization':
                '4fe0c4203533aa61c0fae455ac8d9d07cb237fbf5b8b1e92a783319c02fa5a8d'
          };

      http.Response response =
          await http.get(baseUrl, headers: _setHeadersGet());

      return response;
  }

  static Future<dynamic> getParams(url, params) async {

      var baseUrl = Uri.http('${Utils.url}', '/api$url',params);
      // var baseUrl = Uri.http('139.59.88.239', '/api$url');


      _setHeadersGet() => {
            'Content-type': 'application/json',
            'Authorization':
                '4fe0c4203533aa61c0fae455ac8d9d07cb237fbf5b8b1e92a783319c02fa5a8d'
          };

      http.Response response =
          await http.get(baseUrl, headers: _setHeadersGet());

      return response;
  }


  static Future<dynamic> getNewsParams(base, url, params) async {
    //var baseUrl = Uri.https('pro-api.coinmarketcap.com','/v1/cryptocurrency/quotes/latest',params);
      var baseUrl = Uri.https('$base', '$url', params);



      http.Response response = await http.get(
        baseUrl,
      );

      return response;
  }

  static Future<dynamic> testPost(body, url) async {

      _setHeadersPost() => {
            'Content-type': 'application/json',
            'Accept': 'application/json',
            'Authorization':
                '4fe0c4203533aa61c0fae455ac8d9d07cb237fbf5b8b1e92a783319c02fa5a8d'
          };

      var baseUrl = Uri.http('${Utils.url}', '/api$url');
      // var baseUrl = Uri.http('139.59.88.239', '/api$url');


      http.Response response = await http.post(baseUrl,
          headers: _setHeadersPost(), body: jsonEncode(body));

      return response;
  }

  static Future<dynamic> getOnlineTrasection(base, url, params) async {
      //var baseUrl = Uri.https('pro-api.coinmarketcap.com','/v1/cryptocurrency/quotes/latest',params);
      var baseUrl = Uri.https('$base', '$url', params);

      _setHeadersGet() => {
            'Content-type': 'application/json',
          };

      http.Response response = await http.get(
        baseUrl,
        headers: _setHeadersGet(),
      );

      return response;
  }


  static String calculateLength(String value){

    int showLength = 0;
    if(double.parse(value) < 1){
      showLength = 1;
      var splitted = value.split('.');

      for(int i=0;i<splitted[1].length;i++){

        if(splitted[1][i] == "0"){
          showLength = showLength+1;
        }
        else{
          break;
        }

      }
    }
    else{
      showLength = 2;
    }

    return double.parse(value).toStringAsFixed(showLength);

  }


  static String calculateLength3(String value){

    int showLength = 0;
    if(double.parse(value) < 1){
      showLength = 1;
      var splitted = value.split('.');

      for(int i=0;i<splitted[1].length;i++){

        if(splitted[1][i] == "0"){
          showLength = showLength+1;
        }
        else{
          break;
        }

      }

      showLength = showLength + 2;

    }
    else{
      showLength = 2;
    }

    return double.parse(value).toStringAsFixed(showLength);

  }



  static Future<dynamic> moralisGetParams(url, params) async {

    var baseUrl = Uri.https('deep-index.moralis.io', '/api$url', params);

    _setHeadersGet() => {
      'Content-type': 'application/json',
      'X-API-Key': 'ZhkwlXP0YNIMQ4kdc2A16RHPeieLN6TkgVkU43EgZ9Bq13KU5sP4WZuDHc6zWJNR'
    };

    http.Response response =
    await http.get(baseUrl, headers: _setHeadersGet());

    return response;
  }

  static Future<dynamic> moralisTokenUrl(url) async {

    var baseUrl = Uri.parse('$url');

    _setHeadersGet() => {
      'Content-type': 'application/json',
    };

    http.Response response =
    await http.get(baseUrl, headers: _setHeadersGet());

    return response;
  }


  static Future<dynamic> polkaPost(body, url) async {

    _setHeadersPost() => {
      'Content-type': 'application/json',
      'X-API-Key': '18be4d7b73124fc69d9810018fbad122'
    };

    //var baseUrl = Uri.http('128.199.216.229', '/api$url');
    var baseUrl = Uri.https('polkadot.api.subscan.io', '/api/scan/transfers');

    http.Response response = await http.post(
        baseUrl,
        headers: _setHeadersPost(),
        body: jsonEncode(body)
    );

    return response;

  }


}
