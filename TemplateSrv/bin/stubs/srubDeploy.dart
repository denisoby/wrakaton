import 'dart:async';
import 'package:embla/application.dart';
import 'package:embla/http.dart';
import 'package:embla_trestle/embla_trestle.dart';
import 'package:srv_base/Utils/Utils.dart';
import 'package:srv_base/Utils/Crypto.dart' as crypto;
import 'package:template_srv/Models/Template.dart';
import 'package:template_srv/Services/UsersService.dart' show User, UserGroup;
import 'dart:convert';
import 'package:template_srv/Services/StorageService.dart';

class SubDeploy extends Bootstrapper {
  static List defWorkflow =  [
     { 'state_name' : 'New', 'to_states' : [1, 2],
       'enter_actions' : [],
       'leave_actions' : []
     },
     { 'state_name' : 'In progress', 'to_states' : [0, 2, 3],
       'enter_actions' : [],
       'leave_actions' : []
     },
     { 'state_name' : 'Wait', 'to_states' : [1],
       'enter_actions' : [],
       'leave_actions' : []
     },
     { 'state_name' : 'Done', 'to_states' : [0],
       'enter_actions' : [],
       'leave_actions' : []
     },
  ];

  final Gateway gateway;
  Repository<User> _users;
  Repository<Template> _templates;
  Repository<Record> _records;

  SubDeploy(this.gateway);

  @Hook.init
  init() {
    _users = new Repository<User>(gateway);
    _templates = new Repository<Template>(gateway);
    _records = new Repository<Record>(gateway);
    createTasksData();
    createStubUser();
    createFormData();
    createStub_Article_Templates();
    createStub_ItHelpdesk_Templates();
    createStub_HR_welcome_Templates();
  }

  Future<int> createTemplate(String header,
                             String description,
                             String type,
                             String refName,
                             List<String> assignee,
                             List<int> nested,
                             List workflow,
                             [String placeId = null]) {
    Map template = {
      'title' : header,
      'description' : description,
      'type' : type,
      'ref_name' : refName,
      'place' : placeId,
      'assignee' : JSON.encode(assignee),
      'nested' : JSON.encode(nested),
      'workflow' : JSON.encode(workflow)
    };
    return _createTemplate(template);
  }

  Future<int> _createTemplate(Map params) async {
    Template template = new Template()
      ..enabled = true
      ..TType = TemplateType.fromStr(params['type'])
      ..ref_name = params['ref_name']
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
    return template.id;
  }

  createStubUser() async {
    User user = new User()
      ..email = "wrakatoner@team.wrike.com"
      ..password =  crypto.encryptPassword('wrakaton')
      ..enabled = true
      ..group = UserGroup.toStr(UserGroup.USER)
      ..data = {}
      ..settings = {};
    _users.save(user);
  }

  createFormData() async {
    {
      Record item = new Record()
        ..entity_id = 28481
        ..type = RecordType.FORMS.toInt()
        ..data = { 'taskFormId' : 28481, 'templateId' : 5};
      await _records.save(item);
    }
    {
      Record item = new Record()
        ..entity_id = 28483
        ..type = RecordType.FORMS.toInt()
        ..data = { 'taskFormId' : 28483, 'templateId' : 11};
      await _records.save(item);
    }
    {
      Record item = new Record()
        ..entity_id = 28482
        ..type = RecordType.FORMS.toInt()
        ..data = { 'taskFormId' : 28482, 'templateId' : 12};
      await _records.save(item);
    }
  }

