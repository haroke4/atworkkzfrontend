import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelance_order/prefabs/colors.dart';
import 'package:get/get.dart';
import 'pages/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
  runApp(const MyApp());
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
      overlays: []);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //Set the fit size (Find your UI design, look at the dimensions of the device screen and fill it in,unit in dp)
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'AppName',
          // You can use the library anywhere in the app even in theme
          theme: ThemeData(
            primarySwatch: Colors.blue,
            textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1.sp),
            backgroundColor: const Color.fromRGBO(230, 230, 230, 1),
            primaryColorLight: const Color.fromRGBO(246, 246, 246, 1),
            primaryColorDark: const Color.fromRGBO(21, 21, 21, 1.0),
            inputDecorationTheme: const InputDecorationTheme(
              border: InputBorder.none,
              labelStyle: TextStyle(
                color: Color.fromRGBO(131, 131, 131, 1.0),
              ),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color.fromRGBO(21, 21, 21, 1.0),
            ),
          ),
          home: const SplashScreen(nextScreen: LoginPage()),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  final nextScreen;

  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 1000),
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Get.off(widget.nextScreen);
      }
    });
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brownColor,
      body: Center(
        child: RotationTransition(
          turns: Tween(begin: 0.0, end: 0.5).animate(_controller),
          child: Image.asset("assets/icon.png", height: 200.h),
        ),
      ),
    );
  }
}
