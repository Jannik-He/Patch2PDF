import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:patch2pdf/app/classes/ma_objects.dart';
import 'package:patch2pdf/app/classes/patch_2_pdf_config.dart';
import 'package:printing/printing.dart';
import 'package:patch2pdf/app/pdf/pdf_generator.dart';
import 'dart:io' show Platform, File;
import 'package:file_picker/file_picker.dart';

class PatchPDFViewer extends StatefulWidget {
  const PatchPDFViewer({
    super.key,
    required this.patchdata,
    required this.selectedLogo,
    required this.layerSwitchStates,
    required this.patch2pdfconfig,
  });
  final PatchData patchdata;
  final Logo selectedLogo;
  final Map<String, List<bool>> layerSwitchStates;
  final Patch2PDFConfig patch2pdfconfig;

  @override
  State<PatchPDFViewer> createState() => _PatchPDFViewerState();
}

class _PatchPDFViewerState extends State<PatchPDFViewer> {
  @override
  Widget build(BuildContext context) {
    Future<Uint8List> patchPDF = createPatchPDF(widget.patchdata, widget.selectedLogo, widget.layerSwitchStates, widget.patch2pdfconfig);
    bool isDesktop = Platform.isMacOS || Platform.isWindows || Platform.isLinux;
    List<Widget>? btns = (isDesktop)
        ? ([
            IconButton(
                onPressed: () async {
                  String? result = await FilePicker.platform.saveFile(
                    allowedExtensions: [".pdf"],
                    fileName: "${widget.patchdata.showName}.pdf",
                  );
                  if (result != null) {
                    File(result).writeAsBytes(await patchPDF);
                  }
                },
                icon: Icon(
                  Icons.download,
                  color: Theme.of(context).colorScheme.onPrimary,
                )),
          ])
        : ([]);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text("Layerconfigs"),
      ),
      body: PdfPreview(
        build: (format) => patchPDF,
        canChangeOrientation: false,
        canDebug: false,
        allowPrinting: true,
        allowSharing: (isDesktop) ? false : true,
        canChangePageFormat: false,
        actions: btns,
        pdfFileName: "${widget.patchdata.showName}.pdf",
      ),
    );
  }
}
