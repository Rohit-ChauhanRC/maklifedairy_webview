import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../controllers/home_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              key: controller.webViewKey,
              initialUrlRequest: URLRequest(
                  url: WebUri(
                      "https://app.maklifedairy.in:5017/index.php/Login/Check_Login/${controller.mobileNumber.toString()}")),
              initialSettings: controller.settings,
              onWebViewCreated: (cx) {
                controller.webViewController = cx;
              },
              onLoadStop: (cx, url) async {
                controller.circularProgress = false;
              },
              onPermissionRequest: (controller, request) async {
                return PermissionResponse(
                    resources: request.resources,
                    action: PermissionResponseAction.GRANT);
              },
              onProgressChanged: (cx, progress) {
                controller.progress = progress / 100;
                controller.circularProgress = false;
              },
              onConsoleMessage: (cx, consoleMessage) {
                if (kDebugMode) {
                  print(consoleMessage);
                }
              },
              shouldOverrideUrlLoading: (cx, navigationAction) async {
                if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
                  final shouldPerformDownload =
                      navigationAction.shouldPerformDownload ?? false;
                  final url = navigationAction.request.url;
                  if (shouldPerformDownload && url != null) {
                    await controller.downloadFile(url.toString());
                    return NavigationActionPolicy.DOWNLOAD;
                  }
                }
                return NavigationActionPolicy.ALLOW;
              },
              onDownloadStartRequest: (cx, request) async {
                if (kDebugMode) {
                  print('onDownloadStart ${request.url.toString()}');
                }

                await controller.downloadFile(
                    request.url.toString(), request.suggestedFilename);
              },
            ),
            Obx(() => controller.progress < 1.0
                ? Center(
                    child: CircularProgressIndicator(
                    value: controller.progress,
                  ))
                : Container()),
            // Obx(() => Container(
            //     padding: const EdgeInsets.all(10.0),
            //     child: controller.progress < 1.0
            //         ? LinearProgressIndicator(value: controller.progress)
            //         : Container())),
          ],
        ),
      ),
    );
  }
}
