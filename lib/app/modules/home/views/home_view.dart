import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          title: Text("Text to Word"),
        ),
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Expanded(
                      child: ListView(
                        children: [
                          controller.path.value.isEmpty
                              ? Container()
                              : controller.path.value.contains("http")
                              ? Image.network(controller.path.value)
                              : Image.file(File(controller.path.value)),
                          controller.bload.value
                              ? Column(children: [CircularProgressIndicator()])
                              : Column(
                            children: [
                              Text(
                                '${controller.ocrText}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Times New Roman',
                                    letterSpacing: 1
                                  ),
                              ),
                              // ElevatedButton(
                              //     onPressed: () {
                              //       print("onpress");
                              //       controller.docxGenerate();
                              //     },
                              //     child: Text("save to docx"))
                            ],
                          )
                        ],
                      ))
                ],
              ),
            ),
            Container(
              color: Colors.black26,
              child: controller.bDownloadtessFile
                  ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      Text('download Trained language files')
                    ],
                  ))
                  : SizedBox(),
            )
          ],
        ),

        floatingActionButton: kIsWeb
            ? Container()
            : FloatingActionButton(
          onPressed: () {
            print("pressed");
            controller.runFilePiker();
            // _ocr("");
          },
          tooltip: 'OCR',
          child: Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      );
    });
  }
}
