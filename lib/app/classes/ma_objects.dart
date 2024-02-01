import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'dart:math';

extension _ToBinary on int {
  String toBinary(
    int len, {
    int separateAtLength = 4,
    String separator = ',',
  }) =>
      toRadixString(2).padLeft(len, '0').splitByLength(separateAtLength).join(separator);
}

extension _SplitByLength on String {
  Iterable<String> splitByLength(int len, {String filler = '0'}) sync* {
    final missingFromLength = length % len == 0 ? 0 : len - (characters.length % len);
    final expectedLength = length + missingFromLength;
    final src = padLeft(expectedLength, filler);
    final chars = src.characters;
    for (var i = 0; i < chars.length; i += len) {
      yield chars.getRange(i, i + len).toString();
    }
  }
}

class Fixture {
  Fixture({
    required this.fixtureType,
    required this.fixtureID,
    required this.name,
    required this.patch,
    this.position,
    this.channelID,
    this.dipPatch,
  });
  Fixture.fromJSON(Map<String, dynamic> json)
      : name = json["Name"] as String,
        fixtureType = json["FixtureType"] as String,
        patch = json["Patch"] as String,
        fixtureID = json["FixtureID"] as int,
        dipPatch = (json["DipPatch"] != null) ? (json["DipPatch"].replaceAll(RegExp(r'0'), '\u257D').replaceAll(RegExp(r'1'), '\u257F')) : null,
        position = (json["Position"] != null) ? Position.fromJSON(json["Position"]) : null;
  String fixtureType;
  String name;
  String patch;
  int? fixtureID;
  String? channelID;
  String? dipPatch;
  Position? position;

  static Fixture fromJson(json) {
    return Fixture.fromJSON(json);
  }

  static Fixture? fromXML(XmlElement xmlFixture) {
    Iterable<XmlElement> subfixtures = xmlFixture.findAllElements("SubFixture");
    int address = _getAddressFromXML(subfixtures);
    if (address != 0) {
      return Fixture(
        fixtureType: xmlFixture.findAllElements("FixtureType").first.getAttribute("name")!,
        fixtureID: (xmlFixture.getAttribute("fixture_id") != null) ? int.parse(
          xmlFixture.getAttribute("fixture_id")!,
        ) : null,
        name: xmlFixture.getAttribute("name")!,
        patch: "${(address / 512).ceil()}.${"${(address % 512 == 0) ? (512) : (address % 512)}".padLeft(3, '0')}",
        position: Position.fromXML(xmlFixture),
        dipPatch: ((address % 512 == 0) ? (512) : (address % 512)).toBinary(10, separateAtLength: 10).split('').reversed.join().replaceAll(RegExp(r'0'), '\u257D').replaceAll(RegExp(r'1'), '\u257F'),
      );
    } else {
      return null;
    }
  }

  static int _getAddressFromXML(Iterable<XmlElement> xmlSubFixtures) {
    if (xmlSubFixtures.length == 1) {
      if (xmlSubFixtures.first.getElement("Patch") == null) {
        return 0;
      }
      return int.parse(xmlSubFixtures.first.getElement("Patch")!.innerText);
    } else {
      List<int> patches = [];
      for (XmlElement subfix in xmlSubFixtures) {
        if (subfix.getElement("Patch") == null) {
          return 0;
        }
        patches.add(int.parse(subfix.getElement("Patch")!.innerText));
      }
      return patches.reduce(min);
    }
  }

  @override
  String toString() {
    String string = """{
      "Name": "$name",
      "FixtureID": $fixtureID,
      "FixtureType": "$fixtureType",
      "Patch": "$patch",
      "DipPatch": "$dipPatch",
      "Position": ${position.toString()},
    }""";
    return string;
  }

  /* Map<String, dynamic> toJson() => {
        "Name": name,
        "FixtureID": fixtureID,
        "FixtureType": fixtureType,
        "Patch": patch,
        "DipPatch": dipPatch,
        "Position": position?.toJson(),
      }; */
}

