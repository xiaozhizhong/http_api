// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_api.dart';

// **************************************************************************
// HttpApiGenerator
// **************************************************************************

class _TestApi implements TestApi {
  @override
  HttpApi<ResponseBody<int>?> test(
    RequestBody request, {
    String? name,
    String? id,
  }) {
    return HttpApi<ResponseBody<int>?>(
      'POST',
      'test/$name/$id',
      baseUrl: 'https://www.google.com',
      body: request,
      fromJson: (data) =>
          data == null ? null : ResponseBody<int>.fromJson(data),
    );
  }

  @override
  HttpApi<ResponseBody<dynamic>> testFields({
    required String name,
    required String id,
    required String stepId,
    required String token,
  }) {
    final fields = {
      'stepId': stepId,
      'token': token,
    };
    return HttpApi<ResponseBody<dynamic>>(
      'POST',
      'test/fields/$name/$id',
      baseUrl: 'https://www.google.com',
      formUrlEncoded: true,
      fields: fields,
      fromJson: (data) => ResponseBody<dynamic>.fromJson(data!),
    );
  }

  @override
  HttpApi<int> testQuery({
    required String stepId,
    required String token,
  }) {
    final queries = {
      'stepId': stepId,
      'token': token,
    };
    return HttpApi<int>(
      'GET',
      'test/query',
      baseUrl: 'https://www.google.com',
      queryParams: queries,
    );
  }

  @override
  HttpApi<int?> testBody(dynamic body) {
    return HttpApi<int?>(
      'POST',
      'test/body',
      baseUrl: 'https://www.google.com',
      body: body,
    );
  }

  @override
  HttpApi<List<String?>> testBodyParts(
    List<int> ids,
    String name,
  ) {
    final body = {
      'ids': ids,
      'name': name,
    };
    return HttpApi<List<String?>>(
      'POST',
      'test/bodyParts',
      baseUrl: 'https://www.google.com',
      body: body,
      fromJson: (data) => (data as List).map((e) => e as String?).toList(),
    );
  }

  @override
  HttpApi<List<ResponseBody<dynamic>>> testOptions(dynamic body) {
    final options = HttpOptions.from(
      responseType: 'bytes',
      sendTimeout: 10000,
      receiveTimeout: 20000,
      headers: <String, dynamic>{'auth': 'abcdefg'},
    );
    return HttpApi<List<ResponseBody<dynamic>>>(
      'POST',
      'test/body',
      baseUrl: 'https://www.google.com',
      body: body,
      fromJson: (data) => (data as List)
          .map((e) => ResponseBody<dynamic>.fromJson(e!))
          .toList(),
      options: options,
    );
  }

  @override
  HttpApi<ResponseBody<int>?> testFromJson(
    RequestBody request, {
    String? name,
    String? id,
  }) {
    return HttpApi<ResponseBody<int>?>(
      'POST',
      'test/$name/$id',
      baseUrl: 'https://www.google.com',
      body: request,
      fromJson: (data) => TestApi._fromJson(data),
    );
  }
}
