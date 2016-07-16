library template_srv.models.task_template;
import 'dart:async';
import 'package:embla_trestle/embla_trestle.dart';

class Template extends Model {
  @field int id;
  @field bool enabled;
  @field List nested;
  @field Map config;

  Map toJson() {
    return {
      'id' : id,
      'enabled' : enabled,
      'nested' : nested,
      'config' : config
    };
  }
}
