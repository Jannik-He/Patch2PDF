import "dart:io";
import 'package:flutter/material.dart';
import 'package:patch2pdf/app/classes/patch_2_pdf_config.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/services.dart';
import 'package:patch2pdf/app/widgets/mobile_layer_config.dart';
import 'package:patch2pdf/main.dart';
import 'package:path/path.dart' as p;

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

late List<bool> defaultConfigSwitchStates;

class _SettingsState extends State<Settings> {
  bool _needtosavechange = false;

  void updateSwitchStates(List<bool> switchStates) {
    setState(() {
      defaultConfigSwitchStates = switchStates;
    });
    _needtosavechange = false;
  }

  void updateConfig(List<bool> defaultConfigSwitchStates) {
    setState(() {
      for (int i = 0; i < defaultConfigSwitchStates.length; i++) {
        patch2pdfconfig.headerconfigs[i].enabled = defaultConfigSwitchStates[i];
      }
      _needtosavechange = false;
    });
  }

  void hideAbortBtn(int layerindex, List<bool> statesList, Map<String, List<bool>> switchStates, int index, bool value) {
    setState(() {
      _needtosavechange = true;
      statesList[index] = value;
    });
  }

  void refreshPatchData(Patch2PDFConfig newconfig) {
    setState(() {
      patch2pdfconfig = newconfig;
      saveConfig(newconfig);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30, top: 10, left: 30, right: 30),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              // add title for default config
              // ignore: prefer_const_constructors
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Default PDF Table config",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 18,
                      ),
                    ),
                    DefaultConfig(
                      callBack: hideAbortBtn,
                    ),
                    (_needtosavechange)
                        ? Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _AbortConfigBtn(
                                  clickCallback: updateSwitchStates,
                                ),
                                _SaveConfigBtn(
                                  clickCallback: updateConfig,
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Default Logo Selector",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 18,
                      ),
                    ),
                    DefaultLogoSelector(
                      patch2pdfconfig: patch2pdfconfig,
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Custom Logo Upload",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 18,
                      ),
                    ),
                    LogoUpload(
                      refreshPatchDataCallBack: refreshPatchData,
                    ),
                  ],
                ),
              ),
              if(patch2pdfconfig.logos.length > 1)
              const Padding(
                padding: EdgeInsets.only(top: 20),
              ),
              if(patch2pdfconfig.logos.length > 1)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Manage custom logos",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 18,
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(top: 10)),
                    EditLogo(
                      logos: patch2pdfconfig.logos,
                      refreshPatchDataCallBack: refreshPatchData,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

class DefaultConfig extends StatefulWidget {
  const DefaultConfig({super.key, this.callBack});

  final Function(int, List<bool>, Map<String, List<bool>>, int, bool)? callBack;

  @override
  State<DefaultConfig> createState() => _DefaultConfigState();
}

class _DefaultConfigState extends State<DefaultConfig> {
  late List<TableHeaderConfig> _standardswitch = patch2pdfconfig.headerconfigs;

  @override
  void initState() {
    defaultConfigSwitchStates = List<bool>.generate(_standardswitch.length, (int index) {
      return _standardswitch[index].enabled;
    });
    readConfig().then((value) {
      setState(() {
        _standardswitch = value.headerconfigs;
        defaultConfigSwitchStates = List<bool>.generate(_standardswitch.length, (int index) {
          return _standardswitch[index].enabled;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: /* MediaQuery.of(context).size.width < 900
          ? */
            MobileLayerConfigSwitch(
          layerindex: 1,
          statesList: defaultConfigSwitchStates,
          tableHeaders: _standardswitch,
          switchStates: const {},
          switchCallback: widget.callBack,
        )
        /* : NormalLayerConfigSwitch(
              layerindex: 1,
              statesList: defaultConfigSwitchStates,
              tableHeaders: _standardswitch,
              switchStates: const {},
              switchCallback: widget.callBack,
            ), */
        );
  }
}

class _AbortConfigBtn extends StatefulWidget {
  const _AbortConfigBtn({required this.clickCallback});

  final Function(List<bool>) clickCallback;

  @override
  State<_AbortConfigBtn> createState() => _AbortConfigBtnState();
}

class _AbortConfigBtnState extends State<_AbortConfigBtn> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: ElevatedButton(
        onPressed: () {
          readConfig().then(
            (value) {
              widget.clickCallback(
                List<bool>.generate(value.headerconfigs.length, (int index) {
                  return value.headerconfigs[index].enabled;
                }),
              );
            },
          );
        },
        style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.primary),
        ),
        child: Text("Abort", style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
      ),
    );
  }
}

class _SaveConfigBtn extends StatefulWidget {
  const _SaveConfigBtn({required this.clickCallback});

  final Function(List<bool>) clickCallback;

  @override
  State<_SaveConfigBtn> createState() => __SaveConfigBtnState();
}

class __SaveConfigBtnState extends State<_SaveConfigBtn> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: ElevatedButton(
        onPressed: () {
          widget.clickCallback(defaultConfigSwitchStates);
          saveConfig(patch2pdfconfig);
        },
        style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.primary),
          padding: const MaterialStatePropertyAll(EdgeInsets.only(left: 20, right: 20)),
        ),
        child: Text("Save", style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
      ),
    );
  }
}

