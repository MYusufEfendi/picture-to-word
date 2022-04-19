import 'package:get/get.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:io';

import 'package:docx_template/src/template.dart';
import 'package:docx_template/src/model.dart';
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'dart:io';
import 'package:image/image.dart' as im;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';

class HomeController extends GetxController {
  var ocrText = ''.obs;
  var selectList = ["eng", "kor"];
  var path = ''.obs;
  var bload = false.obs;

  bool bDownloadtessFile = false;

  void runFilePiker() async {
    // android && ios only
    final pickedFile =
    await ImagePicker().getImage(source: ImageSource.gallery);
    print("picker path ${pickedFile?.path}");
    if (pickedFile != null) {
      ocr(pickedFile.path);
    }
  }

  void ocr(url) async {
    if (selectList.length <= 0) {
      print("Please select language");
      return;
    }
    path.value = url.toString();
    if (kIsWeb == false &&
        (url.indexOf("http://") == 0 || url.indexOf("https://") == 0)) {
      Directory tempDir = await getTemporaryDirectory();
      HttpClient httpClient = new HttpClient();
      HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
      HttpClientResponse response = await request.close();
      Uint8List bytes = await consolidateHttpClientResponseBytes(response);
      String dir = tempDir.path;
      print('$dir/test.jpg');
      File file = new File('$dir/test.jpg');
      await file.writeAsBytes(bytes);
      url = file.path;
    }
    var langs = selectList.join("+");

    bload.value = true;

    ocrText.value =
    await FlutterTesseractOcr.extractText(url, language: langs, args: {
      "preserve_interword_spaces": "1",
    });
    bload.value = false;
  }

  docxGenerate() async {
    final f = File("template.docx");
    final docx = await DocxTemplate.fromBytes(await f.readAsBytes());

    /*
    Or in the case of Flutter, you can use rootBundle.load, then get bytes

    final data = await rootBundle.load('lib/assets/users.docx');
    final bytes = data.buffer.asUint8List();

    final docx = await DocxTemplate.fromBytes(bytes);
  */

    // Load test image for inserting in docx
    final testFileContent = await File('test.jpg').readAsBytes();

    final listNormal = ['Foo', 'Bar', 'Baz'];
    final listBold = ['ooF', 'raB', 'zaB'];

    final contentList = <Content>[];

    final b = listBold.iterator;
    for (var n in listNormal) {
      b.moveNext();

      final c = PlainContent("value")
        ..add(TextContent("normal", n))..add(TextContent("bold", b.current));
      contentList.add(c);
    }

    Content c = Content();
    c..add(TextContent("docname", "Simple docname"))..add(
        TextContent("passport", "Passport NE0323 4456673"))..add(
        TableContent("table", [
          RowContent()
            ..add(TextContent("key1", "Paul"))..add(
              TextContent("key2", "Viberg"))..add(
              TextContent("key3", "Engineer"))..add(
              ImageContent('img', testFileContent)),
          RowContent()
            ..add(TextContent("key1", "Alex"))..add(
              TextContent("key2", "Houser"))..add(
              TextContent("key3", "CEO & Founder"))..add(
              ListContent("tablelist", [
                TextContent("value", "Mercedes-Benz C-Class S205"),
                TextContent("value", "Lexus LX 570")
              ]))..add(ImageContent('img', testFileContent))
        ]))..add(ListContent("list", [
      TextContent("value", "Engine")
        ..add(ListContent("listnested", contentList)),
      TextContent("value", "Gearbox"),
      TextContent("value", "Chassis")
    ]))..add(ListContent("plainlist", [
      PlainContent("plainview")
        ..add(TableContent("table", [
          RowContent()
            ..add(TextContent("key1", "Paul"))..add(
              TextContent("key2", "Viberg"))..add(
              TextContent("key3", "Engineer")),
          RowContent()
            ..add(TextContent("key1", "Alex"))..add(
              TextContent("key2", "Houser"))..add(
              TextContent("key3", "CEO & Founder"))..add(
              ListContent("tablelist", [
                TextContent("value", "Mercedes-Benz C-Class S205"),
                TextContent("value", "Lexus LX 570")
              ]))
        ])),
      PlainContent("plainview")
        ..add(TableContent("table", [
          RowContent()
            ..add(TextContent("key1", "Nathan"))..add(
              TextContent("key2", "Anceaux"))..add(
              TextContent("key3", "Music artist"))..add(ListContent(
              "tablelist", [TextContent("value", "Peugeot 508")])),
          RowContent()
            ..add(TextContent("key1", "Louis"))..add(
              TextContent("key2", "Houplain"))..add(
              TextContent("key3", "Music artist"))..add(
              ListContent("tablelist", [
                TextContent("value", "Range Rover Velar"),
                TextContent("value", "Lada Vesta SW Sport")
              ]))
        ])),
    ]))..add(ListContent("multilineList", [
      PlainContent("multilinePlain")
        ..add(TextContent('multilineText', 'line 1')),
      PlainContent("multilinePlain")
        ..add(TextContent('multilineText', 'line 2')),
      PlainContent("multilinePlain")
        ..add(TextContent('multilineText', 'line 3'))
    ]))..add(TextContent('multilineText2', 'line 1\nline 2\n line 3'))..add(
        ImageContent('img', testFileContent));

    final d = await docx.generate(c);
    final of = File('generated.docx');
    if (d != null) await of.writeAsBytes(d);
  }
}

