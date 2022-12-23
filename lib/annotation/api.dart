import 'package:meta/meta.dart';

///
///@author xiao
///@date 2022/12
///
@immutable
class RestApi {
  static const className = "RestApi";

  final String? baseUrl;

  const RestApi({this.baseUrl});
}
