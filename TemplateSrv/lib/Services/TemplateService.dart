library template_srv.services.template_servcie;

import 'dart:convert';
import 'package:embla/http.dart';
import 'package:embla/http_annotations.dart';
import 'package:embla_trestle/embla_trestle.dart';

import 'package:srv_base/Utils/Utils.dart';
import 'package:srv_base/Utils/QueryLimit.dart';
import '../Models/TaskTemplate.dart';
import 'package:srv_base/Middleware/input_parser/input_parser.dart';

class TemplateService extends Controller with QueryLimit {
  final Repository<TaskTemplate> taskTemplates;

  TemplateService(this.taskTemplates);

  @Post('/') create(Input args) async {
    Map params = args.body;
    if(expect(params, 'header') &&
       expect(params, 'description'))
    {
      TaskTemplate template = new TaskTemplate()
        ..enabled = true
        ..config = {
          'header' : params['header'],
          'description' : params['description']
        };
      if(params.containsKey('nested')) {
        template.nested = JSON.decode(params['nested']);
      }
      await taskTemplates.save(template);
      return {'msg' : 'ok', 'id' : template.id};
    } else {
      this.abortBadRequest('wrong data');
    }
  }

  @Get('/') getAll(Input args) {
    Map params = args.body;
    RepositoryQuery<TaskTemplate> query =
      taskTemplates.where((el) => el.enabled == true);
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

  @Get('/:id') getTemplate({String id}) {
    return taskTemplates.find(int.parse(id));
  }

  @Put('/:id/nested') addNested(Input args, {String id}) async {
      Map params = args.body;
      if(expect(params, 'items')) {
        List items = JSON.decode(params['items']);
        RepositoryQuery<TaskTemplate> query =
          taskTemplates.where((el) => items.contains(el.id));
        int count = await query.count();
        if(count == items.length) {
          TaskTemplate template = await getTemplate(id : id);
          template.nested = items;
          await taskTemplates.save(template);
        }
      }
      return {'msg' : 'ok'};
  }

}
