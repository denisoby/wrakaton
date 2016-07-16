library template_srv;

import 'dart:async';
import 'package:di/di.dart';
import 'package:embla/application.dart';
import 'package:option/option.dart';
import 'package:harvest/harvest.dart';
import 'package:http_exception/http_exception.dart';

import 'package:srv_base/Srv.dart';
import 'package:srv_base/Models/Users.dart';
import 'package:srv_base/Utils/Crypto.dart' as crypto;
export 'Services/TemplateService.dart';

class ActionSrv extends Bootstrapper {
  MessageBus _bus = new MessageBus();
  ModuleInjector _injector;
  AuthConfig authConfig = new AuthConfig();
  UserService userService;

  @Hook.init
  init() {
    _injector = new ModuleInjector([ new Module()
      ..bind(MessageBus, toFactory: () => _bus)
      ..bind(AuthConfig, toFactory: () => authConfig)
    ]);
    Utils.setInjector(_injector);

    authConfig
    ..issuer = 'Wrike'
    ..secret = 'WrikeSecreteCode'
    ..lookupByUserName = this.lookupByUsername
    ..validateUserPass = this.validateUserPass
    ..excludeHandler = this.excludeUrlForAuth
    ..welcomeHandler = this.welcomeHandler;
  }

  @Hook.interaction
  initUserSrv(UserService srv) {
    this.userService = srv;
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
