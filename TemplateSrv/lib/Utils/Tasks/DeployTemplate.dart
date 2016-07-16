library template_srv.utils.tasks.deploy;
import 'dart:async';
import 'package:tasks/tasks.dart';
import 'package:srv_base/Utils/Utils.dart';
import 'package:template_srv/Models/Template.dart';
import 'package:template_srv/Models/TemplateRequest.dart';
import 'package:template_srv/Storage/IStorage.dart';

import 'Projects.dart';
import 'Tasks.dart';

class DeployTemplate extends Task {
  final Template base;
  TemplateRequest request;
  IStorage _storage = Utils.$(IStorage);
  DeployTemplate(this.base, this.request);

  Future<String> _create(Template el) async {
    switch (base.TType) {
      case TemplateType.PROJECT :
      {
        CreateProjectParams params = new CreateProjectParams()
          ..title = base.Title
          ..description = base.Description;
        CreateProject action = new CreateProject(params);
        return await action.execute();
      } break;
      case TemplateType.TASK :
      {
        CreateTaskParams params = new CreateTaskParams()
          ..title = base.Title
          ..description = base.Description;
        CreateTask action = new CreateTask(params);
        return await action.execute();
      } break;
    }
    return new Future.error(new ArgumentError('bad template type'));
  }

  Future _handleNested(Template template, String baseId) async {
    await for(Template el in TemplateUtils.getNested(template)) {
      String entityId = await _create(el);
      request.nested_templates.add(entityId);

      if(template.type == TemplateType.PROJECT) {
        await _storage.addSubTaskForProject(baseId, entityId);
      } else if (template.type == TemplateType.TASK) {
        await _storage.addSubTaskForTask(baseId, entityId);
      }
    }
  }

  @override
  Future performWork() async {
    String baseId = await _create(base);
    await _handleNested(base, baseId);
    await TemplateRequestUtils.getTemplateRequest().save(request);
  }
}
