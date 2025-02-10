import 'package:apdq_flutter_app/blocs/login/login_bloc.dart';
import 'package:apdq_flutter_app/blocs/messages/message_api_service.dart';
import 'package:apdq_flutter_app/blocs/search/search_bloc.dart';
import 'package:apdq_flutter_app/config/env_config.dart';
import 'package:apdq_flutter_app/provider/languageProvider.dart';
import 'package:apdq_flutter_app/repositories/vehicle_repository.dart';
import 'package:apdq_flutter_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  // This is required to ensure Flutter bindings are initialized before using platform channels
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment configuration
  const environment =
      String.fromEnvironment('ENVIRONMENT', defaultValue: EnvConfig.local);
  await EnvConfig.initialize(environment);

  final vehicleRepository = VehicleRepository();
  final messageApiService = MessageApiService();

  // Run the app with both BlocProvider and LanguageProvider
  runApp(
    MultiProvider(
      providers: [
        BlocProvider(create: (context) => LoginBloc()),
        BlocProvider(
          create: (context) => VehicleSearchBloc(
            repository: vehicleRepository,
          ),
        ),
        Provider<MessageApiService>.value(value: messageApiService),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter App',
          locale: languageProvider.currentLocale,
          // The delegates list provides localization support for different types of widgets
          localizationsDelegates: const [
            // Our custom localizations delegate generated from ARB files
            AppLocalizations.delegate,
            // Built-in delegates for Material widgets
            GlobalMaterialLocalizations.delegate,
            // Built-in delegates for basic text direction (LTR / RTL)
            GlobalWidgetsLocalizations.delegate,
            // Built-in delegates for Cupertino (iOS-style) widgets
            GlobalCupertinoLocalizations.delegate,
          ],
          // Define which locales we support in our app
          supportedLocales: const [
            Locale('en'), // English
            Locale('fr'), // French
          ],

          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}
