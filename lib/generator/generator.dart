import 'package:analyzer/dart/constant/value.dart';
import 'package:http_api_generator/annotation/api.dart';
import 'package:http_api_generator/annotation/param.dart' as http_param;
import 'package:http_api_generator/annotation/method.dart' as http_method;
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:code_builder/code_builder.dart';
import 'package:http_api_generator/annotation/param.dart';
import 'package:http_api_generator/entity/http_api_info.dart';
import 'package:source_gen/source_gen.dart';
import 'package:built_collection/built_collection.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';

///
///@author xiao
///@date 2022/12
///

class HttpApiGenerator extends GeneratorForAnnotation<RestApi> {
  static const _fieldsVar = "fields";
  static const _queriesVar = "queries";
  static const _bodyVar = "body";
  static const _optionsVar = "options";

  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError("@${RestApi.className}() annotation should only use in class",
          todo: "Remove the ${RestApi.className}() annotation from ${element.toString()}");
    }
    return _generateClass(element, annotation, buildStep);
  }

  /// Generate Class
  String _generateClass(Element classElement, ConstantReader classAnnotation, BuildStep buildStep) {
    final className = classElement.displayName;
    final generateClassName = "_$className";

    final classHelper = Class((classBuilder) {
      classBuilder
        ..name = generateClassName
        ..implements.add(refer(className));

      for (var methodElement in (classElement as ClassElement).methods) {
        final methodAnnotation = methodElement.getRequestMethodAnnotation();
        if (methodAnnotation == null) {
          // Not annotated with Any Request Method
          continue;
        }
        classBuilder.methods.add(_generateMethod(classElement, methodElement, classAnnotation, methodAnnotation));
      }
    });

    final classContent = '${classHelper.accept(DartEmitter())}';
    return DartFormatter().format(classContent);
  }

  /// Generate Method
  Method _generateMethod(Element classElement, MethodElement methodElement, ConstantReader classAnnotation,
      ConstantReader methodAnnotation) {
    final contentBlocks = <Code>[];

    // Return type of Method
    final responseType = methodElement.returnType;
    final responseInnerType = _TypeHelper.getInnerType(responseType) ?? (DynamicType as DartType);

    // FormUrlEncoded
    final formUrlEncoded = methodElement.getAnnotationByType(http_param.FormUrlEncoded) != null;

    // From json
    final fromJsonRef = _buildFromJson(methodElement, classElement.displayName, responseInnerType);

    // Body
    String? bodyName = methodElement.getParamAnnotationByType(http_param.Body)?.first.displayName;
    final hasBodyParts = _generateBodyParts(contentBlocks, methodElement);
    assert(bodyName == null || !hasBodyParts, "Only one of @Body and @BodyPart should be used");

    // Method
    final requestMethod = methodAnnotation.peek("method")!.stringValue;

    // Path
    final requestPath = _generatePath(methodElement, methodAnnotation);

    // Field
    final hasFields = _generateFields(contentBlocks, methodElement, formUrlEncoded);

    // Query
    final hasQueries = _generateQueries(contentBlocks, methodElement);

    // HttpOptions
    final options = methodElement.getAnnotationByType(http_param.HttpOptions)?.objectValue;
    final hasOptions = options != null;
    if (hasOptions) {
      _generateOptions(contentBlocks, options);
    }

    final method = Method((methodBuilder) {
      // Parameters of Method
      final requiredParameters = ListBuilder<Parameter>();
      final optionalParameters = ListBuilder<Parameter>();
      for (var element in methodElement.parameters) {
        if (!element.isOptional && !element.isRequiredNamed) {
          requiredParameters.add(Parameter((p) => p
            ..type = refer(element.type.getDisplayString(withNullability: true))
            ..name = element.name
            ..named = element.isNamed));
        } else {
          optionalParameters.add(Parameter((p) => p
            ..named = element.isNamed
            ..type = refer(element.type.getDisplayString(withNullability: true))
            ..required = element.isRequiredNamed
            ..name = element.name
            ..defaultTo = element.defaultValueCode == null ? null : Code(element.defaultValueCode!)));
        }
      }

      // HttpApi Constructor
      final positionalArguments = [literal(requestMethod), literal(requestPath)];
      var namedArguments = <String, Expression>{};

      final baseUrl = classAnnotation.peek('baseUrl')?.stringValue;
      if (baseUrl != null) {
        namedArguments.putIfAbsent("baseUrl", () => literalString(baseUrl));
      }
      if (formUrlEncoded) {
        namedArguments.putIfAbsent("formUrlEncoded", () => literalBool(formUrlEncoded));
      }
      if (bodyName != null) {
        namedArguments.putIfAbsent("body", () => refer(bodyName));
      }
      if (hasBodyParts) {
        namedArguments.putIfAbsent("body", () => refer(_bodyVar));
      }
      if (hasFields) {
        namedArguments.putIfAbsent("fields", () => refer(_fieldsVar));
      }
      if (hasQueries) {
        namedArguments.putIfAbsent("queryParams", () => refer(_queriesVar));
      }
      if (fromJsonRef != null) {
        namedArguments.putIfAbsent("fromJson", () => fromJsonRef);
      }
      if (hasOptions) {
        namedArguments.putIfAbsent("options", () => refer(_optionsVar));
      }

      _buildHttpApi(contentBlocks, positionalArguments, namedArguments, responseType, responseInnerType);

      methodBuilder
        ..name = methodElement.displayName
        ..returns = refer(responseType.getDisplayString(withNullability: true))
        ..requiredParameters = requiredParameters
        ..optionalParameters = optionalParameters
        ..body = Block.of(contentBlocks)
        ..annotations.add(CodeExpression(Code("override")));
    });

    return method;
  }

  void _generateOptions(List<Code> blocks, DartObject options) {
    var responseType = options.getField("responseType")?.variable?.name;
    var sendTimeout = options.getField("sendTimeout")?.toIntValue();
    var receiveTimeout = options.getField("receiveTimeout")?.toIntValue();
    var headers = options
        .getField("headers")
        ?.toMapValue()
        ?.map((key, value) => MapEntry(key!.toStringValue()!, literal(value?.toStringValue())));
    var namedArguments = <String, Expression>{};
    if (responseType != null) {
      namedArguments.putIfAbsent("responseType", () => literalString(responseType));
    }
    if (sendTimeout != null) {
      namedArguments.putIfAbsent("sendTimeout", () => literalNum(sendTimeout));
    }
    if (receiveTimeout != null) {
      namedArguments.putIfAbsent("receiveTimeout", () => literalNum(receiveTimeout));
    }
    if (headers != null) {
      namedArguments.putIfAbsent(
          "headers",
          () => literalMap(
                headers.map((k, v) => MapEntry(literalString(k), v)),
                refer('String'),
                refer('dynamic'),
              ));
    }
    final optionsObj = refer(HttpOptions.className).newInstanceNamed("from", [], namedArguments);
    blocks.add(declareFinal(_optionsVar).assign(optionsObj).statement);
  }

  /// Join @Path and url to get the full path.
  String _generatePath(MethodElement m, ConstantReader methodAnnotation) {
    var requestPath = methodAnnotation.peek("path")!.stringValue;

    final paths = m.getParamAnnotationsByType(http_param.Path);
    paths.forEach((pair) {
      final key = pair.second.peek("key")?.stringValue ?? pair.first.displayName;
      requestPath = requestPath.replaceFirst("{$key}", "\$${pair.first.displayName}");
    });
    return requestPath;
  }

  /// Generate fields according to @Field.
  /// Return true if @Field annotations are existed.
  bool _generateFields(List<Code> blocks, MethodElement methodElement, bool formUrlEncoded) {
    final fieldsAnnotation = methodElement.getParamAnnotationsByType(http_param.Field);
    if (fieldsAnnotation.isNotEmpty) {
      assert(formUrlEncoded, "@Field should used with @FormUrlEncoded, In ${methodElement.displayName}");
      final fields = _generateValues(fieldsAnnotation);
      blocks.add(declareFinal(_fieldsVar).assign(literalMap(fields)).statement);
      return true;
    }
    return false;
  }

  /// Generate Body according to @[BodyPart].
  /// Return true if @Field annotations are existed.
  bool _generateBodyParts(List<Code> blocks, MethodElement methodElement) {
    final bodyPartAnnotations = methodElement.getParamAnnotationsByType(http_param.BodyPart);
    if (bodyPartAnnotations.isNotEmpty) {
      final parts = Map.fromEntries(bodyPartAnnotations.map((element) {
        final name = element.second.peek("key")?.stringValue ?? element.first.displayName;
        return MapEntry(literal(name), refer(element.first.displayName));
      }));
      blocks.add(declareFinal(_bodyVar).assign(literalMap(parts)).statement);
      return true;
    }
    return false;
  }

  /// Generate queriesParams according to @[Query].
  /// Return true if @Query annotations are existed.
  bool _generateQueries(List<Code> blocks, MethodElement methodElement) {
    final queriesAnnotation = methodElement.getParamAnnotationsByType(http_param.Query);
    if (queriesAnnotation.isNotEmpty) {
      final queries = _generateValues(queriesAnnotation);
      blocks.add(declareFinal(_queriesVar).assign(literalMap(queries)).statement);
      return true;
    }
    return false;
  }

  /// Read the annotations and get its value.
  Map<Expression, Reference> _generateValues(List<_Pair<ParameterElement, ConstantReader>> annotations) {
    return Map.fromEntries(annotations.map((element) {
      final name = element.second.peek("key")?.stringValue ?? element.first.displayName;
      return MapEntry(literal(name), refer(element.first.displayName));
    }));
  }

  void _buildHttpApi(List<Code> blocks, Iterable<Expression> positionalArguments,
      Map<String, Expression> namedArguments, DartType type, DartType innerType) {
    if (!_typeChecker(HttpApi).isExactlyType(type)) {
      throw InvalidGenerationSourceError("A HttpApi should return ${HttpApi.className}",
          todo: "Wrap type with ${HttpApi.className}");
    }
    final typeArguments = [refer(innerType.getDisplayString(withNullability: true))];
    final httpApi =
        refer(HttpApi.className).newInstance(positionalArguments, namedArguments, typeArguments).returned.statement;
    blocks.add(httpApi);
  }

  /// From Json
  Expression? _buildFromJson(MethodElement methodElement, String className, DartType responseType) {
    final function =
        methodElement.getAnnotationByType(http_param.FromJson)?.peek("fromJson")?.objectValue.toFunctionValue();
    if (function != null) {
      final functionName = function.displayName;
      if (function.enclosingElement.displayName.isEmpty) {
        // top-level function
        return CodeExpression(Code("(data)=>$functionName(data)"));
      } else {
        // class member static function
        return CodeExpression(Code("(data)=>$className.$functionName(data)"));
      }
    }
    if (responseType.isVoid || responseType.isDynamic || _TypeHelper.isBasicType(responseType)) {
      return null;
    }
    final typeNullable = responseType.nullabilitySuffix == NullabilitySuffix.question;
    final typeNullablePrefix = typeNullable ? "data == null ? null :" : "";

    decodeByType(DartType type, String key) {
      final nullable = type.nullabilitySuffix == NullabilitySuffix.question;
      final nullableSuffix = nullable ? "" : "!";
      if (type.isDynamic){
        return "$key$nullableSuffix";
      }
      if (_TypeHelper.isBasicType(type)){
        return "$key$nullableSuffix as ${type.getDisplayString(withNullability: nullable)}";
      }
      return "${type.getDisplayString(withNullability: false)}.fromJson($key$nullableSuffix)";
    }

    String fromJsonString;
    if (_TypeHelper.isList(responseType)) {
      // List<?>
      final innerType = _TypeHelper.getInnerType(responseType)!;
      fromJsonString = "(data)=>$typeNullablePrefix (data as List).map((e)=>${decodeByType(innerType, "e")}).toList()";
    } else if (_TypeHelper.isMap(responseType)) {
      // Map
      return null;
    } else {
      // Object
      fromJsonString = "(data)=>$typeNullablePrefix ${decodeByType(responseType, "data")}";
    }
    return CodeExpression(Code(fromJsonString));
  }
}

