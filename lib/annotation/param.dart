// @immutable
// class Header {
//   final String value;
//
//   const Header(this.value);
// }
//
// @immutable
// class Headers {
//   final Map<String, dynamic>? value;
//
//   const Headers([this.value]);
// }

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

@immutable
class Field {
  final String? value;

  const Field([this.value]);
}

@immutable
class Path {
  final String? value;

  const Path([this.value]);
}

@immutable
class Query {
  final String value;

  const Query(this.value);
}

@immutable
class FromJson {
  final FromJsonTransform fromJson;

  const FromJson(this.fromJson);
}
