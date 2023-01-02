import 'package:http_api_generator/annotation/param.dart';
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

  /// Options, may be null
  final HttpOptions? options;

  HttpApi(this.method, this.url,
      {this.baseUrl,
      this.formUrlEncoded = false,
      this.body,
      this.queryParams,
      this.fields,
      this.fromJson,
      this.options})
      : responseType = RESPONSE;

  @override
  String toString() {
    return 'HttpApi{method: $method, url: $url, baseUrl: $baseUrl, body: $body, queryParams: $queryParams, fields: $fields, formUrlEncoded: $formUrlEncoded, responseType: $responseType, fromJson: $fromJson, options: $options}';
  }

  HttpApi<RESPONSE> copyWith({
    String? method,
    String? url,
    String? baseUrl,
    bool? formUrlEncoded,
    Object? body,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? fields,
    FromJsonTransform<RESPONSE>? fromJson,
    HttpOptions? options,
  }) {
    return HttpApi<RESPONSE>(
      method ?? this.method,
      url ?? this.url,
      baseUrl: baseUrl ?? this.baseUrl,
      formUrlEncoded: formUrlEncoded ?? this.formUrlEncoded,
      body: body ?? this.body,
      queryParams: queryParams ?? this.queryParams,
      fields: fields ?? this.fields,
      fromJson: fromJson ?? this.fromJson,
      options: options ?? this.options,
    );
  }
}
