import 'package:template_srv/Srv.dart' as Srv;
import 'package:srv_base/Srv.dart' as base;
import 'package:embla/http.dart';
import 'package:embla/http_basic_middleware.dart';
import 'package:embla_trestle/embla_trestle.dart';

export 'package:embla/application.dart';
export 'package:embla/bootstrap.dart';

final Map config = {
  'username': 'postgres',
  'password': 'qwerty',
  'database': 'templates'
};


//var driver = new InMemoryDriver();

//*
var driver = new base.PostgisPsqlDriver(username: config['username'],
                                        password: config['password'],
                                        database: config['database']);
//*/

get embla => [
  new DatabaseBootstrapper(
    driver: driver
  ),
  new base.HttpsBootstrapper(
    port: 9090,
    pipeline: pipe(
      LoggerMiddleware, base.CORSMiddleware,
      Route.post('login/', base.JwtLoginMiddleware),
      RemoveTrailingSlashMiddleware, base.InputParserMiddleware,
      Route.all('users/*', base.JwtAuthMiddleware, base.UserIdFilter, base.UserService)
    )
  ),
  new Srv.ActionSrv()
];
