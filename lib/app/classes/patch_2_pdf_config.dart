import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

Directory? appDocDirectory;

Future<Patch2PDFConfig> readConfig() async {
  appDocDirectory ??= await getApplicationDocumentsDirectory();
  File config = File("${appDocDirectory!.path}/config.json");
  bool configexists = await config.exists();
  File maLogo = File("${appDocDirectory!.path}/logos/ma_logo.png");
  maLogo.exists().then((exists) {
    if (!exists) {
      maLogo.create(recursive: true).then((value) {
        rootBundle.load('assets/ma_logo.png').then((bytedata) => maLogo.writeAsBytes(bytedata.buffer.asUint8List()));
      });
    }
  });
  final String response;
  if (!configexists) {
    response = await rootBundle.loadString('assets/default_config.json');
    config.writeAsString(response);
  } else {
    response = await config.readAsString();
  }
  final data = await jsonDecode(response);
  return Patch2PDFConfig.fromJSON(data);
}

Future<void> saveConfig(Patch2PDFConfig config) async {
  appDocDirectory ??= await getApplicationDocumentsDirectory();
  appDocDirectory = await getApplicationDocumentsDirectory();
  File configfile = File("${appDocDirectory!.path}/config.json");
  final data = jsonEncode(config);
  configfile.writeAsString(data);
}

class TableHeaderConfig {
  TableHeaderConfig({
    required this.name,
    required this.enabled,
    required this.width,
    required this.parserVar,
    required this.valAlignment,
  });
  TableHeaderConfig.fromJSON(Map<String, dynamic> json)
      : name = json["name"],
        enabled = json["enabled"],
        width = json["width"],
        parserVar = json["parserVar"] ?? "",
        valAlignment = json["valAlignment"],
        specialType = json["specialType"] ?? "";
  String name;
  bool enabled;
  String width;
  String parserVar;
  String valAlignment;
  String specialType = "";

  static fromJson(model) {
    return TableHeaderConfig.fromJSON(model);
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "enabled": enabled,
        "width": width,
        "parserVar": parserVar,
        "valAlignment": valAlignment,
        "specialType": specialType,
      };
}

class Logo {
  Logo({
    required this.displayName,
    required this.path,
  });
  Logo.fromJSON(Map<dynamic, dynamic> json)
      : displayName = json["displayName"],
        path = json["filePath"];
  String displayName;
  String path;

  static fromJson(json) {
    return Logo.fromJSON(json);
  }

  Map<String, dynamic> toJson() => {
        "displayName": displayName,
        "filePath": path,
      };
}

class Patch2PDFConfig {
  Patch2PDFConfig({
    required this.logos,
    required this.headerconfigs,
    this.defaultlogoindex = 0,
  });
  Patch2PDFConfig.fromJSON(Map<String, dynamic> json)
      : logos = List<Logo>.from(json["logos"].map((model) => Logo.fromJson(model))),
        headerconfigs = List<TableHeaderConfig>.from(json["tableHeaders"].map((model) => TableHeaderConfig.fromJson(model))),
        defaultlogoindex = json["defaultlogoindex"] ?? 0;

  List<Logo> logos;
  int defaultlogoindex;
  List<TableHeaderConfig> headerconfigs;

  Map<String, dynamic> toJson() => {
        "logos": logos,
        "tableHeaders": headerconfigs,
        "defaultlogoindex": defaultlogoindex,
      };
}