TypeChecker _typeChecker(Type type) => TypeChecker.fromRuntime(type);

ConstantReader? _getAnnotationByType(Element element, Type type) {
  final annotation = _typeChecker(type).firstAnnotationOf(element, throwOnUnresolved: false);
  if (annotation != null) return ConstantReader(annotation);
  return null;
}

extension _MethodElementExt on MethodElement {
  ConstantReader? getAnnotationByType(Type type) {
    return _getAnnotationByType(this, type);
  }

  List<_Pair<ParameterElement, ConstantReader>> getParamAnnotationsByType(Type type) {
    final paramAnnotations = <_Pair<ParameterElement, ConstantReader>>[];
    for (final p in parameters) {
      final e = _getAnnotationByType(p, type);
      if (e != null) {
        paramAnnotations.add(_Pair(p, e));
      }
    }
    return paramAnnotations;
  }

  _Pair<ParameterElement, ConstantReader>? getParamAnnotationByType(Type type) {
    for (final p in parameters) {
      final e = _getAnnotationByType(p, type);
      if (e != null) {
        return _Pair(p, e);
      }
    }
    return null;
  }

  ConstantReader? getRequestMethodAnnotation() {
    for (final type in http_method.requestMethods) {
      final reader = getAnnotationByType(type);
      if (reader != null) return reader;
    }
    return null;
  }
}

class _Pair<F, S> {
  F first;
  S second;

  _Pair(this.first, this.second);
}

class _TypeHelper {
  static DartType? getInnerType(DartType type) {
    return type is InterfaceType && type.typeArguments.isNotEmpty ? type.typeArguments.first : null;
  }

  static bool isList(DartType type) {
    return _typeChecker(List).isExactlyType(type) || _typeChecker(BuiltList).isExactlyType(type);
  }

  static bool isMap(DartType type) {
    return _typeChecker(Map).isExactlyType(type) || _typeChecker(BuiltMap).isExactlyType(type);
  }

  static bool isBasicType(DartType type) {
    return _typeChecker(String).isExactlyType(type) ||
        _typeChecker(bool).isExactlyType(type) ||
        _typeChecker(int).isExactlyType(type) ||
        _typeChecker(double).isExactlyType(type) ||
        _typeChecker(num).isExactlyType(type);
  }
}
