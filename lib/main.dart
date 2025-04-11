import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'nini_adventureland.dart';
import 'login.dart';
import 'game_intro.dart';
import 'home_page.dart';
import 'cart.dart';
import 'account.dart';
import 'product_1.dart';
import 'product_2.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: false);

  // Set the app to full-screen mode
  Flame.device.fullScreen();
  Flame.device.setPortrait();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login', // Start with the login page
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => ECommercePage(cartItems: cartItems),
        '/cart': (context) => CartPage(cartItems: cartItems),
        '/account': (context) => AccountPage(),
        '/intro': (context) => GameIntro(),
        '/game': (context) => GameSystem(),
        '/product1': (context) => Product1Page(cartItems: cartItems),
        '/product2': (context) => Product2Page(cartItems: cartItems),
      },
    );
  }
}

class GameSystem extends StatelessWidget {
  final NiniAdventure game = NiniAdventure();

  @override
  Widget build(BuildContext context) {
    game.setGameContext(context); // Pass the context to the game

    return Scaffold(
      body: GameWidget(
        game: game,
      ),
    );
  }
}