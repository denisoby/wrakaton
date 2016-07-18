library template_srv.models.template;
import 'dart:async';
import 'package:di/type_literal.dart';
import 'package:embla_trestle/embla_trestle.dart';
import 'package:srv_base/Srv.dart';
import 'package:template_srv/Models/Rule.dart';

class TemplateType {
  final _value;
  const TemplateType._internal(this._value);
  String get Str => _value;
  toString() => '$_value';
  toInt() => values.indexOf(this);

  static TemplateType fromInt(int ind) => values[ind];
  static TemplateType fromStr(String val)
    => values.firstWhere((TemplateType el) => el._value == val);

  static const TASK = const TemplateType._internal('TASK');
  static const PROJECT = const TemplateType._internal('PROJECT');
  static const FOLDER = const TemplateType._internal('FOLDER');

  static final List<TemplateType> values = [
    TemplateType.TASK,
    TemplateType.PROJECT,
    TemplateType.FOLDER
  ];
}

class Template extends Model {
  @field int id;
  @field bool enabled;
  @field int type;
  @field List nested;
  @field Map data;

  TemplateType get TType => TemplateType.fromInt(type);
  set TType(TemplateType val) { type = val.toInt(); }

  String get Title => data['title'];
  String get Description => data['description'];
  List get Assignee => data['assignee'];
  List<Rule> get Workflow {
    return (data["workflow"] as List).map((Map el) => new Rule.fromMap(el));
  }

  Map toJson() {
    return {
      'id' : id,
      'enabled' : enabled,
      'type' : TType.toString(),
      'data' : data,
      'nested' : nested
    };
  }
}

class TemplateUtils {
  static Repository<Template> getTemplates() {
    return Utils.$(new TypeLiteral<Repository<Template>>().type);
  }

  static Stream<Template> getNested(Template base) {
    if(base.nested.isEmpty) return new Stream.empty();
    return getTemplates().where((el) => base.nested.contains(el.id)).get();
  }

  static Future<Map> deepSerialize(Template template) async {
    final String key = 'nested';
    Map ret = template.toJson();
    ret[key] = [];
    await for(Template el in getNested(template)) {
        Map elRepr = await deepSerialize(el);
        (ret[key] as List).add(elRepr);
    }
    return ret;
  }
}
