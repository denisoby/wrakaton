library template_srv.services.template_servcie;

import 'dart:convert';
import 'package:embla/http.dart';
import 'package:embla/http_annotations.dart';
import 'package:embla_trestle/embla_trestle.dart';

import 'package:srv_base/Middleware/input_parser/input_parser.dart';
import 'package:srv_base/Utils/Utils.dart';
import 'package:srv_base/Utils/QueryLimit.dart';
import '../Models/Template.dart';

class TemplateService extends Controller with QueryLimit {
  final Repository<Template> templates;

  TemplateService(this.templates);

  @Post('/') create(Input args) async {
    Map params = args.body;
    if(expect(params, 'type') &&
       expect(params, 'title') &&
       expect(params, 'description') &&
       expect(params, 'assignee'))
    {
      Template template = new Template()
        ..enabled = true
        ..TType = TemplateType.fromStr(params['type'])
        ..data = {
          'title' : params['title'],
          'description' : params['description'],
          'assignee' : JSON.decode(params['assignee'])
        };
      if(params.containsKey('nested')) {
        template.nested = JSON.decode(params['nested']);
      } else {
        template.nested = [];
      }
      await templates.save(template);
      return {'msg' : 'ok', 'id' : template.id};
    } else {
      this.abortBadRequest('wrong data');
    }
  }

  @Get('/') getAll(Input args) {
    Map params = args.body;
    RepositoryQuery<Template> query =
      templates.where((el) => el.enabled == true);
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

  @Get('/:id') getTemplate(Input args, {String id}) {
    Map params = args.body;
    if(expect(params, 'deep')) {
      return templates.find(int.parse(id))
        .then((Template el) => TemplateUtils.deepSerialize(el));
    }
    return templates.find(int.parse(id));
  }

  @Put('/:id/nested') addNested(Input args, {String id}) async {
      Map params = args.body;
      if(expect(params, 'items')) {
        List items = JSON.decode(params['items']);
        RepositoryQuery<Template> query =
          templates.where((el) => items.contains(el.id));
        int count = await query.count();
        if(count == items.length) {
          Template template = await getTemplate(args, id : id);
          template.nested = items;
          await templates.save(template);
        }
      }
      return {'msg' : 'ok'};
  }

}
