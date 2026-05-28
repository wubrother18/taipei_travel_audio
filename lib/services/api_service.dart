import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class ApiService {
  static String baseServer = "https://www.travel.taipei/open-api";
  static Dio dio = Dio();
  static ApiService? _instance;
  static Map<String, String> requestHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };

  ApiService._internal() {
    _instance = this;
  }

  factory ApiService() =>
      _instance ?? ApiService._internal();

  Future<Response> getList(String lang,int page) async {
    var url = '$baseServer/$lang/Media/Audio?page=$page';

    return get(url,);
  }

  Future<bool> downloadFile(String url, String absolutePath, {Function(int r,int t)? onProgress}) async {
    try {
      await dio.download(
        url,
        absolutePath,
        onReceiveProgress: onProgress,
      );
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<Response> get(String url) async {
    debugPrint("url:$url");

    try {
      Response response = await dio.get(
        url,
        options: Options(
          responseType: ResponseType.json,
          headers: requestHeaders,
        ),
      );
      return response;
    } on DioException catch (e) {
      debugPrint("----->m:${e.message}");
      debugPrint("----->e:${e.error}");

      return Response(requestOptions: RequestOptions())..statusCode = 400
      ;
    }
  }
}