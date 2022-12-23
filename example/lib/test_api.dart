import 'package:http_api_generator/http_api.dart';

part 'test_api.g.dart';

@RestApi()
abstract class TestApi {

  factory TestApi()=>_TestApi();

  @POST("https://www.baidu.com/{name}/{id}")
  HttpApi<ResponseBody<int>?> getTaskName(@Body() RequestBody request,
      {@Path("name") String? name, @Path("id") String? id});

  @POST("https://www.baidu.com/{name}/{id}")
  @FormUrlEncoded()
  HttpApi<ResponseBody> getStepName(
      {@Path("name") required String name,
      @Path("id") required String id,
      @Field("stepId") required String stepId,
      @Field("token") required String token});

  @GET("https://www.baidu.com/")
  HttpApi<ResponseBody> getStepName2(
      {@Query("stepId") required String stepId, @Query("token") required String token});
}

final testApi = TestApi();

class RequestBody {
  String name;
  String id;

  RequestBody(this.name, this.id);
}

class ResponseBody<T> {
  String name;
  String id;
  T data;

  ResponseBody(this.name, this.id, this.data);

  factory ResponseBody.fromJson(dynamic json) {
    return ResponseBody(json["name"], json["id"], json["data"]);
  }
}
