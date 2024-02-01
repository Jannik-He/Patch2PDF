import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:patch2pdf/app/classes/ma_objects.dart';
import 'package:patch2pdf/app/pages/pdfviewer.dart';
import 'app/widgets/mobile_layer_config.dart';
import 'app/widgets/normal_layer_config.dart';
import 'app/classes/patch_2_pdf_config.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import 'app/pages/settings.dart';
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

handlePatchFileString(String filedata, String extension, BuildContext context) {
  PatchData? data;
  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    width: 400.0,
    content: const Text('Not a MA file.'),
    action: SnackBarAction(
      label: 'Close',
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
    ),
  );
  if (extension == ".json") {
    //TODO: if necessary add csv converter
    Map<String, dynamic> json = jsonDecode(filedata);
    if (json["MA3Patch2PDF"] != null) {
      data = PatchData.fromJSON(json["MA3Patch2PDF"]);
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  } else if (extension == ".xml") {
    XmlDocument xmldoc = XmlDocument.parse(filedata);
    if (xmldoc.findAllElements("MA").isNotEmpty) {
      data = PatchData.fromMA2XML(xmldoc);
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  } else {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  if (data != null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LayerConfig(patchdata: data!),
      ),
    );
  }
}

void main() {
  runApp(const Patch2PDF());
}

late Patch2PDFConfig patch2pdfconfig;

class Patch2PDF extends StatefulWidget {
  const Patch2PDF({super.key});

  @override
  State<Patch2PDF> createState() => _Patch2PDFState();
}

class _Patch2PDFState extends State<Patch2PDF> {
  @override
  void initState() {
    readConfig().then((value) => patch2pdfconfig = value);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade400,
          background: Colors.grey.shade50,
          secondary: Colors.grey.shade100,
          onSecondary: Colors.black,
          tertiary: Colors.grey.shade300,
          onTertiary: Colors.black,
        )),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue.shade800,
            background: Colors.grey.shade900,
            onBackground: Colors.white,
            tertiary: Colors.grey.shade800,
            onTertiary: Colors.grey.shade300,
          ),
        ),
        themeMode: ThemeMode.system,
        home: const AppScaffold());
  }
}

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int screenIndex = 0;
  final List<Widget> _body = [const LoadPatchFile(), const Settings()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text("Patch2PDF"),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      drawer: NavigationDrawer(
        backgroundColor: Theme.of(context).colorScheme.background,
        indicatorColor: Theme.of(context).colorScheme.tertiary,
        selectedIndex: screenIndex,
        onDestinationSelected: (int index) {
          setState(() {
            screenIndex = index;
          });
          Navigator.pop(context);
        },
        children: [
          NavigationDrawerDestination(
            icon: Icon(Icons.home, color: Theme.of(context).colorScheme.onBackground),
            label: Text(
              "Home",
              style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
            ),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.settings, color: Theme.of(context).colorScheme.onBackground),
            label: Text(
              "Settings",
              style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
            ),
          ),
        ],
      ),
      body: _body[screenIndex],
    );
  }
}

class LoadPatchFile extends StatefulWidget {
  const LoadPatchFile({super.key});

  @override
  State<LoadPatchFile> createState() => _LoadPatchFileState();
}

