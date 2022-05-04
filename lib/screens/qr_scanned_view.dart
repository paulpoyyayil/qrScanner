import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:string_validator/string_validator.dart';
import 'package:url_launcher/url_launcher.dart';

class QRData extends StatelessWidget {
  final Barcode? result;

  QRData({Key? key, required this.result}) : super(key: key);
  viewSnackbar(context, String text) {
    final snackBar = SnackBar(
      elevation: 5,
      duration: Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      content: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    bool isValid = isURL(result!.code.toString());
    print(isValid);
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double size = screenHeight / screenWidth;

    customLauncher() {
      if (result!.code.toString().contains('http') ||
          result!.code.toString().contains('https')) {
        launchUrl(Uri.parse(result!.code.toString()),
            mode: LaunchMode.externalApplication);
      } else {
        String newUrl = 'http://' + result!.code.toString();
        launchUrl(Uri.parse(newUrl), mode: LaunchMode.externalApplication);
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            height: screenHeight,
            width: screenWidth,
            padding: EdgeInsets.all(size * 10),
          ),
          Positioned(
            top: size * 100,
            left: screenWidth / 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.all(20),
              child: isValid == true
                  ? Icon(Icons.http, size: size * 100)
                  : Icon(Icons.text_snippet_rounded, size: size * 100),
            ),
          ),
          Positioned(
            top: size * 250,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(
                  size * 10, size * 7.5, size * 10, size * 7.5),
              child: isValid == true
                  ? InkWell(
                      onTap: customLauncher,
                      onLongPress: () {
                        Clipboard.setData(
                            ClipboardData(text: result!.code.toString()));
                        viewSnackbar(context, 'Link copied');
                      },
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Go to : ',
                              style: TextStyle(
                                  fontSize: size * 15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black),
                            ),
                            TextSpan(
                              text: result!.code.toString(),
                              style: TextStyle(
                                  fontSize: size * 15,
                                  fontWeight: FontWeight.w400,
                                  decoration: TextDecoration.underline,
                                  color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    )
                  : InkWell(
                      onLongPress: () {
                        Clipboard.setData(
                            ClipboardData(text: result!.code.toString()));
                        viewSnackbar(context, 'Text copied');
                      },
                      child: Text(
                        result!.code.toString(),
                        style:
                            TextStyle(fontSize: size * 15, color: Colors.blue),
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
