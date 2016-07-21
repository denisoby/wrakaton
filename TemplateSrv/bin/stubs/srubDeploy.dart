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
  Future init() async {
    _users = new Repository<User>(gateway);
    _templates = new Repository<Template>(gateway);
    _records = new Repository<Record>(gateway);
  }

  Future deployMain() async {
    await createStubUser();
    await createStub_Article_Templates();
    await createStub_ItHelpdesk_Templates();
    await createStub_HR_welcome_Templates();
    await createStub_Event_Templates();
    await createFormData();
  }

  Future<int> createTemplate(String header,
                             String description,
                             String type,
                             String refName,
                             List<String> assignee,
                             List<String> input_assignee,
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
      'input_assignee' : JSON.encode(input_assignee),
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
        'input_assignee' : JSON.decode(params['input_assignee']),
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
      /*Helpdesk*/
      Template root = await _templates.where((el) => el.ref_name == 'ticket').first();
      Record item = new Record()
        ..entity_id = 28481
        ..type = RecordType.FORMS.toInt()
        ..data = { 'taskFormId' : 28481, 'templateId' : root.id, 'targetFolderId' : 8528910};
      await _records.save(item);
    }
    {
      /*Article*/
      Template root = await _templates.where((el) => el.ref_name == 'article').first();
      Record item = new Record()
        ..entity_id = 28483
        ..type = RecordType.FORMS.toInt()
        ..data = { 'taskFormId' : 28483, 'templateId' : root.id, 'targetFolderId' : 8528913};
      await _records.save(item);
    }
    {
      /*HR*/
      Template root = await _templates.where((el) => el.ref_name == 'hr').first();
      Record item = new Record()
        ..entity_id = 28482
        ..type = RecordType.FORMS.toInt()
        ..data = { 'taskFormId' : 28482, 'templateId' : root.id, 'targetFolderId' : 8528918};
      await _records.save(item);
    }
    {
      /*Event*/
      Template root = await _templates.where((el) => el.ref_name == 'event').first();
      Record item = new Record()
        ..entity_id = 28482
        ..type = RecordType.FORMS.toInt()
        ..data = { 'taskFormId' : 28545, 'templateId' : root.id, 'targetFolderId' : 8558054};
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
      'input_assignee' : JSON.encode(['%analyst%', '%author%']),
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
      'input_assignee' : JSON.encode(['%author%', '%editor%', '%designer%']),
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
      'input_assignee' : JSON.encode(['%designer%', '%editor%', '%creativeId%', '%publisher%']),
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
      'input_assignee' : JSON.encode([]),
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
    await createTemplate('Article: %title%',
      '', 'PROJECT', 'article', [], [], nested, defWorkflow, 'megaTeemId');
  }

  createStub_ItHelpdesk_Templates() async {
    await _createTemplate({
      'title' : 'Ticket: %title%',
      'description' : '%description%',
      'type' : 'TASK',
      'ref_name' : 'ticket',
      'place' : '',
      'assignee' : JSON.encode(['%engineerId%']),
      'input_assignee' : JSON.encode(['%engineerId%', '%creativeId%']),
      'nested' : JSON.encode([]),
      'workflow' : JSON.encode([
        { /* 0 */
          'state_name': "New", 'to_states': [ 1, 2 ],
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 1 */
          'state_name': "In progress", 'to_states': [ 2, 5 ],
          'enter_actions': [
            {'path' : ['ticket'], 'action' : { 'name' : 'unassign', 'data' : null} },
            {'path' : ['ticket'], 'action' : { 'name' : 'assign', 'data' : '%engineerId%'} }
          ], 'leave_actions': [ ]
        },
        { /* 2 */
          'state_name': "Waiting for approval", 'to_states': [ 3, 4 ],
          'enter_actions': [
            {'path' : ['ticket'], 'action' : { 'name' : 'unassign', 'data' : null} },
            {'path' : ['ticket'], 'action' : { 'name' : 'assign', 'data' : '%creativeId%'} }
          ], 'leave_actions': [ ]
        },
        { /* 3 */
          'state_name': "In progress - approved", 'to_states': [ 5 ],
          'enter_actions': [
            {'path' : ['ticket'], 'action' : { 'name' : 'unassign', 'data' : null} },
            {'path' : ['ticket'], 'action' : { 'name' : 'assign', 'data' : '%engineerId%'} }
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
      'input_assignee' : JSON.encode([]),
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
      'input_assignee' : JSON.encode([]),
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
      'input_assignee' : JSON.encode([]),
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
      '', 'PROJECT', 'hr', [], [], nested, defWorkflow, 'megaTeemId');
  }

  createStub_Event_Templates() async {

    List<int> nestedplanning = [
      await _createTemplate({
        'title' : 'Plan the event',
        'description' : 'Plan everything',
        'type' : 'TASK',
        'ref_name' : 'plan1',
        'place' : '',
        'assignee' : JSON.encode(['%event%']),
        'input_assignee' : JSON.encode(['%content%', '%pr%', '%event%','%designer%','%speaker%']),
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
            'enter_actions': [
              {'path' : ['event', 'planning','plan2'], 'action' : { 'name' : 'assign', 'data' : '%content%'} },
              {'path' : ['event', 'planning','plan2'], 'action' : { 'name' : 'status', 'data' : 'In progress'} },
              {'path' : ['event', 'planning','plan3'], 'action' : { 'name' : 'assign', 'data' : '%pr%'} },
              {'path' : ['event', 'planning','plan3'], 'action' : { 'name' : 'status', 'data' : 'In progress'} },
              {'path' : ['event', 'booking','book1'], 'action' : { 'name' : 'assign', 'data' : '%event%'} },
              {'path' : ['event', 'booking','book1'], 'action' : { 'name' : 'status', 'data' : 'In progress'} },
              {'path' : ['event', 'booking','book2'], 'action' : { 'name' : 'assign', 'data' : '%event%'} },
              {'path' : ['event', 'booking','book2'], 'action' : { 'name' : 'status', 'data' : 'In progress'} },
              {'path' : ['event', 'booking','book3'], 'action' : { 'name' : 'assign', 'data' : '%event%'} },
              {'path' : ['event', 'booking','book3'], 'action' : { 'name' : 'status', 'data' : 'In progress'} },
              {'path' : ['event', 'collaterals','coll1'], 'action' : { 'name' : 'assign', 'data' : '%content%'} },
              {'path' : ['event', 'collaterals','coll1'], 'action' : { 'name' : 'status', 'data' : 'In progress'} },
              {'path' : ['event', 'collaterals','coll2'], 'action' : { 'name' : 'assign', 'data' : '%designer%'} },
              {'path' : ['event', 'collaterals','coll2'], 'action' : { 'name' : 'status', 'data' : 'In progress'} },
              {'path' : ['event', 'collaterals','coll3'], 'action' : { 'name' : 'assign', 'data' : '%designer%'} },
              {'path' : ['event', 'collaterals','coll3'], 'action' : { 'name' : 'status', 'data' : 'In progress'} },
              {'path' : ['event', 'collaterals','coll4'], 'action' : { 'name' : 'assign', 'data' : '%designer%'} },
              {'path' : ['event', 'collaterals','coll4'], 'action' : { 'name' : 'status', 'data' : 'In progress'} },
              {'path' : ['event', 'collaterals','coll5'], 'action' : { 'name' : 'assign', 'data' : '%designer%'} },
              {'path' : ['event', 'collaterals','coll5'], 'action' : { 'name' : 'status', 'data' : 'In progress'} },
              {'path' : ['event', 'massmedia','mm1'], 'action' : { 'name' : 'assign', 'data' : '%content%'} },
              {'path' : ['event', 'massmedia','mm1'], 'action' : { 'name' : 'status', 'data' : 'In progress'} },
              {'path' : ['event', 'massmedia','mm2'], 'action' : { 'name' : 'assign', 'data' : '%designer%'} },
              {'path' : ['event', 'massmedia','mm2'], 'action' : { 'name' : 'status', 'data' : 'In progress'} },
              {'path' : ['event', 'massmedia','mm3'], 'action' : { 'name' : 'assign', 'data' : '%pr%'} },
              {'path' : ['event', 'massmedia','mm3'], 'action' : { 'name' : 'status', 'data' : 'In progress'} },
              {'path' : ['event', 'massmedia','mm4'], 'action' : { 'name' : 'assign', 'data' : '%event%'} },
              {'path' : ['event', 'massmedia','mm4'], 'action' : { 'name' : 'status', 'data' : 'In progress'} },
              {'path' : ['event', 'presskit','kit1'], 'action' : { 'name' : 'assign', 'data' : '%content%'} },
              {'path' : ['event', 'presskit','kit1'], 'action' : { 'name' : 'status', 'data' : 'In progress'} },
              {'path' : ['event', 'presskit','kit2'], 'action' : { 'name' : 'assign', 'data' : '%event%'} },
              {'path' : ['event', 'presskit','kit2'], 'action' : { 'name' : 'status', 'data' : 'In progress'} },
              {'path' : ['event', 'presskit','kit3'], 'action' : { 'name' : 'assign', 'data' : '%event%'} },
              {'path' : ['event', 'presskit','kit3'], 'action' : { 'name' : 'status', 'data' : 'In progress'} },
              {'path' : ['event', 'speakers','spk1'], 'action' : { 'name' : 'assign', 'data' : '%speaker%'} },
              {'path' : ['event', 'speakers','spk1'], 'action' : { 'name' : 'status', 'data' : 'In progress'} },
              {'path' : ['event', 'speakers','spk2'], 'action' : { 'name' : 'assign', 'data' : '%content%'} },
              {'path' : ['event', 'speakers','spk2'], 'action' : { 'name' : 'status', 'data' : 'In progress'} },
              {'path' : ['event', 'speakers','spk3'], 'action' : { 'name' : 'assign', 'data' : '%speaker%'} },
              {'path' : ['event', 'speakers','spk3'], 'action' : { 'name' : 'status', 'data' : 'In progress'} },

            ], 'leave_actions': [ ]
          }
        ])
      }),
      await _createTemplate({
        'title' : 'Prepare scenario',
        'description' : 'Write the event scenario',
        'type' : 'TASK',
        'ref_name' : 'plan2',
        'place' : '',
        'assignee' : JSON.encode(['%content%']),
        'input_assignee' : JSON.encode(['%content%', '%pr%', '%event%','%designer%','%speaker%']),
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
        'title' : 'Invitations list',
        'description' : 'Collect mass media list to invite',
        'type' : 'TASK',
        'ref_name' : 'plan3',
        'place' : '',
        'assignee' : JSON.encode(['%buddy%']),
        'input_assignee' : JSON.encode(['%content%', '%pr%', '%event%','%designer%','%speaker%']),
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
            'state_name': "Completed", 'to_states': [],
            'enter_actions': [ ], 'leave_actions': [ ]
          }
        ])
      }),
    ];

    List<int> nestedbooking = [
      await _createTemplate({
        'title' : 'Conference hall',
        'description' : '',
        'type' : 'TASK',
        'ref_name' : 'book1',
        'place' : '',
        'assignee' : JSON.encode([]),
        'input_assignee' : JSON.encode(['%content%', '%pr%', '%event%','%designer%','%speaker%']),
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
        'title' : 'Photo shooting',
        'description' : '',
        'type' : 'TASK',
        'ref_name' : 'book2',
        'place' : '',
        'assignee' : JSON.encode([]),
        'input_assignee' : JSON.encode(['%content%', '%pr%', '%event%','%designer%','%speaker%']),
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
        'title' : 'Equipment',
        'description' : '',
        'type' : 'TASK',
        'ref_name' : 'book3',
        'place' : '',
        'assignee' : JSON.encode([]),
        'input_assignee' : JSON.encode(['%content%', '%pr%', '%event%','%designer%','%speaker%']),
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
            'state_name': "Completed", 'to_states': [],
            'enter_actions': [ ], 'leave_actions': [ ]
          }
        ])
      }),
    ];

    List<int> nestedcollaterals = [
      await _createTemplate({
        'title' : 'Presentation',
        'description' : '',
        'type' : 'TASK',
        'ref_name' : 'coll1',
        'place' : '',
        'assignee' : JSON.encode([]),
        'input_assignee' : JSON.encode(['%content%', '%pr%', '%event%','%designer%','%speaker%']),
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
        'title' : 'Roll-ups',
        'description' : '',
        'type' : 'TASK',
        'ref_name' : 'coll22',
        'place' : '',
        'assignee' : JSON.encode([]),
        'input_assignee' : JSON.encode(['%content%', '%pr%', '%event%','%designer%','%speaker%']),
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
        'title' : 'Press wall',
        'description' : '',
        'type' : 'TASK',
        'ref_name' : 'coll3',
        'place' : '',
        'assignee' : JSON.encode([]),
        'input_assignee' : JSON.encode(['%content%', '%pr%', '%event%','%designer%','%speaker%']),
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
            'state_name': "Completed", 'to_states': [],
            'enter_actions': [ ], 'leave_actions': [ ]
          }
        ])
      }),
      await _createTemplate({
        'title' : 'Banner for web',
        'description' : '',
        'type' : 'TASK',
        'ref_name' : 'coll4',
        'place' : '',
        'assignee' : JSON.encode([]),
        'input_assignee' : JSON.encode(['%content%', '%pr%', '%event%','%designer%','%speaker%']),
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
            'state_name': "Completed", 'to_states': [],
            'enter_actions': [ ], 'leave_actions': [ ]
          }
        ])
      }),
      await _createTemplate({
        'title' : 'Badges',
        'description' : '',
        'type' : 'TASK',
        'ref_name' : 'coll5',
        'place' : '',
        'assignee' : JSON.encode([]),
        'input_assignee' : JSON.encode(['%content%', '%pr%', '%event%','%designer%','%speaker%']),
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
            'state_name': "Completed", 'to_states': [],
            'enter_actions': [ ], 'leave_actions': [ ]
          }
        ])
      })
    ];

    List<int> nestedmassmedia = [
      await _createTemplate({
        'title' : 'Invitation letter content',
        'description' : '',
        'type' : 'TASK',
        'ref_name' : 'mm1',
        'place' : '',
        'assignee' : JSON.encode(['']),
        'input_assignee' : JSON.encode(['%content%', '%pr%', '%event%','%designer%','%speaker%']),
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
        'title' : 'Invitation letter design',
        'description' : '',
        'type' : 'TASK',
        'ref_name' : 'mm2',
        'place' : '',
        'assignee' : JSON.encode(['']),
        'input_assignee' : JSON.encode(['%content%', '%pr%', '%event%','%designer%','%speaker%']),
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
        'title' : 'Mail-out with invitation',
        'description' : '',
        'type' : 'TASK',
        'ref_name' : 'mm3',
        'place' : '',
        'assignee' : JSON.encode([]),
        'input_assignee' : JSON.encode(['%content%', '%pr%', '%event%','%designer%','%speaker%']),
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
            'state_name': "Completed", 'to_states': [],
            'enter_actions': [ ], 'leave_actions': [ ]
          }
        ])
      }),
      await _createTemplate({
        'title' : 'Registration of journalists',
        'description' : '',
        'type' : 'TASK',
        'ref_name' : 'mm4',
        'place' : '',
        'assignee' : JSON.encode([]),
        'input_assignee' : JSON.encode(['%content%', '%pr%', '%event%','%designer%','%speaker%']),
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
            'state_name': "Completed", 'to_states': [],
            'enter_actions': [ ], 'leave_actions': [ ]
          }
        ])
      }),
    ];

    List<int> nestedpresskit = [
      await _createTemplate({
        'title' : 'Press kit content',
        'description' : '',
        'type' : 'TASK',
        'ref_name' : 'kit1',
        'place' : '',
        'assignee' : JSON.encode([]),
        'input_assignee' : JSON.encode(['%content%', '%pr%', '%event%','%designer%','%speaker%']),
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
        'title' : 'Printing the kit',
        'description' : '',
        'type' : 'TASK',
        'ref_name' : 'kit2',
        'place' : '',
        'assignee' : JSON.encode([]),
        'input_assignee' : JSON.encode(['%content%', '%pr%', '%event%','%designer%','%speaker%']),
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
        'title' : 'Packaging',
        'description' : '',
        'type' : 'TASK',
        'ref_name' : 'kit3',
        'place' : '',
        'assignee' : JSON.encode([]),
        'input_assignee' : JSON.encode(['%content%', '%pr%', '%event%','%designer%','%speaker%']),
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
            'state_name': "Completed", 'to_states': [],
            'enter_actions': [ ], 'leave_actions': [ ]
          }
        ])
      }),
    ];

    List<int> nestedspeakers = [
      await _createTemplate({
        'title' : 'Presentation speech copy',
        'description' : '',
        'type' : 'TASK',
        'ref_name' : 'spk1',
        'place' : '',
        'assignee' : JSON.encode([]),
        'input_assignee' : JSON.encode(['%content%', '%pr%', '%event%','%designer%','%speaker%']),
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
        'title' : 'Q&A list',
        'description' : '',
        'type' : 'TASK',
        'ref_name' : 'spk2',
        'place' : '',
        'assignee' : JSON.encode([]),
        'input_assignee' : JSON.encode(['%content%', '%pr%', '%event%','%designer%','%speaker%']),
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
      })
    ];

    List<int> nestedonsite = [
      await _createTemplate({
        'title' : 'Coordination',
        'description' : '',
        'type' : 'TASK',
        'ref_name' : 'site1',
        'place' : '',
        'assignee' : JSON.encode([]),
        'input_assignee' : JSON.encode(['%content%', '%pr%', '%event%','%designer%','%speaker%']),
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
        'title' : 'Moderator training',
        'description' : '',
        'type' : 'TASK',
        'ref_name' : 'site2',
        'place' : '',
        'assignee' : JSON.encode([]),
        'input_assignee' : JSON.encode(['%content%', '%pr%', '%event%','%designer%','%speaker%']),
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
        'title' : 'Register desk operation',
        'description' : '',
        'type' : 'TASK',
        'ref_name' : 'site4',
        'place' : '',
        'assignee' : JSON.encode([]),
        'input_assignee' : JSON.encode(['%content%', '%pr%', '%event%','%designer%','%speaker%']),
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
            'state_name': "Completed", 'to_states': [],
            'enter_actions': [ ], 'leave_actions': [ ]
          }
        ])
      }),
    ];

    List<int> nestedpostevent = [
      await _createTemplate({
        'title' : 'Press kit mail-out',
        'description' : '',
        'type' : 'TASK',
        'ref_name' : 'post1',
        'place' : '',
        'assignee' : JSON.encode([]),
        'input_assignee' : JSON.encode(['%content%', '%pr%', '%event%','%designer%','%speaker%']),
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
        'title' : 'Photoset publication',
        'description' : '',
        'type' : 'TASK',
        'ref_name' : 'post2',
        'place' : '',
        'assignee' : JSON.encode([]),
        'input_assignee' : JSON.encode(['%content%', '%pr%', '%event%','%designer%','%speaker%']),
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
        'title' : 'Analyse mass media feedback',
        'description' : '',
        'type' : 'TASK',
        'ref_name' : 'post3',
        'place' : '',
        'assignee' : JSON.encode([]),
        'input_assignee' : JSON.encode(['%content%', '%pr%', '%event%','%designer%','%speaker%']),
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
            'state_name': "Completed", 'to_states': [],
            'enter_actions': [ ], 'leave_actions': [ ]
          }
        ])
      }),
      await _createTemplate({
        'title' : 'Internal reports',
        'description' : '',
        'type' : 'TASK',
        'ref_name' : 'post4',
        'place' : '',
        'assignee' : JSON.encode([]),
        'input_assignee' : JSON.encode(['%content%', '%pr%', '%event%','%designer%','%speaker%']),
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
            'state_name': "Completed", 'to_states': [],
            'enter_actions': [ ], 'leave_actions': [ ]
          }
        ])
      }),
    ];

    List<int> nested1stlevel = [
    await createTemplate('Planning',
        '', 'FOLDER', 'planning', [], [], nestedplanning, defWorkflow, 'megaTeemId'),
    await createTemplate('Third-party booking',
        '', 'FOLDER', 'booking', [], [], nestedbooking, defWorkflow, 'megaTeemId'),
    await createTemplate('Collaterals',
        '', 'FOLDER', 'collaterals', [], [], nestedcollaterals, defWorkflow, 'megaTeemId'),
    await createTemplate('Mass media interaction',
        '', 'FOLDER', 'massmedia', [], [], nestedmassmedia, defWorkflow, 'megaTeemId'),
    await createTemplate('Speakers preparations',
        '', 'FOLDER', 'speakers', [], [], nestedspeakers, defWorkflow, 'megaTeemId'),
    await createTemplate('Onsite jobs',
        '', 'FOLDER', 'onsite', [], [], nestedonsite, defWorkflow, 'megaTeemId'),
    await createTemplate('Post-event jobs',
        '', 'FOLDER', 'postevent', [], [], nestedpostevent, defWorkflow, 'megaTeemId'),
    await createTemplate('Press kit',
        '', 'FOLDER', 'presskit', [], [], nestedpresskit, defWorkflow, 'megaTeemId'),
  ];
    await createTemplate('Event: %name%',
        '', 'PROJECT', 'event', [], [], nested1stlevel, defWorkflow, 'megaTeemId');
  }
}
