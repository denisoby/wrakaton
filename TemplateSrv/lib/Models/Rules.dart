library template_srv.models.rules;
import 'package:embla_trestle/embla_trestle.dart';

class Rule extends Model {
  @field int id;
  @field String state_name;
  @field List actions;

  Map toJson() {
    return {
      'id' : id,
      'state_name' : state_name,
      'actions' : actions
    };
  }
}
