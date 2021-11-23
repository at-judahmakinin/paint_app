//import 'dart:html';
import 'dart:html';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import './dio_instance.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class ApiWidget extends InheritedWidget {
  static const timeOut = Duration(seconds: 120);
  
  ApiWidget({Key? key, required Widget child}) : super(key: key, child: child);

  static ApiWidget of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<ApiWidget>()
        as ApiWidget);
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }

  //save media assets
  Future<dynamic> sendUserPaint(String userToken, Uint8List imageBytes) async {
    debugPrint("saveUser user paint hit");
    debugPrint("userToken= " + userToken.toString());
    print(imageBytes.runtimeType);

    try {
//using dio with imageBytes
      // dio.options.headers["Authorization"] = "Bearer $userToken";
      // var formData = FormData.fromMap({'mediaAsset': _img});

      // final response =
      //     await dio.post("/media_asset/save_paint", data: formData);

//using http with the filepath
      //Map<String, String> headers = {"Authorization": "Bearer $userToken"};

      // final multipartRequest = http.MultipartRequest(
      //     'POST',
      //     Uri.parse(
      //         'https://https://advent.amalitech-dev.net/api/media_asset/save_paint'));
      // multipartRequest.headers.addAll(headers);
      // multipartRequest.files
      //     .add(http.MultipartFile.fromBytes('mediaAsset', file_path));

//using http with fileBytes
      var headers = {'Authorization': 'Bearer $userToken'};
      var request = http.MultipartRequest(
          'POST',
          Uri.parse(
              'https://https://advent.amalitech-dev.net/api/media_asset/save_paint'));
      request.files.add(http.MultipartFile.fromBytes('mediaAsset', imageBytes));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      // if (response.statusCode == 200) {
      //   print(await response.stream.bytesToString());
      // } else {
      //   print(response.reasonPhrase);
      // }

    } catch (e) {
      //debugPrint(e.toString());

      //if (e is HttpException) {
      if (e is DioError) {
        debugPrint(e.message.toString());
      }
      throw Exception(e);
    }
  }

  SnackBar showMySnackBar(String content) {
    return SnackBar(
      content: Text(content),
      duration: const Duration(seconds: 20),
    );
  }
}
