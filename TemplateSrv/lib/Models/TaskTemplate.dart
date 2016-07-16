library template_srv.models.task_template;
import 'dart:async';
import 'package:embla_trestle/embla_trestle.dart';

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
