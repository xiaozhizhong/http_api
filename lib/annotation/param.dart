import 'package:http_api_generator/entity/http_api_info.dart';
import 'package:meta/meta.dart';

///
///@author xiao
///@date 2022/12
///
@immutable
class FormUrlEncoded {
  final mime = 'application/x-www-form-urlencoded';

  const FormUrlEncoded();
}

@immutable
class Body {
  const Body();
}

/// Automatically generate a Map of all @BodyPart and used as [Body].
/// This is a useful when a request body is very simple and you don't wanna define a Request Model.
/// * Enum and Object(toJson) are currently not supported.
/// * Should not use both of @Body and @BodyPart.
/// eg:
/// (@BodyPart("userId") String id, @BodyPart() String name) => {"userId":"$id", "name": "$name"}
///
@immutable
class BodyPart {
  final String? key;

  const BodyPart([this.key]);
}

@immutable
class Field {
  final String? key;

  const Field([this.key]);
}

@immutable
class Path {
  final String? key;

  const Path([this.key]);
}

@immutable
class Query {
  final String key;

  const Query(this.key);
}

@immutable
class FromJson {
  final FromJsonTransform fromJson;

  const FromJson(this.fromJson);
}

@immutable
class HttpOptions {
  static const className = "HttpOptions";
  final HttpResponseType? responseType;
  final int? connectTimeout;
  final int? sendTimeout;
  final int? receiveTimeout;
  final Map<String, dynamic>? headers;

  const HttpOptions({this.responseType, this.connectTimeout, this.sendTimeout, this.receiveTimeout, this.headers});

  HttpOptions.from({
    String? responseType,
    this.connectTimeout,
    this.sendTimeout,
    this.receiveTimeout,
    this.headers,
  }) : responseType = responseType == null ? null : HttpResponseType.fromName(responseType);

  @override
  String toString() {
    return 'HttpOptions{responseType: $responseType, connectTimeout:$connectTimeout,sendTimeout: $sendTimeout, receiveTimeout: $receiveTimeout, headers: $headers}';
  }
}

enum HttpResponseType {
  json,
  stream,
  plain,
  bytes;

  factory HttpResponseType.fromName(String name) {
    switch (name) {
      case "json":
        return json;
      case "stream":
        return stream;
      case "plain":
        return plain;
      case "bytes":
        return bytes;
      default:
        return json;
    }
  }
}
