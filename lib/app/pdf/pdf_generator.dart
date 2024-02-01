import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:patch2pdf/app/classes/ma_objects.dart';
import 'package:patch2pdf/app/classes/patch_2_pdf_config.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<Uint8List> createPatchPDF(PatchData patchdata, Logo selectedLogo, final Map<String, List<bool>> layerSwitchStates, Patch2PDFConfig patch2pdfconfig) async {
  pw.Font fontRegular = pw.Font.ttf(await rootBundle.load("assets/fonts/Arial Unicode MS.TTF"));
  pw.Font fontBold = pw.Font.ttf(await rootBundle.load("assets/fonts/Arial-Unicode-Bold.ttf"));
  Uint8List logo = File("${appDocDirectory!.path}/${selectedLogo.path}").readAsBytesSync();
  final pw.Document pdf = pw.Document(
    theme: pw.ThemeData(
      defaultTextStyle: pw.TextStyle(
        font: fontRegular,
        fontSize: 9,
      ),
    ),
    title: patchdata.showName,
    author: "Patch2PDF",
  );
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(vertical: 15, horizontal: 40),
      header: (context) {
        return pw.Header(
          padding: const pw.EdgeInsets.only(bottom: 0),
          margin: const pw.EdgeInsets.only(bottom: 0),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.white)),
          child: pw.Column(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Patchplan", style: pw.TextStyle(fontSize: 25, font: fontBold)),
                    pw.SizedBox(
                      height: 40,
                      width: 150,
                      child: pw.Image(pw.MemoryImage(logo), fit: pw.BoxFit.contain),
                    ),
                  ],
                ),
              ),
              pw.Container(
                height: 10,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(
                      color: PdfColors.black,
                      width: 1,
                    ),
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 10, left: 10, right: 10),
                child: pw.Table(
                  border: pw.TableBorder.symmetric(
                    inside: pw.BorderSide.none,
                    outside: const pw.BorderSide(
                      color: PdfColors.black,
                      width: 1,
                    ),
                  ),
                  defaultColumnWidth: const pw.FractionColumnWidth(0.5),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          child: pw.Row(
                            children: [
                              pw.Text("Show:", style: pw.TextStyle(font: fontBold, fontSize: 11)),
                              pw.Text(" ${patchdata.showName}", style: const pw.TextStyle(fontSize: 11)),
                            ],
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          child: pw.Row(
                            children: [
                              pw.Text("Export Date:", style: pw.TextStyle(font: fontBold, fontSize: 11)),
                              pw.Text(" ${(patchdata.exportTime != null) ? DateFormat('yyyy-MM-dd kk:mm').format(patchdata.exportTime!) : DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now())}", style: const pw.TextStyle(fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      footer: (context) {
        return pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 0),
            child: pw.RichText(
              text: pw.TextSpan(
                text: 'Patch2PDF',
                style: pw.TextStyle(font: fontBold, fontSize: 8),
                children: <pw.TextSpan>[
                  pw.TextSpan(text: ' by Jannik Heym', style: pw.TextStyle(font: fontRegular)),
                ],
              ),
            ),
          ),
          pw.Container(
            child: pw.Padding(
              padding: const pw.EdgeInsets.only(left: 10),
              child: pw.Text(
                "${context.pageNumber}/${context.pagesCount}",
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(fontSize: 8, font: fontBold),
              ),
            ),
          )
        ]);
      },
      build: (context) {
        List<pw.Widget> tables = [];
        if (patchdata.data.fixtures != null && patchdata.data.fixtures!.isNotEmpty) {
          Group group = Group(name: "", index: 0, fixtures: patchdata.data.fixtures); //Ungrouped Fixtures currently use global setting
          tables.add(pw.Padding(padding: const pw.EdgeInsets.only(top: 5), child: _generateTable(group: group, layerSwitchStates: layerSwitchStates["Global"]!, patch2pdfconfig: patch2pdfconfig, fontBold: fontBold, fontRegular: fontRegular)));
        }
        if (patchdata.data.groups != null && patchdata.data.groups!.isNotEmpty) {
          for (Group group in patchdata.data.groups!.values) {
            tables.add(pw.Padding(padding: const pw.EdgeInsets.only(top: 5), child: _generateTable(group: group, layerSwitchStates: layerSwitchStates[group.name]!, patch2pdfconfig: patch2pdfconfig, fontBold: fontBold, fontRegular: fontRegular)));
          }
        }
        return [
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 10, right: 10, top: 0),
            child: pw.Column(
              children: tables,
            ),
          ),
        ];
      },
    ),
  );
  return pdf.save();
}

