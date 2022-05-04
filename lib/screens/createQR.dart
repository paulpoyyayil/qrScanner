import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

final key = GlobalKey();

class viewQR extends StatefulWidget {
  const viewQR({Key? key}) : super(key: key);

  @override
  State<viewQR> createState() => _viewQRState();
}

class _viewQRState extends State<viewQR> {
  File? file;
  TextEditingController _controller = TextEditingController();
  bool qrGenerated = false;

  generateQR() {
    setState(() {
      qrGenerated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: TextField(
              style: TextStyle(fontSize: 30),
              textAlign: TextAlign.center,
              controller: _controller,
              decoration: InputDecoration(hintText: 'Enter text'),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: generateQR,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Generate QR',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          SizedBox(height: 50),
          RepaintBoundary(
            key: key,
            child: Container(
              color: Colors.white,
              child: qrGenerated == true
                  ? GestureDetector(
                      onLongPress: () async {
                        try {
                          RenderRepaintBoundary boundary = key.currentContext!
                              .findRenderObject() as RenderRepaintBoundary;
                          var image = await boundary.toImage();

                          ByteData? byteData = await image.toByteData(
                              format: ImageByteFormat.png);

                          Uint8List pngBytes = byteData!.buffer.asUint8List();
                          final appDir =
                              await getApplicationDocumentsDirectory();
                          var datetime = DateTime.now();
                          file = await File('${appDir.path}/$datetime.png')
                              .create();
                          await file?.writeAsBytes(pngBytes);
                          await Share.shareFiles(
                            [file!.path],
                            mimeTypes: ["image/png"],
                            text: "Share this  QR Code",
                          );
                        } catch (e) {
                          print(e.toString());
                        }
                      },
                      child: QrImage(
                        data: _controller.text,
                        version: QrVersions.auto,
                      ),
                    )
                  : SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
