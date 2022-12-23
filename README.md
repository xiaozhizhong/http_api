## Features

Generate Http api info by annotation

## Getting started

Add dependency to your pubspec:
```yaml
http_api_generator: latest_version
```

## Usage

```dart
part 'login.api.g.dart';

@RestApi()
abstract class LoginApi {
  factory LoginApi() => _LoginApi();

  @POST("app/login")
  HttpApi<UserEntity> login(@Body() LoginRequest request);

  @GET("app/{userId}")
  HttpApi<UserEntity?> getUser(@Path() String userId);
}
```

Then run the build_runner by 'flutter packages pub run build_runner build'. 

You can get the following information from the generated HttpApi:
```dart
/// @Method
String method;

/// Url of @Method and @Path
String url;

/// baseUrl in @HttpApi
String? baseUrl;

/// @Body
Object? body;

/// @Query
Map<String, dynamic>? queryParams;

/// @Field
Map<String, dynamic>? fields;

/// @FormUrlEncoded
bool formUrlEncoded;

/// Type of response, as T
Type responseType;

/// From Json
FromJsonTransform<RESPONSE>? fromJson;
```
