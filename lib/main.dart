
import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:real_esrgan_gui/views/real_cugan_tab_page.dart';
import 'package:real_esrgan_gui/views/real_esrgan_tab_page.dart';
import 'package:window_size/window_size.dart';

/// バージョン
const String version = '1.2.0';

void main() async {

  // おまじない
  WidgetsFlutterBinding.ensureInitialized();

  // ローカライゼーションの初期化
  await EasyLocalization.ensureInitialized();

  // スクリーン情報を取得
  var screen = await getCurrentScreen();

  // スクリーンの DPI スケールを取得
  var dpiScale = screen!.scaleFactor;

  // macOS では DPI スケールに関わらず常に1倍で表示する
  // Windows と DPI スケール周りの扱いが違うのかも…？ 1倍でちょうど良いサイズになる
  if (Platform.isMacOS) {
    dpiScale = 1;
  }

  // ウインドウの最小サイズ
  // DPI スケールに合わせて調整する (Windows のみ)
  /// macOS のみ、ウインドウの最小高さから 10px ほど引く
  /// Windows と macOS でウインドウのタイトルバーの高さが異なるため
  double minWidth = 780 * dpiScale;
  double minHeight = (Platform.isMacOS ? 684 : 694) * dpiScale;

  // 左上を起点にしたウインドウのX座標・Y座標
  double top = (screen.visibleFrame.height - minHeight) / 2;
  double left = (screen.visibleFrame.width - minWidth) / 2;

  // ウインドウの位置とサイズを設定
  setWindowFrame(Rect.fromLTWH(left, top, minWidth, minHeight));

  // 最小ウインドウサイズを設定
  // ref: https://zenn.dev/tris/articles/006c41f9c473a4
  setWindowMinSize(Size(minWidth, minHeight));

  // ウィンドウのタイトルを設定
  setWindowTitle('Real-ESRGAN-GUI');

  // ローカライゼーションを有効化した状態でアプリを起動
  runApp(EasyLocalization(
    path: 'assets/translations',
    supportedLocales: const [
      Locale('en', 'US'),
      Locale('ja', 'JP'),
      Locale('uk'),
    ],
    fallbackLocale: const Locale('en', 'US'),
    child: const RealESRGanGUIApp(),
  ));
}

class RealESRGanGUIApp extends StatelessWidget {
  const RealESRGanGUIApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Real-ESRGAN-GUI',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'M PLUS 2',
        snackBarTheme: const SnackBarThemeData(
          contentTextStyle: TextStyle(fontFamily: 'M PLUS 2'),
        ),
      ),
      home: const MainWindowPage(title: 'Real-ESRGAN-GUI'),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}

class MainWindowPage extends StatefulWidget {
  const MainWindowPage({super.key, required this.title});

  final String title;

  @override
  State<MainWindowPage> createState() => MainWindowPageState();
}

class MainWindowPageState extends State<MainWindowPage> with SingleTickerProviderStateMixin {

  late TabController tabController;
  Color appBarBackgroundColor = Colors.green;

  @override
  void initState() {
    super.initState();

    // タブが切り替わったとき、タブに応じてヘッダーの背景色を変える
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      setState(() {
        switch (tabController.index) {
          case 0:
            // Real-ESRGAN タブ
            appBarBackgroundColor = Colors.green;
            break;
          case 1:
            // Real-CUGAN タブ
            appBarBackgroundColor = Colors.lightBlue;
            break;
        }
      });
    });

    // 更新をチェック
    (() async {
      var response = await http.get(Uri.parse('https://api.github.com/repos/tsukumijima/Real-ESRGAN-GUI/tags'));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var retrieveVersion = (data[0]['name'] as String).replaceAll('v', '');
        if (version != retrieveVersion) {

          // 更新があるのでダイヤログを表示
          var goUpdateUrl = false;
          await showDialog(
            context: context,
            barrierDismissible: true,
            builder: (_) {
              return AlertDialog(
                title: const Text('label.updateInformation').tr(),
                content: const Text('message.updateInformation').tr(args: [retrieveVersion]),
                actionsPadding: const EdgeInsets.only(right: 12, bottom: 12),
                actions: [
                  SizedBox(
                    height: 40,
                    child: TextButton(
                      child: const Text('label.later').tr(),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      style: const ButtonStyle(elevation: MaterialStatePropertyAll(0)),
                      child: const Text('label.download').tr(),
                      onPressed: () {
                        goUpdateUrl = true;
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              );
            },
          );

          // ダウンロード先 URL を開く
          if (goUpdateUrl) {
            await launchUrl(Uri.parse('https://github.com/tsukumijima/Real-ESRGAN-GUI/releases/tag/v${retrieveVersion}'));
          }
        }
      }
    })();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarBackgroundColor,
        title: Text(widget.title),
        actions: const [
          Center(
            child: Text('version ${version}', style: TextStyle(fontSize: 16)),
          ),
          SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Real-ESRGAN'),
            Tab(text: 'Real-CUGAN'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: const [
          RealESRGANTabPage(),
          RealCUGANTabPage(),
        ],
      ),
    );
  }
}
