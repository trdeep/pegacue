import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/translations.dart';
import 'screens/index.dart';
import 'widgets/overlay_prompter.dart';

/// PegaCue - 一个专业的提词器应用
/// 
/// 本应用提供台词提示功能，支持悬浮窗口显示和自定义滚动速度，
/// 帮助演讲者、主持人等专业人士更好地进行现场表演。


/// 应用主入口
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}


/// 悬浮窗口入口点
@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OverlayPrompter(),
    ),
  );
}

/// 应用根组件
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '提词器',
      localizationsDelegates: const [
        ...GlobalMaterialLocalizations.delegates,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const IndexPage(),
    );
  }
}
