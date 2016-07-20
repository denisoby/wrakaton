library template_srv;

import 'dart:async';
import 'package:di/di.dart';
import 'package:di/type_literal.dart';
import 'package:embla/application.dart';
import 'package:option/option.dart';
import 'package:harvest/harvest.dart';
import 'package:http_exception/http_exception.dart';
import 'package:trestle/trestle.dart';

import 'package:srv_base/Srv.dart';
import 'package:srv_base/Models/Users.dart';
import 'package:srv_base/Utils/Crypto.dart' as crypto;
import 'Storage/WrikeApi.dart';
import 'Models/Template.dart';
import 'Models/TemplateRequest.dart';
import 'package:logging/logging.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:template_srv/Services/StorageService.dart';
import 'package:trestle/gateway.dart';
export 'Services/StorageService.dart';
export 'Services/RulesService.dart';
export 'Services/TemplateService.dart';
export 'Services/UsersService.dart';

class ActionSrv extends Bootstrapper {
  MessageBus _bus = new MessageBus();
  ModuleInjector _injector;
  AuthConfig authConfig = new AuthConfig();
  Repository<TemplateRequest> _requests;
  UserService userService;

  Repository<User> _users;
  Repository<Template> _templates;
  Repository<Record> _records;

  Gateway gateway;

  ActionSrv(this.gateway);

  @Hook.init
  init() {
    _injector = new ModuleInjector([ new Module()
      ..bind(MessageBus, toFactory: () => _bus)
      ..bind(AuthConfig, toFactory: () => authConfig)
      ..bind(IStorage, toValue: new WrikeStorage())
      ..bind(new TypeLiteral<Repository<Template>>().type,
             toFactory: () => _templates)
      ..bind(new TypeLiteral<Repository<TemplateRequest>>().type,
             toFactory: () => _requests)
    ]);
    Utils.setInjector(_injector);

    authConfig
    ..issuer = 'Wrike'
    ..secret = 'WrikeSecreteCode'
    ..lookupByUserName = this.lookupByUsername
    ..validateUserPass = this.validateUserPass
    ..excludeHandler = this.excludeUrlForAuth
    ..welcomeHandler = this.welcomeHandler;

    setupConsoleLog();

    _users = new Repository<User>(gateway);
    _templates = new Repository<Template>(gateway);
    _records = new Repository<Record>(gateway);
  }

  void setupConsoleLog([Level level = Level.INFO]) {
    Logger.root.level = level;
    Logger.root.onRecord.listen((LogRecord rec) {

      if (rec.level >= Level.SEVERE) {
        var stack = rec.stackTrace != null ? "\n${Trace.format(rec.stackTrace)}" : "";
        print('[${rec.loggerName}] - ${rec.level.name}: ${rec.time}: ${rec.message} - ${rec.error}${stack}');
      } else {
        print('[${rec.loggerName}] - ${rec.level.name}: ${rec.time}: ${rec.message}');
      }
    });
  }

  @Hook.interaction
  initUserSrv(UserService srv) {
    this.userService = srv;
  }

  @Hook.interaction
  initTemplates(Repository<Template> templates) {
    this._templates = templates;
  }

  @Hook.interaction
  initRequests(Repository<TemplateRequest> requests) {
    this._requests = requests;
  }

  Future<User> _getUserByName(String username)
    => userService.getUserByName(username);

  Future<Option<UserPrincipal>>
    validateUserPass(String username, String password) async
  {
    User user = await _getUserByName(username);

    if(user.password == crypto.encryptPassword(password)) {
        return new Some(new UserPrincipal(username, user.id, user.group));
    }
    throw new UnauthorizedException();
  }

  Future<Option<UserPrincipal>> lookupByUsername(String username) async
  {
    User user = await _getUserByName(username);
    if(user != null) {
      return new Some(new UserPrincipal(username, user.id, user.group));
    }
    return const None();
  }

  Future<bool> excludeUrlForAuth(Uri uri, String method) async {
    bool ret = false;
    if(uri.path == "/users" && method == "POST") {
      ret = true;
    }
    return ret;
  }

  Future<String> welcomeHandler(UserPrincipal cred) async {
    return "users/${cred.id}";
  }
}
