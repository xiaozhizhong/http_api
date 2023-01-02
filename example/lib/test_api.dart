import 'package:http_api_generator/http_api.dart';

part 'test_api.g.dart';

@RestApi(baseUrl: "https://www.google.com")
abstract class TestApi {
  factory TestApi() => _TestApi();

  @POST("test/{name}/{id}")
  HttpApi<ResponseBody<int>?> test(@Body() RequestBody request, {@Path("name") String? name, @Path("id") String? id});

  @POST("test/fields/{name}/{id}")
  @FormUrlEncoded()
  HttpApi<ResponseBody> testFields(
      {@Path("name") required String name,
      @Path("id") required String id,
      @Field("stepId") required String stepId,
      @Field("token") required String token});

  @GET("test/query")
  HttpApi<int> testQuery({@Query("stepId") required String stepId, @Query("token") required String token});

  @POST("test/body")
  HttpApi<int?> testBody(@Body() dynamic body);

  @POST("test/bodyParts")
  HttpApi<List<String?>> testBodyParts(@BodyPart("ids") List<int> ids, @BodyPart() String name);

  @POST("test/body")
  @HttpOptions(
      responseType: HttpResponseType.bytes, sendTimeout: 10000, receiveTimeout: 20000, headers: {"auth": "abcdefg"})
  HttpApi<List<ResponseBody>> testOptions(@Body() dynamic body);

  @POST("test/{name}/{id}")
  @FromJson(_fromJson)
  HttpApi<ResponseBody<int>?> testFromJson(@Body() RequestBody request, {@Path("name") String? name, @Path("id") String? id});

  static _fromJson(dynamic map){
    return ResponseBody.fromJson(map);
  }
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

  @override
  String toString() {
    return 'ResponseBody{name: $name, id: $id, data: $data}';
  }
}
