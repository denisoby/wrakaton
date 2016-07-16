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

  @override
  Future performWork() async {
    String baseId = null;
    switch (base.TType) {
      case TemplateType.PROJECT :
      {
        CreateProjectParams params = new CreateProjectParams()
          ..title = base.Title
          ..description = base.Description;
        CreateProject action = new CreateProject(params);
        baseId = await action.execute();
      }
        break;
      case TemplateType.TASK :
      {
        CreateTaskParams params = new CreateTaskParams()
          ..title = base.Title
          ..description = base.Description;
        CreateTask action = new CreateTask(params);
        baseId = await action.execute();
      }
        break;
    }
    print("!!!!!!!!!!!!11 ${baseId}");
  }
}
