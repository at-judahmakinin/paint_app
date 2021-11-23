import 'package:dio/dio.dart';

var remoteOptions = BaseOptions(
    //baseUrl: 'https://advent-calendar-api.herokuapp.com',
    baseUrl: 'https://advent.amalitech-dev.net/api',
    //baseUrl: 'https://4fd2-196-61-44-162.ngrok.io',
    connectTimeout: 60 * 1000, // 60 seconds
    receiveTimeout: 60 * 1000 // 60 seconds
    );

//online json hosting service key
//-> baseUrl: https://api.jsonbin.io/b/618b654d4a56fb3dee0c4807/1

//switch to either local or remote depending on where
//you're retrieving your data from
Dio dio = Dio(remoteOptions);