class DefaultLogoSelector extends StatefulWidget {
  const DefaultLogoSelector({super.key, required this.patch2pdfconfig});
  final Patch2PDFConfig patch2pdfconfig;

  @override
  State<DefaultLogoSelector> createState() => _DefaultLogoSelectorState();
}

class _DefaultLogoSelectorState extends State<DefaultLogoSelector> {
  List<DropdownMenuItem> logos = [];
  int selectedValue = 0;

  @override
  Widget build(BuildContext context) {
    selectedValue = (widget.patch2pdfconfig.defaultlogoindex < widget.patch2pdfconfig.logos.length) ? widget.patch2pdfconfig.defaultlogoindex : 0;
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
      child: _dropDown(),
    );
  }

  Widget _dropDown() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).colorScheme.secondary,
      ),
      child: DropdownButton(
        onChanged: (value) {
          if (value != null) {
            patch2pdfconfig.defaultlogoindex = value;
            saveConfig(patch2pdfconfig);
            setState(() {
              selectedValue = value;
            });
          }
        },
        dropdownColor: Theme.of(context).colorScheme.secondary,
        enableFeedback: true,
        iconEnabledColor: Theme.of(context).colorScheme.onSecondary,
        value: selectedValue,
        borderRadius: BorderRadius.circular(15),
        items: logos,
      ),
    );
  }
}

class LogoUpload extends StatefulWidget {
  const LogoUpload({super.key, required this.refreshPatchDataCallBack});

  final Function(Patch2PDFConfig) refreshPatchDataCallBack;

  @override
  State<LogoUpload> createState() => _LogoUploadState();
}

class _LogoUploadState extends State<LogoUpload> {
  String logoDisplayName = "";

