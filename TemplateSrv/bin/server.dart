import 'dart:io';
import 'dart:isolate';
import 'package:template_srv/Srv.dart' as Srv;
import 'package:srv_base/Srv.dart' as base;
import 'package:embla/http.dart';
import 'package:embla/http_basic_middleware.dart';
import 'package:embla_trestle/embla_trestle.dart';
import 'package:srv_base/Models/Users.dart';

export 'package:embla/application.dart';
import 'package:embla/bootstrap.dart' as embla_bootstrap;

import 'stubs/srubDeploy.dart';

Map config = {
  'port' : 8001
};

main(List<String> arguments, SendPort sendExitCommandPort) async {
  if(arguments.length == 1) {
    config['port'] = int.parse(arguments[0]);
  }
  return embla_bootstrap.main(arguments, sendExitCommandPort);
}

var driver =
  new PostgresqlDriver(username: 'postgres',
                       password: 'postgres',
                       database: 'template_srv'/*, host: '192.168.3.23', ssl: true*/);

get embla => [
  new DatabaseBootstrapper(
    driver: driver
  ),
  new base.HttpsBootstrapper(
    port: config['port'],
    ipAddress: InternetAddress.ANY_IP_V4,
    pipeline: pipe(
      LoggerMiddleware, RemoveTrailingSlashMiddleware,
      Route.post('login/', base.JwtLoginMiddleware),
      base.InputParserMiddleware,
      Route.all('users/*', /*base.JwtAuthMiddleware,
        new base.UserGroupFilter(UserGroup.USER.Str), base.UserIdFilter,*/
        Srv.UserService),
      Route.all('templates/*', /*base.JwtAuthMiddleware,
        new base.UserGroupFilter(UserGroup.USER.Str),*/
        Srv.TemplateService),
      Route.all('storage/*', Srv.StorageService)
    )
  ),
  new Srv.ActionSrv(new Gateway(driver))
  //new SubDeploy(new Gateway(driver))
];
