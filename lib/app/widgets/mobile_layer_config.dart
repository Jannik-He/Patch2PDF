import 'package:flutter/material.dart';
import 'package:patch2pdf/app/classes/patch_2_pdf_config.dart';

class MobileLayerConfig extends StatefulWidget {
  const MobileLayerConfig({
    super.key,
    required this.patch2pdfconfig,
    required this.layers,
    required this.switchStates
  });
  final Patch2PDFConfig? patch2pdfconfig;
  final List<String> layers;
  final Map<String, List<bool>> switchStates;

  @override
  State<MobileLayerConfig> createState() => _MobileLayerConfigState();
}

class _MobileLayerConfigState extends State<MobileLayerConfig> {
  List<TableHeaderConfig>? standardswitch;
  List<ExpansionPanelItem> _data = [];

  @override
  void initState() {
    standardswitch = widget.patch2pdfconfig!.headerconfigs;
    _data = generateItems(widget.layers);
    super.initState();
  }

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
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _data[index].isExpanded = isExpanded;
        });
      },
      expandedHeaderPadding: const EdgeInsets.all(0),
      materialGapSize: 20,
      dividerColor: Theme.of(context).colorScheme.background,
      children: _data.map<ExpansionPanel>((ExpansionPanelItem item) {
        if (widget.switchStates[item.layername] == null) {
          widget.switchStates[item.layername] = List<bool>.generate(standardswitch!.length, (int index) {
            return standardswitch![index].enabled;
          });
        }
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(
                item.headerValue,
                style: TextStyle(
                  color: item.isExpanded ? Theme.of(context).colorScheme.onSecondary : Theme.of(context).colorScheme.onTertiary,
                ),
              ),
            );
          },
          backgroundColor: item.isExpanded ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.tertiary,
          canTapOnHeader: true,
          body: ListTile(
            title: Column(
              children: <Widget>[
                generateMobileLayerConfigSwitches(item.index, widget.switchStates[item.layername]!, standardswitch!, widget.switchStates, switchCallback),
              ],
              //title: Text(item.expandedValue),
            ),
          ),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }
}

class MobileLayerConfigSwitch extends StatefulWidget {
  const MobileLayerConfigSwitch({super.key, required this.layerindex, required this.statesList, required this.tableHeaders, required this.switchStates, this.switchCallback});
  final int layerindex;
  final List<bool> statesList;
  final List<TableHeaderConfig> tableHeaders;
  final Map<String, List<bool>> switchStates;

  final Function(int, List<bool>, Map<String, List<bool>>, int, bool)? switchCallback;

  @override
  State<MobileLayerConfigSwitch> createState() => _MobileLayerConfigSwitchState();
}

class _MobileLayerConfigSwitchState extends State<MobileLayerConfigSwitch> {
  @override
  Widget build(BuildContext context) {
    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: List<TableRow>.generate(widget.tableHeaders.length, (int index) {
        return TableRow(children: [
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              padding: const EdgeInsets.only(left: 10, right: 5),
              alignment: Alignment.centerRight,
              child: Text(
                widget.tableHeaders[index].name,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 5, right: 10),
            child: Switch.adaptive(
              inactiveTrackColor: Colors.red,
              value: widget.statesList[index],
              onChanged: (value) {
                if(widget.switchCallback != null){
                  widget.switchCallback!(widget.layerindex, widget.statesList, widget.switchStates, index, value);
                }else{
                  setState(() {
                    widget.statesList[index] = value;
                  });
                }
              },
            ),
          ),
        ]);
      }),
    );
  }
}

Widget generateMobileLayerConfigSwitches(int layerindex, List<bool> statesList, List<TableHeaderConfig> tableHeaders, Map<String, List<bool>> switchStates, Function(int, List<bool>, Map<String, List<bool>>, int, bool)? callback) {
  return MobileLayerConfigSwitch(layerindex: layerindex, statesList: statesList, tableHeaders: tableHeaders, switchStates: switchStates, switchCallback: callback,);
}

class ExpansionPanelItem {
  ExpansionPanelItem({
    required this.headerValue,
    required this.index,
    required this.layername,
    this.isExpanded = false,
  });

  String headerValue;
  String layername;
  int index;
  bool isExpanded;
}

List<ExpansionPanelItem> generateItems(List<String> layers) {
  return List<ExpansionPanelItem>.generate(layers.length + 1, (int index) {
    return ExpansionPanelItem(
      headerValue: (index == 0) ? 'Global' : layers[index - 1],
      index: index,
      layername: (index == 0) ? "Global" : layers[index - 1],
    );
  });
}
