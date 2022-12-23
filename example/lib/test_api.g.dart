// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_api.dart';

// **************************************************************************
// HttpApiGenerator
// **************************************************************************

class _TestApi implements TestApi {
  @override
  HttpApi<ResponseBody<int>?> getTaskName(RequestBody request,
      {String? name, String? id}) {
    return HttpApi<ResponseBody<int>?>(
        'POST', 'https://www.baidu.com/$name/$id',
        body: request,
        fromJson: (data) =>
            data == null ? null : ResponseBody<int>.fromJson(data));
  }

  @override
  HttpApi<ResponseBody<dynamic>> getStepName(
      {required String name,
      required String id,
      required String stepId,
      required String token}) {
    final fields = {'stepId': stepId, 'token': token};
    return HttpApi<ResponseBody<dynamic>>(
        'POST', 'https://www.baidu.com/$name/$id',
        formUrlEncoded: true,
        fields: fields,
        fromJson: (data) => ResponseBody<dynamic>.fromJson(data));
  }

  @override
  HttpApi<ResponseBody<dynamic>> getStepName2(
      {required String stepId, required String token}) {
    final queries = {'stepId': stepId, 'token': token};
    return HttpApi<ResponseBody<dynamic>>('GET', 'https://www.baidu.com/',
        queryParams: queries,
        fromJson: (data) => ResponseBody<dynamic>.fromJson(data));
  }
}
