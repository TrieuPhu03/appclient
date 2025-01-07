import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:flutter_localizations/flutter_localizations.dart'; // Localization
import 'screens/login_screen.dart';
import './service/ThemeNotifier.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Đảm bảo mọi plugin được khởi tạo
  await dotenv.load(fileName: ".env"); // Tải file .env
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Ứng dụng của tôi',
          theme: themeNotifier.isDarkMode
              ? ThemeData.dark() // Chế độ tối
              : ThemeData.light(), // Chế độ sáng
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('vi', 'VN'), // Tiếng Việt
            Locale('en', 'US'), // Tiếng Anh
          ],
          home: const LoginScreen(), // Trang mặc định là LoginScreen
        );
      },
    );
  }
}
