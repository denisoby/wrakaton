library template_srv.services.rules_servcie;

import 'dart:convert';
import 'package:embla/http.dart';
import 'package:embla/http_annotations.dart';
import 'package:embla_trestle/embla_trestle.dart';

import 'package:srv_base/Middleware/input_parser/input_parser.dart';
import 'package:srv_base/Utils/Utils.dart';
import 'package:srv_base/Utils/QueryLimit.dart';
import '../Models/Rule.dart';

class RulesService extends Controller with QueryLimit {
  final Repository<Rule> rules;

  RulesService(this.rules);

  @Post('/') create(Input args) async {
    Map params = args.body;
    if(expect(params, 'state_name') &&
       expect(params, 'actions'))
    {
      Rule rule = new Rule()
        ..state_name = params['state_name'];
      await rules.save(rule);
      return {'msg' : 'ok', 'id' : rule.id};
    } else {
      this.abortBadRequest('wrong data');
    }
  }

  @Get('/') getAll(Input args) {
    Map params = args.body;
    RepositoryQuery<Rule> query = rules.where((el) => true);
    if(params.containsKey('count')) {
      final int count = int.parse(params['count']);
      if(params.containsKey('page')) {
        final int page = int.parse(params['page']);
        query = limit(query, count, page);
      } else {
        query = limit(query, count);
      }
    }
    return query.get().toList();
  }

  @Get('/:id') getRule(Input args, {String id}) {
    Map params = args.body;
    return rules.find(int.parse(id));
  }

}
