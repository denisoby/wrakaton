library template_srv.utils.tasks.domain_tasks;
import 'dart:async';
import 'package:srv_base/Utils/Utils.dart';
import 'package:tasks/tasks.dart';

import '../../Storage/IStorage.dart';

class CreateTaskParams {
  String title;
  String description;
}

class CreateTask extends Task {

  IStorage _storage = Utils.$(IStorage);
  CreateTaskParams params;
  CreateTask(this.params);

  @override
  Future performWork() {

  }
}
