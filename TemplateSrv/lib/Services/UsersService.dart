library template_srv.services.user_service;

import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:embla/http.dart';
import 'package:embla/http_annotations.dart';
import 'package:embla_trestle/embla_trestle.dart';
import 'package:harvest/harvest.dart';
import 'package:tasks/tasks.dart';

import 'package:srv_base/Utils/Utils.dart';
import 'package:srv_base/Utils/Crypto.dart' as crypto;
import 'package:srv_base/Middleware/input_parser/input_parser.dart';
import 'package:srv_base/Models/Users.dart';
import '../Utils/Tasks/DeployTemplate.dart';
import '../Storage/IStorage.dart';
import '../Models/Template.dart';
import '../Models/TemplateRequest.dart';

export 'package:srv_base/Models/Users.dart';

class UserService extends Controller {
  final Repository<User> users;
  final Repository<Template> templates;
  final Repository<TemplateRequest> template_requests;
  MessageBus _bus;
  TaskQueue _taskQueue = new TaskQueue(concurrencyCount: 3);

  Uuid generator = new Uuid();
  IStorage _storage;

  UserService(this.users, this.templates, this.template_requests)
  {
    _bus = Utils.$(MessageBus);
    _storage = Utils.$(IStorage);
  }

  Future<User> getUserByName(String username)
    => users.where((user) => user.email == username).first();

  Future<User> getUserById(int id) => users.find(id);

  _returnOk(String key, var value) => {'msg':'ok', key : value};

  bool _filterData(Map data) {
    return true;
  }

  @Post('/') create(Input args) async {
    Map params = args.body;
    if(expect(params, 'email') &&
       expect(params, 'password')) {
        try {
           //check exist user
           User user = await getUserByName(params['email']);
           this.abortConflict('user exist');
        } catch (err){
          if (err is HttpException) rethrow;
        }

        User user = new User()
          ..email = params['email']
          ..password = crypto.encryptPassword(params['password'])
          ..enabled = true
          ..group = UserGroup.toStr(UserGroup.USER)
          ..settings = {
            'uuid' :  generator.v4()
          };
        await users.save(user);
          //.then((_) => _bus.publish(CreateUser.create(user)));
        return _returnOk('userId', user.id);
    } else {
      this.abortBadRequest('wrong data');
    }
  }

  @Get('/:id') getUser({String id})
    => getUserById(int.parse(id))
      .then((User user) async {
        //await _bus.publish(GetUserData.create(user));
        return user;
      });

  @Get('/:id/data') getUsetData({String id}) async {
    User user = await getUserById(int.parse(id));
    return user.data;
  }

  @Put('/:id/data') updateUser(Input args, {String id}) async {
    User user =  await getUserById(int.parse(id));
    Map params = args.body;
    if(_filterData(params)) {
      user.data = params;
      await users.save(user);
    }
    return this.ok('');
  }

  _materialize(Template base) async {
    _taskQueue.queue(new DeployTemplate(base));
  }

  @Post('/:id/templates') createTemplateRequest(Input args, {String id}) async {
    User user =  await getUserById(int.parse(id));
    Map params = args.body;
    if(expect(params, 'template')) {
      Template template = await templates.find(int.parse(params['template']));
      TemplateRequest request = new TemplateRequest()
        ..user_id = user.id
        ..base_template_id = template.id;
      _materialize(template);
    }
    return this.ok('');
  }

}