  Uint8List? logoUploadData;
  String logoUploadExtension = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: _imgUpload(),
        ),
        if (logoUploadData != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiary,
                borderRadius: BorderRadius.circular(15),
              ),
              child: _uploadPreviewAndSave(logoUploadData!),
            ),
          ),
      ],
    );
  }

  Widget _imgUpload() {
    bool dragging = false;

    return DropTarget(
      onDragDone: (detail) {
        XFile droppedfile = detail.files.first;
        String extension = p.extension(droppedfile.path);
        if (extension.toLowerCase() == ".jpg" || extension.toLowerCase() == ".jpeg" || extension.toLowerCase() == ".png" || extension.toLowerCase() == ".webp") {
          droppedfile.readAsBytes().then(
            (value) {
              setState(() {
                logoUploadExtension = p.extension(droppedfile.path);
                logoUploadData = value;
              });
            },
          );
        } else {
          final snackBar = SnackBar(
            behavior: SnackBarBehavior.floating,
            width: 400.0,
            content: const Text('Only jpg, jpeg, webp and png are allowed.'),
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
          dragging = true;
        });
      },
      onDragExited: (detail) {
        setState(() {
          dragging = false;
        });
      },
      child: Builder(
        builder: (context) => InkWell(
          onTap: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ["jpg", "jpeg", "png", "webp"]);
            if (result != null) {
              File file = File(result.files.single.path!);
              file.readAsBytes().then(
                (value) {
                  setState(() {
                    logoUploadData = value;
                  });
                },
              );
            }
          },
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: (dragging) ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.secondary,
            ),
            child: Text(
              "Upload own logo",
              style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _uploadPreviewAndSave(Uint8List imageBytes) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: ColoredBox(
            color: Colors.white,
            child: Image(
              image: MemoryImage(imageBytes),
              width: 200,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            width: 200,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(15),
            ),
            child: TextField(
              onChanged: (value) {
                logoDisplayName = value;
              },
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
              ),
              autocorrect: false,
              decoration: InputDecoration(
                hintText: "Dropdown Name",
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
                filled: false,
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _abortBtn(),
                _saveBtn(),
              ],
            )),
      ],
    );
  }

  Widget _saveBtn() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: ElevatedButton(
        onPressed: () {
          //clear preview and hide buttons again
          String path = "logos/${DateTime.now().millisecondsSinceEpoch}$logoUploadExtension";
          File("${appDocDirectory!.path}/$path").writeAsBytes(logoUploadData!);
          Patch2PDFConfig tempconfig = patch2pdfconfig;
          setState(() {
            tempconfig.logos.add(
              Logo(
                displayName: logoDisplayName,
                path: path,
              ),
            );
            logoUploadData = null;
            logoDisplayName = "";
          });
          widget.refreshPatchDataCallBack(tempconfig);
        },
        style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.secondary),
          padding: const MaterialStatePropertyAll(EdgeInsets.only(left: 20, right: 20)),
        ),
        child: Text("Save", style: TextStyle(color: Theme.of(context).colorScheme.onSecondary)),
      ),
    );
  }

  Widget _abortBtn() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            //clear preview
            logoUploadData = null;
            logoDisplayName = "";
          });
        },
        style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.secondary),
          padding: const MaterialStatePropertyAll(EdgeInsets.only(left: 20, right: 20)),
        ),
        child: Text("Abort", style: TextStyle(color: Theme.of(context).colorScheme.onSecondary)),
      ),
    );
  }
}

class EditLogo extends StatefulWidget {
  const EditLogo({super.key, required this.logos, required this.refreshPatchDataCallBack});
  final List<Logo> logos;
  final Function(Patch2PDFConfig) refreshPatchDataCallBack;

  @override
  State<EditLogo> createState() => _EditLogoState();
}

class _EditLogoState extends State<EditLogo> {
  int? selectedIndex;
  String? logoDisplayName;
  TextEditingController logoNameInput = TextEditingController();
  TextEditingController logoDropDown = TextEditingController();

