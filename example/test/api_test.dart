import 'package:flutter_test/flutter_test.dart';
import 'package:http_api_example/test_api.dart';

void main(){
  test("test", (){
    final info = testApi.getTaskName(RequestBody("1", "2"),name: "张三",id:"1");
    print(info.method);
  });
}