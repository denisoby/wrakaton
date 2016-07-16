library template_srv.utils.tasks.deploy;
import 'dart:async';
import 'package:tasks/tasks.dart';
import 'package:srv_base/Utils/Utils.dart';
import 'package:template_srv/Models/Template.dart';
import 'package:template_srv/Storage/IStorage.dart';

import 'Projects.dart';
import 'Tasks.dart';

class DeployTemplate extends Task {
  final Template base;
  DeployTemplate(this.base);

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
  }

  @override
  Future performWork() async {
    String baseId = await _create(base);
    if(base.nested.isNotEmpty) {
      
    }
  }
}
