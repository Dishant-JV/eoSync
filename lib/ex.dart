import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:e_o_sync/log_in.dart';
import 'package:get/get.dart';
import 'package:e_o_sync/scan_api_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyHome extends StatefulWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  logout() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool('isLogIn', false);
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) => LogInScreen()),(route)=>false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height*0.55,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Color(0xff343A40),
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(60),bottomRight: Radius.circular(60))
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Hey! Welcome to ",style: TextStyle(color: Colors.white,fontSize: 17,fontWeight: FontWeight.w500,letterSpacing: 1.5),),
                        SizedBox(height: 12,),
                        Text("eoSync",style: TextStyle(color: Colors.white,fontSize: 80,fontWeight: FontWeight.w500,letterSpacing: 4),)
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const QRViewExample(),
                      ));
                    },
                    child: Center(
                      child: Container(
                        margin: EdgeInsets.only(top:  MediaQuery.of(context).size.height*0.48),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20)
                        ),
                        height: 110,
                        width: 150,
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.qr_code_scanner_rounded,size: 35,),
                              SizedBox(height: 8,),
                              Text("Scan Barcode",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),)
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.28,),
              InkWell(
                onTap: (){
                  logout();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout,size: 30,),
                    SizedBox(width: 5,),
                    Text("Logout",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 20),)
                  ],
                ),
              )

            ],

          ),
        ),
      )
    );
  }
}


class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  String? accountCode;
  DateTime? lastScan;
  List<ScanApiModel> listScan = [];
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }
  void getCode()async{
    SharedPreferences preferences=await SharedPreferences.getInstance();
    accountCode=preferences.getString("accountCode")??"";
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
        ],
      ),
    );
  }

  Widget dialog(BuildContext context, String code, String text) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        height: 200,
        width: double.infinity,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Color(0xff343A40),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              height: 80,
              width: double.infinity,
              alignment: Alignment.center,
              child: Icon(
                Icons.info_outline,
                size: 60,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Order : ",
                  style: TextStyle(fontFamily: 'RyeFonts', fontSize: 16),
                ),
                Text(code,
                    style: TextStyle(fontFamily: 'RyeFonts', fontSize: 16))
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Text(text,
                style: TextStyle(
                    fontFamily: 'RyeFonts',
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Color(0xff343A40))),
                onPressed: () async {
                  controller?.resumeCamera();
                  Navigator.pop(context);
                },
                child: Text(
                  "OK",
                  style: TextStyle(fontFamily: 'RyeFonts'),
                ))
          ],
        ),
      ),
    );
  }

  compareData(String code) async {
    final response = await http.post(Uri.parse("http://3.110.105.180:8080/api/${accountCode}/orders/scan"),
        body: jsonEncode({'barcode': code}),
        headers: {'Content-Type': 'application/json; charset=UTF-8'});
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> scanMap = jsonDecode(response.body);
      listScan.add(ScanApiModel.fromJson(scanMap));
      if (listScan[0].statusCode == "401") {
        setState(() {
          controller?.pauseCamera();
          listScan.clear();
          showDialog(
              context: (context),
              builder: (context) {
                return dialog(context, code, "Invalid Barcode");
              });
        });
      } else if (listScan[0].statusCode == "200") {
        if (listScan[0].statusMessage == "Already Scanned before.") {
          setState(() {
            controller?.pauseCamera();
            listScan.clear();
            showDialog(
                context: (context),
                builder: (context) {
                  return dialog(context, code, "Item Already Scanned");
                });
          });
        } else if (listScan[0].statusMessage == "Order Scanned.") {
          setState(() {
            listScan.clear();
            playSound();
          });
        }
      }
    }
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 400.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((data) {
      final currentScan = DateTime.now();
      if (lastScan == null ||
          currentScan.difference(lastScan!) > const Duration(seconds: 4)) {
        lastScan = currentScan;
        compareData(data.code.toString());
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void playSound() async {
    final player = AudioCache();
    // AudioPlayer player=AudioPlayer(mode: PlayerMode.LOW_LATENCY);
    String audioasset = "assets/sound/beep.mp3";
    ByteData bytes = await rootBundle.load(audioasset); //load audio from assets
    Uint8List audiobytes =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    await player.playBytes(audiobytes);
  }
}
