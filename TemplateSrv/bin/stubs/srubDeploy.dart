import 'dart:async';
import 'package:embla/application.dart';
import 'package:embla/http.dart';
import 'package:embla_trestle/embla_trestle.dart';
import 'package:srv_base/Utils/Utils.dart';
import 'package:srv_base/Utils/Crypto.dart' as crypto;
import 'package:template_srv/Models/Template.dart';
import 'package:template_srv/Services/UsersService.dart' show User, UserGroup;
import 'dart:convert';

class SubDeploy extends Bootstrapper {
  final Gateway gateway;
  Repository<User> _users;
  Repository<Template> _templates;

  SubDeploy(this.gateway);

  @Hook.init
  init() {
    _users = new Repository<User>(gateway);
    _templates = new Repository<Template>(gateway);
    createStubUser();
    createStubTemplates();
  }

  createTemplate(String header,
                 String description,
                 String type,
                 List<String> assignee,
                 Map workflow) {
    Map template = {
      'title' : header,
      'description' : description,
      'type' : type,
      'assignee' : JSON.encode(assignee),
      'workflow' : JSON.encode(workflow)
    };
    return _createTemplate(template);
  }

  Future _createTemplate(Map params) async {
    Template template = new Template()
      ..enabled = true
      ..TType = TemplateType.fromStr(params['type'])
      ..data = {
        'title' : params['title'],
        'description' : params['description'],
        'assignee' : JSON.decode(params['assignee']),
        'workflow' : JSON.decode(params['workflow'])
      };
    if(params.containsKey('nested')) {
      template.nested = JSON.decode(params['nested']);
    } else {
      template.nested = [];
    }
    await _templates.save(template);
  }

  createStubUser() async {
    User user = new User()
      ..email = "wrakatoner@team.wrike.com"
      ..password =  crypto.encryptPassword('wrakaton')
      ..enabled = true
      ..group = UserGroup.toStr(UserGroup.USER)
      ..settings = {};
    _users.save(user);
  }

  createStubTemplates() async {
    await createTemplate('base project template',
     'some project template', 'PROJECT', [],
     {
       'new' : { 'state_name' : 'new'},
       'in progress' : {'state_name' : 'in progress'},
       'done' : {'state_name' : 'done'}
     });
  }

}
