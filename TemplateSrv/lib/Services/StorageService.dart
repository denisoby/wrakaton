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

  static const TASK = const RecordType._internal('tasks');
  static const FORMS = const RecordType._internal('forms');

  static final List<RecordType> values = [
    RecordType.TASK,
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
    return records.where((el)
      => el.entity_id == int.parse(id) &&
         RecordType.fromInt(el.type) == RecordType.fromStr(type))
          .limit(1).first().catchError((StateError err){
            this.abortNotFound();
          });
  }
}
