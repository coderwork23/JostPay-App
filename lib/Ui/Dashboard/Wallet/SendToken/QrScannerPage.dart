import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  late MobileScannerController cameraController;
  bool flashlight=false;
  bool flashOn = false;

  @override
  void dispose() {
    cameraController.stop();
    cameraController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        detectionTimeoutMs: 300,
        formats: [BarcodeFormat.qrCode],
        facing: CameraFacing.back,
        autoStart: true,
        returnImage: false,
        torchEnabled: false
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) async {
              cameraController.stop();
              if(capture.barcodes.length < 2) {
                final barcodes = capture.barcodes[0];
                var result = barcodes;
                if (result != null) {
                  // print(result.rawValue.toString());
                  Navigator.pop(context, result.rawValue.toString());
                }
              }
            },
          ),
          Positioned(
            top: 50,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                      onTap: () async {
                        await cameraController.toggleTorch();
                        setState(() {
                          flashOn = !flashOn;
                        });
                      },
                      child:
                      flashOn == false ?
                      const Icon(
                        Icons.flash_on,
                        color: MyColor.whiteColor,
                      )
                          :
                      const Icon(
                        Icons.flash_off,
                        color: MyColor.whiteColor,
                      )
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 50,right: 30,
            child: GestureDetector(
              onTap: () async {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.close,
                color: MyColor.whiteColor,
              ),
            ),
          )

        ],
      ),
    );
  }
}
