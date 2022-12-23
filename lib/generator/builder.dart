import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'generator.dart';

///
///@author xiao
///@date 2022/12
///

Builder httpApiBuilder(BuilderOptions options) =>
    SharedPartBuilder([HttpApiGenerator()],'http_api');
