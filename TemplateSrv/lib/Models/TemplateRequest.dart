library template_srv.models.template.requst;
import 'package:embla_trestle/embla_trestle.dart';

class TemplateRequest extends Model {
  @field int id;
  @field int user_id;
  @field int base_template_id;
  @field List nested_templates;
  @field Map data;

  Map toJson() {
    return {
      'id' : id,
      'user_id' : user_id,
      'base_template_id' : base_template_id,
      'nested_templates' : nested_templates,
      'data' : data
    };
  }
}