  bool editDisplayName = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: _dropDown(widget.logos),
            )
          ],
        ),
        if (selectedIndex != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _editSection(),
          ),
      ],
    );
  }

  Widget _dropDown(List<Logo> logos) {
    List<DropdownMenuEntry> entries = List<DropdownMenuEntry>.generate(
      logos.length - 1,
      (index) {
        File image = File("${appDocDirectory!.path}/${widget.logos[index + 1].path}");
        return DropdownMenuEntry(
          value: index + 1,
          label: logos[index + 1].displayName,
          leadingIcon: (image.existsSync())
              ? Image(
                  image: FileImage(
                    image,
                  ),
                  height: 20)
              : const SizedBox.shrink(),
          style: ButtonStyle(
            foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.onSecondary),
          ),
        );
      },
    );
    return DropdownMenu(
      controller: logoDropDown,
      leadingIcon: Icon(
        Icons.edit,
        color: Theme.of(context).colorScheme.onSecondary,
      ),
      enableFilter: true,
      enableSearch: true,
      requestFocusOnTap: true,
      menuStyle: MenuStyle(
        minimumSize: const MaterialStatePropertyAll(Size.fromWidth(200)),
        backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.secondary),
      ),
      textStyle: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
      onSelected: (value) {
        setState(() {
          selectedIndex = value;
          logoDisplayName = logos[value].displayName;
          logoNameInput.text = logoDisplayName!;
        });
      },
      inputDecorationTheme: InputDecorationTheme(
        fillColor: Theme.of(context).colorScheme.secondary,
        filled: true,
      ),
      dropdownMenuEntries: entries,
    );
  }

  Widget _editSection() {
    File preview = File("${appDocDirectory!.path}/${widget.logos[selectedIndex!].path}");
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.only(left: 0, right: 0, top: 15, bottom: 12),
      child: Column(
        children: [
          if (preview.existsSync())
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image(
                image: FileImage(preview),
                width: 200,
                fit: BoxFit.contain,
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  //Edit btn
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        editDisplayName = true;
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.secondary),
                      padding: const MaterialStatePropertyAll(EdgeInsets.only(left: 20, right: 20)),
                    ),
                    child: Text("Rename", style: TextStyle(color: Theme.of(context).colorScheme.onSecondary)),
                  ),
                ),
                Padding(
                  //Delete btn
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      File("${appDocDirectory!.path}/${patch2pdfconfig.logos[selectedIndex!].path}").delete();
                      Patch2PDFConfig tempconfig = patch2pdfconfig;
                      setState(() {
                        tempconfig.logos.removeAt(selectedIndex!);
                        logoDropDown.value = TextEditingValue.empty;
                        selectedIndex = null;
                        logoDisplayName = null;
                      });
                      widget.refreshPatchDataCallBack(tempconfig);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.secondary),
                      padding: const MaterialStatePropertyAll(EdgeInsets.only(left: 20, right: 20)),
                    ),
                    child: Text("Delete", style: TextStyle(color: Theme.of(context).colorScheme.onSecondary)),
                  ),
                ),
              ],
            ),
          ),
          if (editDisplayName)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: _textField(),
            ),
          if (editDisplayName)
            Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _abortBtn(),
                    _saveBtn(),
                  ],
                )),
        ],
      ),
    );
  }

  Widget _textField() {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(15),
        ),
        child: TextField(
          controller: logoNameInput,
          onChanged: (value) {
            logoDisplayName = value;
          },
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondary,
          ),
          autocorrect: false,
          decoration: InputDecoration(
            hintText: "Dropdown Name",
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
            filled: false,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _saveBtn() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: ElevatedButton(
        onPressed: () {
          //clear preview and hide buttons again
          if (logoDisplayName != null && logoDisplayName != "") {
            Patch2PDFConfig tempconfig = patch2pdfconfig;
            setState(() {
              tempconfig.logos[selectedIndex!].displayName = logoDisplayName!;
              logoDropDown.value = TextEditingValue.empty;
              selectedIndex = null;
              logoDisplayName = null;
              editDisplayName = false;
            });
            widget.refreshPatchDataCallBack(tempconfig);
          } else {
            final snackBar = SnackBar(
              behavior: SnackBarBehavior.floating,
              width: 400.0,
              content: const Text('Empty Name is not allowed'),
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
        style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.secondary),
          padding: const MaterialStatePropertyAll(EdgeInsets.only(left: 20, right: 20)),
        ),
        child: Text("Save", style: TextStyle(color: Theme.of(context).colorScheme.onSecondary)),
      ),
    );
  }

  Widget _abortBtn() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            //clear preview
            logoDropDown.value = TextEditingValue.empty;
            selectedIndex = null;
            logoDisplayName = null;
            editDisplayName = false;
          });
        },
        style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.secondary),
          padding: const MaterialStatePropertyAll(EdgeInsets.only(left: 20, right: 20)),
        ),
        child: Text("Abort", style: TextStyle(color: Theme.of(context).colorScheme.onSecondary)),
      ),
    );
  }
}
