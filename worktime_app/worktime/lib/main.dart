import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'state/auth_provider.dart';
import 'state/activity_provider.dart';
import 'state/summary_provider.dart';

/// Punto de entrada de la aplicación WorkTime
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================
  // INICIALIZAR FORMATO DE FECHAS EN ESPAÑOL
  // ============================================
  await initializeDateFormatting('es_ES', null);

  // Configurar orientación de pantalla (solo vertical)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configurar la barra de estado
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const WorkTimeApp());
}

/// Widget principal de la aplicación
class WorkTimeApp extends StatelessWidget {
  const WorkTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ============================================
    // MULTIPROVIDER
    // Aquí configuramos todos los providers de la app
    // ============================================
    return MultiProvider(
      providers: [
        // Auth Provider - Gestión de autenticación
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        
        // Activity Provider - Gestión de actividades
        ChangeNotifierProvider(
          create: (_) => ActivityProvider(),
        ),
        
        // Summary Provider - Gestión de resúmenes
        ChangeNotifierProvider(
          create: (_) => SummaryProvider(),
        ),
      ],
      
      // ============================================
      // MATERIAL APP
      // ============================================
      child: MaterialApp.router(
        title: 'WorkTime',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: AppRoutes.router,
      ),
    );
  }
}