/* class Position {
  Position({
    required this.x,
    required this.y,
    required this.z,
  });
  Position.fromJSON(Map<String, dynamic> json)
      : x = json["x"] + .0,
        y = json["y"] + .0,
        z = json["z"] + .0;
  double x;
  double y;
  double z;

  static Position fromJson(json) {
    return Position.fromJSON(json);
  }

  static Position? fromXML(XmlElement xmlFixture) {
    Iterable<XmlElement> absposlist = xmlFixture.findAllElements("AbsolutePosition");
    if (absposlist.isEmpty) {
      return null;
    } else {
      XmlElement abspos = absposlist.first.findAllElements("Location").first;
      return Position(
        x: double.parse(abspos.getAttribute("x")!),
        y: double.parse(abspos.getAttribute("y")!),
        z: double.parse(abspos.getAttribute("z")!),
      );
    }
  }

  @override
  String toString() {
    String string = """{
      "x": $x,
      "y": $y,
      "z": $z,
    }""";
    return string;
  }

  String toPDFString() {
    RegExp regex = RegExp(r"([.]*0+)(?!.*\d)");
    return "( ${x.toStringAsFixed(2).replaceAll(regex, '')} | ${y.toStringAsFixed(2).replaceAll(regex, '')} | ${z.toStringAsFixed(2).replaceAll(regex, '')} )";
  }

  Map<String, dynamic> toJson() => {
        "x": x,
        "y": y,
        "z": z,
      };
} */

class Position {
  Position({
    this.location,
    this.rotation,
  });
  Position.fromJSON(Map<String, dynamic> json)
      : location = Location.fromJSON(json["Location"]),
        rotation = Rotation.fromJSON(json["Rotation"]);
  Location? location;
  Rotation? rotation ;

  static Position fromJson(json) {
    return Position.fromJSON(json);
  }

  static Position? fromXML(XmlElement xmlFixture) {
    Iterable<XmlElement> absposlist = xmlFixture.findAllElements("AbsolutePosition");
    if (absposlist.isEmpty) {
      return null;
    } else {
      XmlElement abspos = absposlist.first;
      return Position(
        location: Location.fromXML(abspos),
        rotation: Rotation.fromXML(abspos),
      );
    }
  }

  @override
  String toString() {
    String string = """{
      "Position": $location,
      "Rotation": $rotation,
    }""";
    return string;
  }

  String toPDFString() {
    return (location != null) ? location!.toPDFString() : "";
  }
}

class Location {
  Location({
    required this.x,
    required this.y,
    required this.z,
  });
  Location.fromJSON(Map<String, dynamic> json)
      : x = json["x"] + .0,
        y = json["y"] + .0,
        z = json["z"] + .0;
  double x;
  double y;
  double z;

  static Location fromJson(json) {
    return Location.fromJSON(json);
  }

  static Location? fromXML(XmlElement absPos) {
    XmlElement location = absPos.findAllElements("Location").first;
    return Location(
        x: double.parse(location.getAttribute("x")!),
        y: double.parse(location.getAttribute("y")!),
        z: double.parse(location.getAttribute("z")!),
      );
  }

  @override
  String toString() {
    String string = """{
      "x": $x,
      "y": $y,
      "z": $z,
    }""";
    return string;
  }

  String toPDFString() {
    RegExp regex = RegExp(r"([.]*0+)(?!.*\d)");
    return "( ${x.toStringAsFixed(2).replaceAll(regex, '')} | ${y.toStringAsFixed(2).replaceAll(regex, '')} | ${z.toStringAsFixed(2).replaceAll(regex, '')} )";
  }

  Map<String, dynamic> toJson() => {
        "x": x,
        "y": y,
        "z": z,
      };
}

class Rotation {
  Rotation({
    required this.x,
    required this.y,
    required this.z,
  });
  Rotation.fromJSON(Map<String, dynamic> json)
      : x = json["x"] + .0,
        y = json["y"] + .0,
        z = json["z"] + .0;
  double x;
  double y;
  double z;

  static Rotation fromJson(json) {
    return Rotation.fromJSON(json);
  }

  static Rotation? fromXML(XmlElement absPos) {
    XmlElement rotation = absPos.findAllElements("Rotation").first;
    return Rotation(
        x: double.parse(rotation.getAttribute("x")!),
        y: double.parse(rotation.getAttribute("y")!),
        z: double.parse(rotation.getAttribute("z")!),
      );
  }

  @override
  String toString() {
    String string = """{
      "x": $x,
      "y": $y,
      "z": $z,
    }""";
    return string;
  }

  Map<String, dynamic> toJson() => {
        "x": x,
        "y": y,
        "z": z,
      };
}

