import 'package:flutter_test/flutter_test.dart';
import 'package:http_api_example/test_api.dart';

void main(){
  test("test", (){
    final info = testApi.test(RequestBody("1", "2"),name: "john",id:"1");
    print(info.method);
  });

  test("test", (){
    final info = testApi.testBodyParts([1,2,3],"john");
    print(info);
  });
}