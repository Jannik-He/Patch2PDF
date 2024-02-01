import 'package:flutter/material.dart';
import 'package:patch2pdf/app/classes/patch_2_pdf_config.dart';

class NormalLayerConfig extends StatefulWidget {
  const NormalLayerConfig({
    super.key,
    required this.patch2pdfconfig,
    required this.layers,
    required this.switchStates,
  });
  final Patch2PDFConfig? patch2pdfconfig;
  final List<String> layers;
  final Map<String, List<bool>> switchStates;

  @override
  State<NormalLayerConfig> createState() => _NormalLayerConfigState();
}

class _NormalLayerConfigState extends State<NormalLayerConfig> {
  List<TableHeaderConfig>? standardswitch;

  void switchCallback(int layerindex, List<bool> statesList, Map<String, List<bool>> switchStates, int index, bool value) {
    setState(() {
      if (layerindex == 0) {
        for (String entry in switchStates.keys) {
          switchStates[entry]![index] = value;
        }
      } else if (layerindex > 0) {
        statesList[index] = value;
      }
    });
  }

  @override
  void initState() {
    standardswitch = widget.patch2pdfconfig!.headerconfigs;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Container>.generate(
        widget.layers.length + 1,
        (int index) {
          if (widget.switchStates[(index > 0)?(widget.layers[index-1]):("Global")] == null) {
            widget.switchStates[(index > 0)?(widget.layers[index-1]):("Global")] = List<bool>.generate(standardswitch!.length, (int index) {
              return standardswitch![index].enabled;
            });
          }
          return Container(
            padding: const EdgeInsets.only(top: 10, left: 50, right: 50),
            child: Center(
              child: Table(
                defaultColumnWidth: const IntrinsicColumnWidth(),
                children: [
                  TableRow(children: [
                    Text(
                      (index == 0) ? "Global" : widget.layers[index - 1],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: Theme.of(context).textTheme.headlineSmall?.fontSize,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ]),
                  TableRow(children: [
                    generateNormalLayerConfigSwitches(index, widget.switchStates[(index > 0)?(widget.layers[index-1]):("Global")]!, standardswitch!, widget.switchStates, switchCallback),
                  ]),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

Widget generateNormalLayerConfigSwitches(int layerindex, List<bool> statesList, List<TableHeaderConfig> tableHeaders, Map<String, List<bool>> switchStates, Function(int, List<bool>, Map<String, List<bool>>, int, bool)? callback) {
  return NormalLayerConfigSwitch(
    layerindex: layerindex,
    statesList: statesList,
    tableHeaders: tableHeaders,
    switchStates: switchStates,
    switchCallback: callback,
  );
}

class NormalLayerConfigSwitch extends StatefulWidget {
  const NormalLayerConfigSwitch({super.key, required this.layerindex, required this.statesList, required this.tableHeaders, required this.switchStates, this.switchCallback});
  final int layerindex;
  final List<bool> statesList;
  final List<TableHeaderConfig> tableHeaders;
  final Map<String, List<bool>> switchStates;

  final Function(int, List<bool>, Map<String, List<bool>>, int, bool)? switchCallback;

  @override
  State<NormalLayerConfigSwitch> createState() => _NormalLayerConfigSwitchState();
}

class _NormalLayerConfigSwitchState extends State<NormalLayerConfigSwitch> {
  @override
  Widget build(BuildContext context) {
    final List<TableCell> headers = [];
    final List<TableCell> switches = [];
    for (var entry in widget.tableHeaders) {
      int index = widget.tableHeaders.indexOf(entry);
      /* AlignmentGeometry alignment;
      switch (entry.valAlignment) {
        case ("center"):
          alignment = Alignment.center;
          break;
        case ("right"):
          alignment = Alignment.centerRight;
          break;
        default:
          alignment = Alignment.centerLeft;
          break;
      } */
      headers.add(
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            alignment: Alignment.center,
            child: Text(entry.name,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onBackground,
                )),
          ),
        ),
      );
      switches.add(
        TableCell(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Switch.adaptive(
              inactiveTrackColor: Colors.red,
              mouseCursor: SystemMouseCursors.click,
              value: widget.statesList[index],
              onChanged: (value) {
                if (widget.switchCallback != null) {
                  widget.switchCallback!(widget.layerindex, widget.statesList, widget.switchStates, index, value);
                } else {
                  widget.statesList[index] = value;
                }
              },
            ),
          ),
        ),
      );
    }
    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      border: TableBorder(
        verticalInside: BorderSide(
          color: Theme.of(context).colorScheme.onBackground,
        ),
        horizontalInside: BorderSide(
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
      columnWidths: const {
        //3: FlexColumnWidth(1.1),
        //4: FlexColumnWidth(1.5),
        //5: FlexColumnWidth(1.5),
        //6: FlexColumnWidth(1.8),
      },
      children: [
        TableRow(children: headers),
        TableRow(children: switches),
      ],
    );
  }
}