  createTasksData() async {
    {
      Record item = new Record()
        ..entity_id = 1
        ..type = RecordType.TASKS.toInt()
        ..data = {
          'wroot_id' : 1,
          'wid' : 1,
          'tmpl_root' : 11,
          'tmpl_sub' : 11,
          'tmpl_root_ref_name' : 'arcticle',
          'tmpl_sub_ref_name' : 'arcticle'
        };
      await _records.save(item);
    }
    {
      Record item = new Record()
        ..entity_id = 2
        ..type = RecordType.TASKS.toInt()
        ..data = {
          'wroot_id' : 1,
          'wid' : 2,
          'tmpl_root' : 11,
          'tmpl_sub' : 1,
          'tmpl_root_ref_name' : 'arcticle',
          'tmpl_sub_ref_name' : 'collect'
        };
      await _records.save(item);
    }
    {
      Record item = new Record()
        ..entity_id = 3
        ..type = RecordType.TASKS.toInt()
        ..data = {
          'wroot_id' : 1,
          'wid' : 3,
          'tmpl_root' : 11,
          'tmpl_sub' : 4,
          'tmpl_root_ref_name' : 'arcticle',
          'tmpl_sub_ref_name' : 'content'
        };
      await _records.save(item);
    }
    {
      Record item = new Record()
        ..entity_id = 4
        ..type = RecordType.TASKS.toInt()
        ..data = {
          'wroot_id' : 1,
          'wid' : 4,
          'tmpl_root' : 11,
          'tmpl_sub' : 7,
          'tmpl_root_ref_name' : 'arcticle',
          'tmpl_sub_ref_name' : 'makeup'
        };
      await _records.save(item);
    }
    {
      Record item = new Record()
        ..entity_id = 5
        ..type = RecordType.TASKS.toInt()
        ..data = {
          'wroot_id' : 1,
          'wid' : 5,
          'tmpl_root' : 11,
          'tmpl_sub' : 9,
          'tmpl_root_ref_name' : 'arcticle',
          'tmpl_sub_ref_name' : 'publish'
        };
      await _records.save(item);
    }
  }