class Group {
  Group({
    required this.name,
    required this.index,
    this.subgroups,
    this.fixtures,
  });
  Group.fromJSON(Map<String, dynamic> json)
      : name = json["name"] as String,
        index = json["index"] as int,
        subgroups = (json["subgroups"] != null) ? List<Group>.from(json["subgroups"].map((model) => Group.fromJson(model))) : null,
        fixtures = (json["fixtures"] != null) ? List<Fixture>.from(json["fixtures"].map((model) => Fixture.fromJson(model))) : null;
  String name;
  int index;
  List<Group>? subgroups;
  List<Fixture>? fixtures;

  static Group fromJson(json) {
    return Group.fromJSON(json);
  }

  static Group fromXML(XmlElement layer) {
    List<XmlElement> xmlFixtures = layer.findElements("Fixture").toList();
    List<Fixture> fixtures = [];
    for (XmlElement xmlFixture in xmlFixtures) {
      Fixture? fixture = Fixture.fromXML(xmlFixture);
      if (fixture != null) {
        fixtures.add(fixture);
      }
    }
    return Group(
      index: int.parse(layer.getAttribute("index")!),
      name: layer.getAttribute("name")!,
      fixtures: fixtures,
    );
  }

  @override
  String toString() {
    String string = """{
      "name": "$name",
      "index": $index,
      "subgroups": ${subgroups.toString()},
      "fixtures": ${fixtures.toString()},
    }""";
    return string;
  }

  Map<String, dynamic> toJson() => {"Name": name, "index": index, "subgroups": subgroups};
}

class PatchDataData {
  PatchDataData({
    this.fixtures,
    this.groups,
  });
  PatchDataData.fromJSON(Map<String, dynamic> json)
      : fixtures = (json["fixtures"] != null) ? List<Fixture>.from(json["fixtures"].map((model) => Fixture.fromJson(model))) : null,
        groups = (json["groups"] != null) ? Map<String, Group>.from(json["groups"].map((name, model) => MapEntry(name, Group.fromJson(model)))) : null;
  List<Fixture>? fixtures;
  Map<String, Group>? groups;

  static PatchDataData fromJson(json) {
    return PatchDataData.fromJSON(json);
  }

  static PatchDataData fromXML(XmlElement xmlData) {
    List<XmlElement> xmlLayers = xmlData.findElements("Layer").toList();
    Map<String, Group> groups = {};
    for (XmlElement xmlLayer in xmlLayers) {
      Group group = Group.fromXML(xmlLayer);
      groups.addAll({group.name: group});
    }
    return PatchDataData(groups: groups);
  }

  @override
  String toString() {
    String string = """
      "data":{
        "fixtures": ${fixtures.toString()},
        "groups": ${groups.toString()}
      }""";
    return string;
  }
}

class PatchData {
  PatchData({
    required this.data,
    required this.showName,
    this.exportTime,
    this.version,
    this.stageName,
    this.hostOS,
  });
  PatchData.fromJSON(Map<String, dynamic> json)
      : data = PatchDataData.fromJSON(json["data"]),
        exportTime = DateTime.parse(json["exportTime"] as String),
        version = json["Version"] as String,
        showName = json["showname"] as String,
        stageName = json["stagename"] as String,
        hostOS = json["HostOS"] as String;
  PatchDataData data;
  DateTime? exportTime;
  String? version;
  String showName;
  String? stageName;
  String? hostOS;

  static PatchData fromJson(json) {
    return PatchData.fromJSON(json);
  }

  static PatchData fromMA2XML(XmlDocument xmldoc) {
    XmlElement maTag = xmldoc.findElements("MA").first;
    String? datetime = maTag.findAllElements("Info").first.getAttribute("datetime");
    return PatchData(
      data: PatchDataData.fromXML(maTag),
      showName: maTag.findAllElements("Info").first.getAttribute("showfile")!,
      exportTime: (datetime != null) ? DateTime.parse(datetime) : DateTime.now(),
      version: "GMA2",
    );
  }

  @override
  String toString() {
    String string = """Patchdata:{
        ${data.toString()},
        "exportTime": "$exportTime",
        "version": "$version",
        "showName": "$showName",
        "stageName": "$stageName",
        "HostOS": "$hostOS"
      }""";
    return string;
  }
}
