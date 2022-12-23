import 'package:meta/meta.dart';

///
///@author xiao
///@date 2022/12
///

typedef FromJsonTransform<T> = T Function(dynamic json);

class HttpApi<@required RESPONSE> {
  static const className = "HttpApi";

  /// Implement of @Method
  final String method;

  /// Url of @Method and @Path
  final String url;

  /// baseUrl in @RestApi
  final String? baseUrl;

  /// @Body
  final Object? body;

  /// @Query
  final Map<String, dynamic>? queryParams;

  /// @Field
  final Map<String, dynamic>? fields;

  /// @FormUrlEncoded
  final bool formUrlEncoded;

  /// Type of response, as T
  final Type responseType;

  /// From Json
  final FromJsonTransform<RESPONSE>? fromJson;

  HttpApi(
    this.method,
    this.url, {
    this.baseUrl,
    this.formUrlEncoded = false,
    this.body,
    this.queryParams,
    this.fields,
    this.fromJson,
  }) : responseType = RESPONSE;
}
