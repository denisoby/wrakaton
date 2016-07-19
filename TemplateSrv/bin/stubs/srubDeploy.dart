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

  SubDeploy(this.gateway);

  @Hook.init
  init() {
    _users = new Repository<User>(gateway);
    _templates = new Repository<Template>(gateway);
    createStubUser();
    createStub_Article_Templates();
    createStub_ItHelpdesk_Templates();
  }

  Future<int> createTemplate(String header,
                             String description,
                             String type,
                             List<String> assignee,
                             List<int> nested,
                             List workflow,
                             [String placeId = null]) {
    Map template = {
      'title' : header,
      'description' : description,
      'type' : type,
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

  createStub_Article_Templates() async {
    List<int> nested = [
    await _createTemplate({
      'title' : 'Collect data %title%',
      'description' : '',
      'type' : 'TASK',
      'place' : '',
      'assignee' : JSON.encode([]),
      'nested' : JSON.encode([]),
      'workflow' : JSON.encode([
        { /* 0 */
          'state_name': "New", 'to_states': [ 1 ],
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 1 */
          'state_name': "Collecting data", 'to_states': [ 2 ],
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 2 */
          'state_name': "Data in review", 'to_states': [ 1, 3 ],
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 3 */
          'state_name': "Completed", 'to_states': [],
          'enter_actions': [ ], 'leave_actions': [ ]
        }
      ])
    }),
    await _createTemplate({
      'title' : 'Content %title%',
      'description' : '',
      'type' : 'TASK',
      'place' : '',
      'assignee' : JSON.encode([]),
      'nested' : JSON.encode([]),
      'workflow' : JSON.encode([
        { /* 0 */
          'state_name': "New", 'to_states': [ 1 ],
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 1 */
          'state_name': "Content creation", 'to_states': [ 2 ],
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 2 */
          'state_name': "Content in review", 'to_states': [ 1, 3 ],
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 3 */
          'state_name': "Completed", 'to_states': [],
          'enter_actions': [ ], 'leave_actions': [ ]
        }
      ])
    }),
    await _createTemplate({
      'title' : 'Make-up %title%',
      'description' : '',
      'type' : 'TASK',
      'place' : '',
      'assignee' : JSON.encode([]),
      'nested' : JSON.encode([]),
      'workflow' : JSON.encode([
        { /* 0 */
          'state_name': "New", 'to_states': [ 1 ],
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 1 */
          'state_name': "Design in progress", 'to_states': [ 2 ],
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 2 */
          'state_name': "Design in review", 'to_states': [ 1, 3 ],
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 3 */
          'state_name': "Final review", 'to_states': [ 2, 4 ],
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 4 */
          'state_name': "Completed", 'to_states': [],
          'enter_actions': [ ], 'leave_actions': [ ]
        }
      ])
    }),
    await _createTemplate({
      'title' : 'Publish %title%',
      'description' : '',
      'type' : 'TASK',
      'place' : '',
      'assignee' : JSON.encode([]),
      'nested' : JSON.encode([]),
      'workflow' : JSON.encode([
        { /* 0 */
          'state_name': "New", 'to_states': [ 1 ],
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 1 */
          'state_name': "Publishing", 'to_states': [ 2 ],
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 2 */
          'state_name': "Waiting for response", 'to_states': [ 3 ],
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 3 */
          'state_name': "Completed", 'to_states': [],
          'enter_actions': [ ], 'leave_actions': [ ]
        }
      ])
    })
    ];
    await createTemplate('Article creation %title%',
      '', 'PROJECT', ['%analyst%'], nested, defWorkflow, 'megaTeemId');
  }

  createStub_ItHelpdesk_Templates() async {
    List<int> nested = [
    await _createTemplate({
      'title' : 'Collect data %title%',
      'description' : '',
      'type' : 'TASK',
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
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 2 */
          'state_name': "Waiting for approval", 'to_states': [ 3, 4 ],
          'enter_actions': [ ], 'leave_actions': [ ]
        },
        { /* 3 */
          'state_name': "In progress - approved", 'to_states': [ 5 ],
          'enter_actions': [ ], 'leave_actions': [ ]
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
    })
    ];
    await createTemplate(' IT-helpdesk %title%',
      '', 'PROJECT', ['%engineer%'], nested, defWorkflow, 'megaTeemId');
  }

}
