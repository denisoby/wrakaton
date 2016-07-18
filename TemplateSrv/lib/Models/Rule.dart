library template_srv.models.rules;
import 'package:embla_trestle/embla_trestle.dart';
import 'package:srv_base/Utils/Utils.dart';

class Rule extends Model {
  @field int id;
  @field String state_name;
  @field List to_states;
  @field List enter_actions;
  @field List leave_actions;

  Rule();

  Rule.fromMap(Map params) {
    if(expect(params, 'state_name') &&
       expect(params, 'to_states') &&
       expect(params, 'enter_actions') &&
       expect(params, 'leave_actions'))
    {
      state_name    = params['state_name'];
      to_states     = params['to_states'];
      enter_actions = params['enter_actions'];
      leave_actions = params['leave_actions'];
    } else {
      throw new ArgumentError("wrong params $params");
    }
  }

  Map toJson() {
    return {
      /*'id' : id,*/
      'state_name' : state_name,
      'to_states' : to_states,
      'enter_actions' : enter_actions,
      'leave_actions' : leave_actions
    };
  }
}
