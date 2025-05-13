import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:grocery_vendor_app/providers/auth_provider.dart';
import 'package:grocery_vendor_app/providers/orders_provider.dart';
import 'package:grocery_vendor_app/providers/products_provider.dart';
import 'package:grocery_vendor_app/screens/add_edit_coupon_screen.dart';
import 'package:grocery_vendor_app/screens/add_new_product_screen.dart';
import 'package:grocery_vendor_app/screens/banners_screen.dart';
import 'package:grocery_vendor_app/screens/coupon_screen.dart';
import 'package:grocery_vendor_app/screens/home_screen.dart';
import 'package:grocery_vendor_app/screens/login_screen.dart';
import 'package:grocery_vendor_app/screens/order_screen.dart';
import 'package:grocery_vendor_app/screens/products_screen.dart';
import 'package:grocery_vendor_app/screens/registration_screen.dart';
import 'package:grocery_vendor_app/screens/reset_password_screen.dart';
import 'package:grocery_vendor_app/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDKNSapKXYrTKL4xD5cXSnmn5ppC8KDVgc",
      appId: "1:147156304764:android:e993fc9a95b149b4da9af9",
      messagingSenderId: "grocery-application-3329d",
      projectId: "grocery-application-3329d",
      storageBucket: "grocery-application-3329d.appspot.com"
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ListenableProvider(
          create: (_) => AuthProvider(),
        ),
        ListenableProvider(
          create: (_) => ProductProvider(),
        ),
        ListenableProvider(
          create: (_) => OrderProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: EasyLoading.init(),
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id: (context) => const SplashScreen(),
        RegistrationScreen.id: (context) => const RegistrationScreen(),
        HomeScreen.id: (context) => const HomeScreen(),
        LoginScreen.id: (context) => const LoginScreen(),
        ResetPasswordScreen.id: (context) => const ResetPasswordScreen(),
        ProductScreen.id: (context) => const ProductScreen(),
        AddNewProductScreen.id: (context) => const AddNewProductScreen(),
        BannerScreen.id: (context) => const BannerScreen(),
        AddEditCoupon.id: (context) => const AddEditCoupon(),
        CouponScreen.id: (context) => const CouponScreen(),
        OrderScreen.id: (context) => const OrderScreen(),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple, fontFamily: 'Lato'),
    );
  }
}