pw.Column _generateTable({required Group group, required List<bool> layerSwitchStates, required Patch2PDFConfig patch2pdfconfig, required pw.Font fontRegular, required pw.Font fontBold}) {
  //TODO: break table when bigger than 1 page
  pw.EdgeInsets tableCellPadding = const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1);
  List<pw.Widget> columnChildren = [];
  if (group.fixtures != null && group.fixtures!.isNotEmpty) {
    List<pw.TableRow> tableRows = [];
    List<pw.Widget> headers = [];
    //Map<int, pw.TableColumnWidth>? columnWidths = {};
    for (int i = 0; i < layerSwitchStates.length; i++) {
      if (layerSwitchStates[i]) {
        TableHeaderConfig headerconfig = patch2pdfconfig.headerconfigs[i];
        headers.add(
          pw.Padding(
            padding: tableCellPadding,
            child: pw.Text(
              headerconfig.name,
              style: pw.TextStyle(
                color: PdfColor.fromHex("#ffffff"),
              ),
            ),
          ),
        );
        /* if(headerconfig.name.toLowerCase() == "dippatch"){
          columnWidths.addAll({i: const pw.FractionColumnWidth(10)});
        }else{
        double? width = double.tryParse(headerconfig.width);
        if (width == null) {
          columnWidths.addAll({i: const pw.FractionColumnWidth(10)});
          print(headerconfig.name);
        } else {
          columnWidths.addAll({i: pw.FractionColumnWidth(10)});
        }
        } */
      }
    }
    tableRows.add(pw.TableRow(decoration: pw.BoxDecoration(color: PdfColor.fromHex("#707070")), children: headers));
    for (Fixture fixture in group.fixtures!) {
      List<pw.Widget> row = [];
      for (int i = 0; i < layerSwitchStates.length; i++) {
        if (layerSwitchStates[i]) {
          TableHeaderConfig headerconfig = patch2pdfconfig.headerconfigs[i];
          late pw.TextAlign alignment;
          if (headerconfig.valAlignment.toLowerCase() == "right") {
            alignment = pw.TextAlign.right;
          } else if (headerconfig.valAlignment.toLowerCase() == "center") {
            alignment = pw.TextAlign.center;
          } else {
            alignment = pw.TextAlign.left;
          }
          if (headerconfig.parserVar.toLowerCase() == "fixtureid") {
            row.add(
              pw.Container(
                color: (tableRows.length % 2 == 1) ? PdfColor.fromHex("#dedede") : PdfColors.white,
                padding: tableCellPadding,
                child: pw.Text("${fixture.fixtureID ?? ""}", textAlign: alignment),
              ),
            );
          } else if (headerconfig.parserVar.toLowerCase() == "channelid") {
            row.add(
              pw.Container(
                color: (tableRows.length % 2 == 1) ? PdfColor.fromHex("#dedede") : PdfColors.white,
                padding: tableCellPadding,
                child: pw.Text("${(fixture.channelID != null) ? fixture.channelID : ""}", textAlign: alignment),
              ),
            );
          } else if (headerconfig.parserVar.toLowerCase() == "patch") {
            row.add(
              pw.Container(
                color: (tableRows.length % 2 == 1) ? PdfColor.fromHex("#dedede") : PdfColors.white,
                padding: tableCellPadding,
                child: pw.Text(fixture.patch, textAlign: alignment),
              ),
            );
          } else if (headerconfig.parserVar.toLowerCase() == "dippatch") {
            row.add(
              pw.Container(
                color: (tableRows.length % 2 == 1) ? PdfColor.fromHex("#dedede") : PdfColors.white,
                padding: tableCellPadding,
                child: pw.Text("${(fixture.dipPatch != null) ? fixture.dipPatch : ""}", textAlign: alignment),
              ),
            );
          } else if (headerconfig.parserVar.toLowerCase() == "name") {
            row.add(
              pw.Container(
                color: (tableRows.length % 2 == 1) ? PdfColor.fromHex("#dedede") : PdfColors.white,
                padding: tableCellPadding,
                child: pw.Text(fixture.name, textAlign: alignment),
              ),
            );
          } else if (headerconfig.parserVar.toLowerCase() == "fixturetype") {
            row.add(
              pw.Container(
                color: (tableRows.length % 2 == 1) ? PdfColor.fromHex("#dedede") : PdfColors.white,
                padding: tableCellPadding,
                child: pw.Text(fixture.fixtureType, textAlign: alignment),
              ),
            );
          } else if (headerconfig.specialType.toLowerCase() == "position") {
            row.add(
              pw.Container(
                color: (tableRows.length % 2 == 1) ? PdfColor.fromHex("#dedede") : PdfColors.white,
                padding: tableCellPadding,
                child: pw.Text((fixture.position != null) ? fixture.position!.toPDFString() : "", textAlign: alignment),
              ),
            );
          }
        }
      }
      tableRows.add(
        pw.TableRow(
          children: row,
        ),
      );
    }
    columnChildren.add(
      pw.Column(
        children: [
          pw.Align(
            alignment: pw.Alignment.centerLeft,
            child: pw.Padding(padding: const pw.EdgeInsets.only(bottom: 2), child: pw.Text(group.name, textAlign: pw.TextAlign.left, style: pw.TextStyle(fontSize: 11, font: fontBold))),
          ),
          pw.Table(
            //defaultColumnWidth: pw.FixedColumnWidth(100),
            defaultVerticalAlignment: pw.TableCellVerticalAlignment.full,
            border: pw.TableBorder.all(width: 1, color: PdfColors.black),
            //columnWidths: columnWidths, // bugged for some reason
            children: tableRows,
          )
        ],
      ),
    );
  }
  if (group.subgroups != null && group.subgroups!.isNotEmpty) {
    for (Group subgroup in group.subgroups!) {
      columnChildren.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 20, top: 5),
          child: _generateTable(group: subgroup, layerSwitchStates: layerSwitchStates, patch2pdfconfig: patch2pdfconfig, fontBold: fontBold, fontRegular: fontRegular),
        ),
      );
    }
  }
  return pw.Column(
    children: columnChildren,
  );
}
