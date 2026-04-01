import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Configura Firebase para entornos de test sin conexión real.
/// Compatible con firebase_core >= 2.x (Pigeon).
void setupFirebaseCoreMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Pigeon usa un BinaryMessenger distinto al MethodChannel clásico.
  // Hay que interceptar el canal exacto que usa FirebaseCoreHostApi.
  _interceptPigeonChannel();
}

void _interceptPigeonChannel() {
  const pigeonChannel =
      'dev.flutter.pigeon.firebase_core_platform_interface.FirebaseCoreHostApi';

  // Respuesta simulada para initializeCore
  final initializeCoreResponse = _encodePigeonResponse([
    {
      'name': '[DEFAULT]',
      'options': {
        'apiKey': 'test-api-key',
        'appId': '1:1234567890:android:abcdef',
        'messagingSenderId': '1234567890',
        'projectId': 'test-project',
        'storageBucket': 'test-project.appspot.com',
      },
      'pluginConstants': <String, dynamic>{},
    }
  ]);

  // Respuesta simulada para initializeApp
  final initializeAppResponse = _encodePigeonResponse({
    'name': '[DEFAULT]',
    'options': {
      'apiKey': 'test-api-key',
      'appId': '1:1234567890:android:abcdef',
      'messagingSenderId': '1234567890',
      'projectId': 'test-project',
      'storageBucket': 'test-project.appspot.com',
    },
    'pluginConstants': <String, dynamic>{},
  });

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('$pigeonChannel.initializeCore',
          (_) async => initializeCoreResponse);

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('$pigeonChannel.initializeApp',
          (_) async => initializeAppResponse);
}

/// Codifica una respuesta Pigeon con el formato que espera el decodificador.
/// Pigeon usa una lista donde el primer elemento es el resultado y el resto
/// son errores. Un resultado exitoso es [result].
ByteData _encodePigeonResponse(Object result) {
  return const StandardMessageCodec().encodeMessage([result])!;
}

/// Inicializa Firebase una vez para toda la suite de tests.
Future<void> initializeFirebaseForTests() async {
  setupFirebaseCoreMocks();

  // Registrar la implementación fake de la plataforma
  FirebasePlatform.instance = MockFirebasePlatform();

  // En algunos entornos hay que intentar inicializar aunque ya esté inicializado
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'test-api-key',
        appId: '1:1234567890:android:abcdef',
        messagingSenderId: '1234567890',
        projectId: 'test-project',
      ),
    );
  } on FirebaseException catch (e) {
    // Si ya está inicializado, ignorar el error
    if (!e.message!.contains('already exists')) rethrow;
  }
}

/// Implementación fake de FirebasePlatform que evita llamadas reales
/// a la plataforma nativa.
class MockFirebasePlatform extends FirebasePlatform {
  MockFirebasePlatform() : super();

  static const _defaultOptions = FirebaseOptions(
    apiKey: 'test-api-key',
    appId: '1:1234567890:android:abcdef',
    messagingSenderId: '1234567890',
    projectId: 'test-project',
  );

  static final FirebaseAppPlatform _defaultApp = MockFirebaseAppPlatform(
    '[DEFAULT]',
    _defaultOptions,
  );

  @override
  List<FirebaseAppPlatform> get apps => [_defaultApp];

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async =>
      _defaultApp;

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) => _defaultApp;
}

class MockFirebaseAppPlatform extends FirebaseAppPlatform {
  MockFirebaseAppPlatform(super.name, super.options);

  @override
  bool get isAutomaticDataCollectionEnabled => false;

  @override
  Future<void> delete() async {}

  @override
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setAutomaticResourceManagementEnabled(bool enabled) async {}
}