  createStub_Article_Templates() async {
    List<int> nested = [
    await _createTemplate({
      'title' : 'Collect data: %title%',
      'description' : '<h3>Please collect the data for the following article</h3><p>Title:<b>%title%</b></p><p>%brief%</p>',
      'type' : 'TASK',
      'ref_name' : 'collect',
      'place' : '',
      'assignee' : JSON.encode(['%analyst%']),
      'nested' : JSON.encode([]),
      'workflow' : JSON.encode([
        { /* 0 */
          'state_name': "New", 'to_states': [ 1 ],
          'enter_actions': [], 'leave_actions': [ ]
        },
        { /* 1 */
          'state_name': "Collecting data", 'to_states': [ 2 ],
          'enter_actions': [
                      /*----ref_name------*/
            {'path' : ['article', 'collect'], 'action' : { 'name' : 'unassign', 'data' : null} },
            {'path' : ['article', 'collect'], 'action' : { 'name' : 'assign', 'data' : '%analyst%'} }
          ], 'leave_actions': [ ]
        },
        { /* 2 */
          'state_name': "Data in review", 'to_states': [ 1, 3 ],
          'enter_actions': [
            {'path' : ['article', 'collect'], 'action' : { 'name' : 'unassign', 'data' : null} },
            {'path' : ['article', 'collect'], 'action' : { 'name' : 'assign', 'data' : '%author%'} }
           ], 'leave_actions': [ ]
        },
        { /* 3 */
          'state_name': "Completed", 'to_states': [],
          'enter_actions': [
            {'path' : ['article', 'collect'], 'action' : { 'name' : 'unassign', 'data' : null} },
            {'path' : ['article', 'collect'], 'action' : { 'name' : 'assign', 'data' : '%analyst%'} },
            {'path' : ['article', 'content'], 'action' : { 'name' : 'assign', 'data' : '%author%'} },
            {'path' : ['article', 'content'], 'action' : { 'name' : 'status', 'data' : 'New'} }
          ], 'leave_actions': [ ]
        }
      ])
    }),
    await _createTemplate({
      'title' : 'Content %title%',
      'description' : '<h3>Please write content for the article</h3><p>Title:<b>%title%</b></p><p>%brief%</p>',
      'type' : 'TASK',
      'ref_name' : 'content',
      'place' : '',
      'assignee' : JSON.encode([]),
      'nested' : JSON.encode([]),
      'workflow' : JSON.encode([
        { /* 0 */
          'state_name': "Waiting for other tasks", 'to_states': [ 1 ],
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 1 */
          'state_name': "New", 'to_states': [ 2 ],
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 2 */
          'state_name': "Content creation", 'to_states': [ 3 ],
          'enter_actions': [
            {'path' : ['article', 'content'], 'action' : { 'name' : 'unassign', 'data' : null} },
            {'path' : ['article', 'content'], 'action' : { 'name' : 'assign', 'data' : '%author%'} }
          ], 'leave_actions': [ ]
        },
        { /* 3 */
          'state_name': "Content in review", 'to_states': [ 2, 4 ],
          'enter_actions': [
            {'path' : ['article', 'content'], 'action' : { 'name' : 'unassign', 'data' : null} },
            {'path' : ['article', 'content'], 'action' : { 'name' : 'assign', 'data' : '%editor%'} }
          ], 'leave_actions': [ ]
        },
        { /* 4 */
          'state_name': "Completed", 'to_states': [],
          'enter_actions': [
            {'path' : ['article', 'content'], 'action' : { 'name' : 'unassign', 'data' : null} },
            {'path' : ['article', 'content'], 'action' : { 'name' : 'assign', 'data' : '%author%'} },
            {'path' : ['article', 'makeup'], 'action' : { 'name' : 'assign', 'data' : '%designer%'} },
            {'path' : ['article', 'makeup'], 'action' : { 'name' : 'status', 'data' : 'New'} }
          ], 'leave_actions': [ ]
        }
      ])
    }),
    await _createTemplate({
      'title' : 'Make-up %title%',
      'description' : '<h3>Please design the make-up for the new article</h3><p>Title:<b>%title%</b></p><p>%brief%</p>',
      'type' : 'TASK',
      'ref_name' : 'makeup',
      'place' : '',
      'assignee' : JSON.encode([]),
      'nested' : JSON.encode([]),
      'workflow' : JSON.encode([
        { /* 0 */
          'state_name': "Waiting for other tasks", 'to_states': [ 1 ],
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 1 */
          'state_name': "New", 'to_states': [ 2 ],
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 2 */
          'state_name': "Design in progress", 'to_states': [ 3 ],
          'enter_actions': [
            {'path' : ['article', 'makeup'], 'action' : { 'name' : 'unassign', 'data' : null} },
            {'path' : ['article', 'makeup'], 'action' : { 'name' : 'assign', 'data' : '%designer%'} }
          ], 'leave_actions': [ ]
        },
        { /* 3 */
          'state_name': "Design in review", 'to_states': [ 2, 4 ],
          'enter_actions': [
            {'path' : ['article', 'makeup'], 'action' : { 'name' : 'unassign', 'data' : null} },
            {'path' : ['article', 'makeup'], 'action' : { 'name' : 'assign', 'data' : '%editor%'} }
          ], 'leave_actions': [ ]
        },
        { /* 4 */
          'state_name': "Final review", 'to_states': [ 2, 5 ],
          'enter_actions': [
            {'path' : ['article', 'makeup'], 'action' : { 'name' : 'unassign', 'data' : null} },
            {'path' : ['article', 'makeup'], 'action' : { 'name' : 'assign', 'data' : '%creativeId%'} }
          ], 'leave_actions': [ ]
        },
        { /* 5 */
          'state_name': "Completed", 'to_states': [],
          'enter_actions': [
            {'path' : ['article', 'makeup'], 'action' : { 'name' : 'unassign', 'data' : null} },
            {'path' : ['article', 'makeup'], 'action' : { 'name' : 'assign', 'data' : '%designer%'} },
            {'path' : ['article', 'publish'], 'action' : { 'name' : 'assign', 'data' : '%publisher%'} },
            {'path' : ['article', 'publish'], 'action' : { 'name' : 'status', 'data' : 'New'} }
          ], 'leave_actions': [ ]
        }
      ])
    }),
    await _createTemplate({
      'title' : 'Publish %title%',
      'description' : '<h3>Please publish the article</h3><p>Title:<b>%title%</b></p>',
      'type' : 'TASK',
      'ref_name' : 'publish',
      'place' : '',
      'assignee' : JSON.encode([]),
      'nested' : JSON.encode([]),
      'workflow' : JSON.encode([
        { /* 0 */
          'state_name': "Waiting for other tasks", 'to_states': [ 1 ],
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 1 */
          'state_name': "New", 'to_states': [ 2 ],
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 2 */
          'state_name': "Publishing", 'to_states': [ 3 ],
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 3 */
          'state_name': "Waiting for response", 'to_states': [ 4 ],
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 4 */
          'state_name': "Completed", 'to_states': [],
          'enter_actions': [ ], 'leave_actions': [ ]
        }
      ])
    })
    ];
    await createTemplate('Article creation %title%',
      '', 'PROJECT', 'arcticle', [], nested, defWorkflow, 'megaTeemId');
  }

