# DetFall APP
DetFall APP es una innovadora aplicación diseñada para conectarse con el dispositivo DetFall, un avanzado detector de caídas. Utilizando inteligencia artificial, DetFall ofrece una precisión superior en la identificación de caídas, permitiendo una respuesta rápida en situaciones de emergencia. Esta aplicación garantiza la seguridad de los usuarios al enviar alertas automáticas a servicios de emergencia cuando se detecta un incidente.

# Requerimientos
- Flutter SDK 3.16.0
- Dart SDK 3.2.0
- VSCode

## Instalación

Sigue estos pasos para configurar el proyecto en tu entorno local:

1. Clona este repositorio en tu máquina local:

    ```bash
    git clone https://github.com/alanbarco/DetFall.git
    ```
2. Instala las dependencias del proyecto:

    ```bash
    flutter pub get
    ```
3. Solicitar el archivo .env para la comunicación con la API de ESPOL Alert.
4. Conecta un dispositivo o emulador y ejecuta la aplicación:

    ```bash
    flutter run
    ```

## Estructura del Proyecto

```plaintext
DetFall/
├── android/                # Archivos específicos de Android
├── ios/                    # Archivos específicos de iOS
├── lib/                    # Código fuente principal de la aplicación
│   ├── main.dart           # Punto de entrada de la aplicación
│   ├── config/             # Archivos de configuración
│   ├── domain/             # Modelos utilizados
│   ├── providers/          # Providers para el manejo de estados
│   ├── services/           # Archivos para comunicación con servicios externos
│   ├── utils/              # Archivos para almacenar funciones, clases auxiliares
│   └── views/              # Pantallas de la app
├── pubspec.yaml            # Archivo de configuración de Flutter/Dart
└── README.md               # Documentación del proyecto