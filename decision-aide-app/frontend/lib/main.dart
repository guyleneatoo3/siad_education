import 'package:flutter/material.dart';
import 'routes.dart';
import 'theme/couleurs.dart';

void main() {
  runApp(const MonApp());
}

class MonApp extends StatelessWidget {
  const MonApp({super.key});

  // Pour activer/désactiver la bande debug, modifiez cette valeur :
  static const bool showDebugBanner = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIAD Décision',
      theme: themeClair(),
      routes: RoutesApp.routes(context),
      initialRoute: RoutesApp.accueilPublic,
      debugShowCheckedModeBanner: showDebugBanner,
    );
  }
}