  createStub_ItHelpdesk_Templates() async {
    await _createTemplate({
      'title' : 'Ticket: %title%',
      'description' : '%description%',
      'type' : 'TASK',
      'ref_name' : 'ticket',
      'place' : '',
      'assignee' : JSON.encode([]),
      'nested' : JSON.encode([]),
      'workflow' : JSON.encode([
        { /* 0 */
          'state_name': "New", 'to_states': [ 1, 2 ],
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 1 */
          'state_name': "In progress", 'to_states': [ 2, 5 ],
          'enter_actions': [
            {'path' : ['helpdesk', 'ticket'], 'action' : { 'name' : 'unassign', 'data' : null} },
            {'path' : ['helpdesk', 'ticket'], 'action' : { 'name' : 'assign', 'data' : '%engineer%'} }
          ], 'leave_actions': [ ]
        },
        { /* 2 */
          'state_name': "Waiting for approval", 'to_states': [ 3, 4 ],
          'enter_actions': [
            {'path' : ['helpdesk', 'ticket'], 'action' : { 'name' : 'unassign', 'data' : null} },
            {'path' : ['helpdesk', 'ticket'], 'action' : { 'name' : 'assign', 'data' : '%approver%'} }
          ], 'leave_actions': [ ]
        },
        { /* 3 */
          'state_name': "In progress - approved", 'to_states': [ 5 ],
          'enter_actions': [
            {'path' : ['helpdesk', 'ticket'], 'action' : { 'name' : 'unassign', 'data' : null} },
            {'path' : ['helpdesk', 'ticket'], 'action' : { 'name' : 'assign', 'data' : '%engineer%'} }
          ], 'leave_actions': [ ]
        },
        { /* 4 */
          'state_name': "Rejected", 'to_states': [ ],
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 5 */
          'state_name': "Completed", 'to_states': [],
          'enter_actions': [ ], 'leave_actions': [ ]
        }
      ])
    });
  }

  createStub_HR_welcome_Templates() async {
    List<int> nested = [
    await _createTemplate({
      'title' : 'Workspace preparation: %name%',
      'description' : 'Please prepare standard equipment set for the new employee.',
      'type' : 'TASK',
      'ref_name' : 'it',
      'place' : '',
      'assignee' : JSON.encode(['%engineer%']),
      'nested' : JSON.encode([]),
      'workflow' : JSON.encode([
        { /* 0 */
          'state_name': "New", 'to_states': [ 1 ],
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 1 */
          'state_name': "In progress", 'to_states': [ 2 ],
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 2 */
          'state_name': "Completed", 'to_states': [ ],
          'enter_actions': [ ], 'leave_actions': [ ]
        }
      ])
    }),
    await _createTemplate({
      'title' : 'HR onboarding: %name%',
      'description' : 'Please prepare and sign all necessary documents for the new employee.',
      'type' : 'TASK',
      'ref_name' : 'docs',
      'place' : '',
      'assignee' : JSON.encode(['%manager%']),
      'nested' : JSON.encode([]),
      'workflow' : JSON.encode([
        { /* 0 */
          'state_name': "New", 'to_states': [ 1 ],
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 1 */
          'state_name': "In progress", 'to_states': [ 2 ],
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 2 */
          'state_name': "Completed", 'to_states': [ ],
          'enter_actions': [ ], 'leave_actions': [ ]
        }
      ])
    }),
    await _createTemplate({
      'title' : 'Buddy adoption: %name%',
      'description' : 'There is a new guy in your department. Please help him adopt better!',
      'type' : 'TASK',
      'ref_name' : 'buddy',
      'place' : '',
      'assignee' : JSON.encode(['%buddy%']),
      'nested' : JSON.encode([]),
      'workflow' : JSON.encode([
        { /* 0 */
          'state_name': "New", 'to_states': [ 1 ],
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 1 */
          'state_name': "In progress", 'to_states': [ 2 ],
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 2 */
          'state_name': "Collecting feedback", 'to_states': [ 3 ],
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 3 */
          'state_name': "Completed", 'to_states': [],
          'enter_actions': [ ], 'leave_actions': [ ]
        }
      ])
    }),
    ];
    await createTemplate('Welcome onboarding %name%',
      '', 'PROJECT', 'hr', [], nested, defWorkflow, 'megaTeemId');
  }

}
