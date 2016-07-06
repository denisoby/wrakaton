import 'package:template_srv/Srv.dart' as Srv;
import 'package:srv_base/Srv.dart' as base;
import 'package:embla/http.dart';
import 'package:embla/http_basic_middleware.dart';
import 'package:embla_trestle/embla_trestle.dart';
import 'package:srv_base/Models/Users.dart';

export 'package:embla/application.dart';
export 'package:embla/bootstrap.dart';

final Map config = {
  'username': 'postgres',
  'password': 'qwerty',
  'database': 'templates'
};


var driver = new InMemoryDriver();

/*
var driver = new base.PostgisPsqlDriver(username: config['username'],
                                        password: config['password'],
                                        database: config['database']);
*/

get embla => [
  new DatabaseBootstrapper(
    driver: driver
  ),
  new base.HttpsBootstrapper(
    port: 9090,
    pipeline: pipe(
      LoggerMiddleware, RemoveTrailingSlashMiddleware,
      Route.post('login/', base.JwtLoginMiddleware),
      base.InputParserMiddleware,
      Route.all('users/*', base.JwtAuthMiddleware,
        new base.UserGroupFilter(UserGroup.USER.Str), base.UserIdFilter,
        base.UserService),
      Route.all('templates/*', base.JwtAuthMiddleware,
        new base.UserGroupFilter(UserGroup.USER.Str),
        Srv.TemplateService)
    )
  ),
  new Srv.ActionSrv()
];
