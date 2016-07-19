library template_srv.services.storage_servcie;

import 'dart:convert';
import 'package:embla/http.dart';
import 'package:embla/http_annotations.dart';
import 'package:embla_trestle/embla_trestle.dart';

import 'package:srv_base/Middleware/input_parser/input_parser.dart';
import 'package:srv_base/Utils/Utils.dart';
import 'package:srv_base/Utils/QueryLimit.dart';
import '../Models/Template.dart';

class RecordType {
  final _value;
  const RecordType._internal(this._value);
  String get Str => _value;
  toString() => '$_value';
  toInt() => values.indexOf(this);

  static RecordType fromInt(int ind) => values[ind];
  static RecordType fromStr(String val)
    => values.firstWhere((RecordType el) => el._value == val);

  static const TASKS = const RecordType._internal('tasks');
  static const FORMS = const RecordType._internal('forms');

  static final List<RecordType> values = [
    RecordType.TASKS,
    RecordType.FORMS
  ];
}

class Record extends Model {
  @field int id;
  @field int entity_id;
  @field int type;
  @field Map data;

  Map toJson() {
    return {
      'id' : entity_id,
      'type' : RecordType.fromInt(type).toString(),
      'data' : data
    };
  }
}

class StorageService extends Controller with QueryLimit {
  final Repository<Record> records;

  final Set urls = new Set.from(['tasks', 'forms']);

  StorageService(this.records);

  @Post('/:type') createFromsData(Input args, {String type}) async {
    if(!urls.contains(type)) this.abortNotFound();
    Map params = args.body;
    Record rec = new Record()
      ..type = RecordType.fromStr(type).toInt()
      ..entity_id = int.parse(params['id'])
      ..data = JSON.decode(params['data']);
    return await records.save(rec);
  }

  @Get('/:type/:id') getFormsData({String id, String type}) async {
    if(!urls.contains(type)) this.abortNotFound();
    final int queryType = RecordType.fromStr(type).toInt();
    try {
      Record ret = await records.where((el)
                  => el.entity_id == int.parse(id) && el.type == queryType)
                        .get().first;
      return ret.data;
    } catch (err) {
      this.abortNotFound();
    }
  }

  @Get('/:type') getDataQuery(Input args, {String type}) async {
    if(!urls.contains(type)) this.abortNotFound();
    final int queryType = RecordType.fromStr(type).toInt();
    Map params = args.body;
    if(params.keys.isEmpty) {
      return records.where((el) => el.type == queryType).get()
        .toList().then((List<Record> items) => items.map((Record el) => el.data))
        .catchError((StateError err){ this.abortNotFound();});
    } else {
      final String key = params.keys.first;
      return records
        .where((el) => el.type == queryType).get()
          .where((el) => el.data[key] == params[key])
          .toList().then((List<Record> items) => items.map((Record el) => el.data))
          .catchError((StateError err){ this.abortNotFound();});
    }
  }
}
