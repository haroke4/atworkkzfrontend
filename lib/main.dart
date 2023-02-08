import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelance_order/pages/admin_main_page.dart';
import 'package:freelance_order/pages/enter_code_page.dart';
import 'package:freelance_order/pages/worker_main_page.dart';
import 'package:freelance_order/prefabs/colors.dart';
import 'package:freelance_order/utils/BackendAPI.dart';
import 'package:freelance_order/utils/LocalizerUtil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  await ScreenUtil.ensureScreenSize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //Set the fit size (Find your UI design, look at the dimensions of the device screen and fill it in,unit in dp)
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: false,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Zhumysta',
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
          home: const SplashScreen(),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 2000),
    vsync: this,
  );
  late SharedPreferences sharedPrefs;
  StatefulWidget? nextScreen;

  @override
  void initState() {
    super.initState();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (nextScreen != null) {
          Get.off(nextScreen);
        } else {
          _controller.forward(from: 0.0);
        }
      }
    });
    _controller.forward(from: 0.0);
    asyncInitState();
  }

  void asyncInitState() async {
    sharedPrefs = await SharedPreferences.getInstance();

    nextScreen = LoginPage();
    if (sharedPrefs.getString("account_type") == null) { //
      setState(() {
        nextScreen = LoginPage();
      });
    } else if (sharedPrefs.getString("account_type") == "admin") {
      var token = sharedPrefs.getString('token').toString();
      var code = sharedPrefs.getString('code');
      if (await BackendAPI.isTokenValid(token) && code != null) {
        headers["Authorization"] = "Token $token";
        setState(() {
          nextScreen = EnterCodePage(
            nextPage: const AdminsMainPage(),
            code: code.toString(),
          );
        });
      }
    } else {
      var token = sharedPrefs.getString('token').toString();
      var code = sharedPrefs.getString('code');
      if (await BackendAPI.isTokenValid(token) && code != null) {
        headers["Authorization"] = "Token $token";
        setState(() {
          nextScreen = EnterCodePage(
            nextPage: const WorkersMainPage(),
            code: code.toString(),
          );
        });
      }
    }
    // sharedPrefs.clear();

    if (sharedPrefs.getString('lang') != null) {
      Localizer.setLang(sharedPrefs.getString('lang')!);
    }
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
          turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
          child: Image.asset("assets/icon.png", height: 350.h),
        ),
      ),
    );
  }
}