class _LoadPatchFileState extends State<LoadPatchFile> {
  bool _dragging = false;
  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (detail) {
        XFile droppedfile = detail.files.first;
        String extension = p.extension(droppedfile.path);
        if (extension.toLowerCase() == ".json" || extension.toLowerCase() == ".csv" || extension.toLowerCase() == ".xml") {
          setState(() {
            droppedfile.readAsString().then(
                  (value) => handlePatchFileString(value, extension, context),
                );
          });
        } else {
          final snackBar = SnackBar(
            behavior: SnackBarBehavior.floating,
            width: 400.0,
            content: const Text('Only json, csv and xml are allowed.'),
            action: SnackBarAction(
              label: 'Close',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          );

          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      },
      onDragEntered: (detail) {
        setState(() {
          _dragging = true;
        });
      },
      onDragExited: (detail) {
        setState(() {
          _dragging = false;
        });
      },
      child: Builder(
        builder: (context) => InkWell(
          onTap: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ["json", "csv", "xml"]);
            if (result != null) {
              File file = File(result.files.single.path!);
              String extension = p.extension(file.path);
              file.readAsString().then(
                    (value) => handlePatchFileString(value, extension, context),
                  );
            }
          },
          child: Container(
            height: double.infinity,
            color: (_dragging) ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.background,
            child: Center(
              child: Text(
                "Upload Patchfile",
                style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LayerConfig extends StatefulWidget {
  const LayerConfig({
    super.key,
    required this.patchdata,
  });
  final PatchData patchdata;

  @override
  State<LayerConfig> createState() => _LayerConfigState();
}

class _LayerConfigState extends State<LayerConfig> {
  int selectedLogoIndex = patch2pdfconfig.defaultlogoindex;
  final Map<String, List<bool>> layerSwitchStates = {};

  void _updateLogoIndex(int newvalue) {
    selectedLogoIndex = newvalue;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> layerlist = widget.patchdata.data.groups!.keys.toList();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text("Layerconfigs"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30, top: 10),
        child: Column(
          children: [
            LogoSelector(patch2pdfconfig: patch2pdfconfig, onChangeCallBack: _updateLogoIndex),
            const Padding(padding: EdgeInsets.only(top: 20)),
            MediaQuery.of(context).size.width < 900
                ? MobileLayerConfig(
                    patch2pdfconfig: patch2pdfconfig,
                    layers: layerlist,
                    switchStates: layerSwitchStates,
                  )
                : NormalLayerConfig(
                    patch2pdfconfig: patch2pdfconfig,
                    layers: layerlist,
                    switchStates: layerSwitchStates,
                  ),
            const Padding(padding: EdgeInsets.only(top: 30)),
            Center(
              child: ElevatedButton(
                style: ButtonStyle(foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.onSecondary), backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.secondary), padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 30, vertical: 20))),
                child: const Text(
                  "Generate PDF",
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PatchPDFViewer(
                        patchdata: widget.patchdata,
                        selectedLogo: patch2pdfconfig.logos[selectedLogoIndex],
                        layerSwitchStates: layerSwitchStates,
                        patch2pdfconfig: patch2pdfconfig,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LogoSelector extends StatefulWidget {
  const LogoSelector({super.key, required this.patch2pdfconfig, required this.onChangeCallBack});
  final Patch2PDFConfig patch2pdfconfig;
  final Function(int) onChangeCallBack;

  @override
  State<LogoSelector> createState() => _LogoSelectorState();
}

class _LogoSelectorState extends State<LogoSelector> {
  List<DropdownMenuItem> logos = [];
  int selectedValue = 0;

  @override
  void initState() {
    selectedValue = (widget.patch2pdfconfig.defaultlogoindex < widget.patch2pdfconfig.logos.length) ? widget.patch2pdfconfig.defaultlogoindex : 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    logos = List<DropdownMenuItem>.generate(widget.patch2pdfconfig.logos.length, (index) {
      File image = File("${appDocDirectory!.path}/${widget.patch2pdfconfig.logos[index].path}");
      return DropdownMenuItem(
        value: index,
        child: Row(children: [
          if (image.existsSync()) Image(image: FileImage(image), height: 20),
          const Padding(padding: EdgeInsets.only(right: 10)),
          Text(
            widget.patch2pdfconfig.logos[index].displayName,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
        ]),
      );
    });
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).colorScheme.secondary,
        ),
        child: DropdownButton(
          onChanged: (value) {
            if (value != null) {
              widget.onChangeCallBack(value);
            }
            setState(() {
              selectedValue = value;
            });
          },
          dropdownColor: Theme.of(context).colorScheme.secondary,
          enableFeedback: true,
          iconEnabledColor: Theme.of(context).colorScheme.onSecondary,
          value: selectedValue,
          borderRadius: BorderRadius.circular(15),
          items: logos,
        ),
      ),
    );
  }
}
