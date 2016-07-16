library template_srv.utils.tasks.domain_projects;
import 'dart:async';
import 'package:srv_base/Utils/Utils.dart';
import 'package:tasks/tasks.dart';

import '../../Storage/IStorage.dart';

class CreateProjectParams {
  String title;
  String description;
}

class CreateProject extends Task {
  IStorage _storage = Utils.$(IStorage);
  CreateProjectParams params;
  CreateProject(this.params);

  @override
  Future performWork() {
    Map params = {
      'title' : this.params.title,
      'description' : this.params.description
    };
    return _storage.createProject(params);
  }
}
