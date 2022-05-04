import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_scanner/screens/createQR.dart';
import 'qr_scanned_view.dart';

class QRViewer extends StatefulWidget {
  const QRViewer({Key? key}) : super(key: key);

  @override
  State<QRViewer> createState() => _QRViewerState();
}

class _QRViewerState extends State<QRViewer> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? result;
  bool cameraStatus = true;
  bool backCamera = true;
  bool flashStatus = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        pauseCamera();
        result = scanData;
      });
      if (result != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QRData(result: result),
            ));
      }
    });
  }

  pauseCamera() async {
    setState(() {
      cameraStatus = false;
    });
    await controller!.pauseCamera();
  }

  resumeCamera() async {
    setState(() {
      cameraStatus = true;
    });
    await controller!.resumeCamera();
  }

  flashFunction() async {
    if (flashStatus == false) {
      await controller!.toggleFlash();
      setState(() {
        flashStatus = true;
      });
    } else {
      await controller!.toggleFlash();
      setState(() {
        flashStatus = false;
      });
    }
  }

  toggleCamera() async {
    if (backCamera == true) {
      await controller!.flipCamera();
      setState(() {
        backCamera = false;
      });
    } else {
      await controller!.flipCamera();
      setState(() {
        backCamera = true;
      });
    }
  }

  _pushPage() {
    pauseCamera();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => viewQR()),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            child: QRView(
              key: qrKey,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
              ),
              onQRViewCreated: _onQRViewCreated,
              onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
            ),
          ),
          Positioned(
            bottom: 10,
            left: MediaQuery.of(context).size.width / 4,
            right: MediaQuery.of(context).size.width / 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: cameraStatus == true
                      ? GestureDetector(
                          onTap: () {
                            pauseCamera();
                          },
                          child: Icon(
                            Icons.pause,
                            color: Colors.white54,
                            size: 50,
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            resumeCamera();
                          },
                          child: Icon(
                            Icons.play_arrow,
                            color: Colors.white54,
                            size: 50,
                          ),
                        ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(50),
              ),
              child: flashStatus == true
                  ? GestureDetector(
                      onTap: () {
                        flashFunction();
                      },
                      child: Icon(
                        Icons.flash_off,
                        color: Colors.white60,
                        size: 30,
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        flashFunction();
                      },
                      child: Icon(
                        Icons.flash_on,
                        color: Colors.white60,
                        size: 30,
                      ),
                    ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 20,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(50),
              ),
              child: backCamera == true
                  ? GestureDetector(
                      onTap: () {
                        toggleCamera();
                      },
                      child: Icon(
                        Icons.camera_front,
                        color: Colors.white60,
                        size: 30,
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        toggleCamera();
                      },
                      child: Icon(
                        Icons.camera_rear,
                        color: Colors.white60,
                        size: 30,
                      ),
                    ),
            ),
          ),
          Positioned(
            top: 50,
            right: 5,
            child: PopupMenuButton(
              color: Colors.white70,
              offset: Offset(-20, 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: GestureDetector(
                    onTap: _pushPage,
                    child: Text(
                      "Create QR",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
              child: Icon(
                Icons.more_vert_outlined,
                color: Colors.white,
                size: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }
}
