import 'dart:io';

import 'package:dio/dio.dart';
import 'package:education_app/constant/api_url.dart';
import 'package:education_app/helpers/user_email.dart';
import 'package:education_app/models/network_response.dart';

class AuthApi {
  Dio dioApi() {
    BaseOptions options = BaseOptions(
      baseUrl: ApiUrl.baseUrl,
      headers: {
        "x-api-key": ApiUrl.apiKey,
        HttpHeaders.contentTypeHeader: "application/json"
      },
      responseType: ResponseType.json,
    );
    final dio = Dio(options);
    return dio;
  }

  Future<NetworkResponse> _getRequest({endpoint, param}) async {
    try {
      final dio = dioApi();
      final result = await dio.get(endpoint, queryParameters: param);
      return NetworkResponse.success(result.data);
    } on DioError catch (e) {
      if (e.type == DioErrorType.sendTimeout) {
        return NetworkResponse.error(null, "request timeout");
      }
      return NetworkResponse.error(null, "request error dio");
    } catch (e) {
      return NetworkResponse.error(null, "other error");
    }
  }

  Future<NetworkResponse> _postRequest({endpoint, body}) async {
    try {
      final dio = dioApi();
      final result = await dio.post(endpoint, data: body);
      return NetworkResponse.success(result.data);
    } on DioError catch (e) {
      if (e.type == DioErrorType.sendTimeout) {
        return NetworkResponse.error(null, "request timeout");
      }
      return NetworkResponse.error(null, "request error dio");
    } catch (e) {
      return NetworkResponse.error(null, "other error");
    }
  }

  Future<NetworkResponse> getUserByEmail() async {
    final result = await _getRequest(
        endpoint: ApiUrl.users, param: {"email": UserEmail.getUserEmail()});
    return result;
  }

  Future<NetworkResponse> postRegister(body) async {
    final result =
        await _postRequest(endpoint: ApiUrl.userRegistration, body: body);
    return result;
  }

  Future<NetworkResponse> postUpdateUser(body) async {
    final result =
        await _postRequest(endpoint: ApiUrl.userUpdateProfile, body: body);
    return result;
  }
}
