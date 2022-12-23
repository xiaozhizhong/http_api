import 'package:meta/meta.dart';

///
///@author xiao
///@date 2022/12
///
@immutable
class Method {
  final String method;
  final String path;

  const Method(this.method, this.path);
}

final requestMethods = [GET, POST, PATCH, PUT, DELETE];

@immutable
class GET extends Method {
  const GET(String path) : super("GET", path);
}

@immutable
class POST extends Method {
  const POST(String path) : super("POST", path);
}

@immutable
class PATCH extends Method {
  const PATCH(String path) : super("PATCH", path);
}

@immutable
class PUT extends Method {
  const PUT(String path) : super("PUT", path);
}

@immutable
class DELETE extends Method {
  const DELETE(String path) : super("DELETE", path);
}
