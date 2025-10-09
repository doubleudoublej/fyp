# my_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Running backend + Flutter (local development)

This repository contains a `backend/` folder alongside the Flutter app. The backend is a Spring Boot application that runs on port `8080` by default in this workspace. The Flutter app's API client is configured to talk to the backend on port `8080` for local development.

Quick steps:

1. Start the backend

	- From PowerShell:

```powershell
cd C:\Users\JJWDe\fyp\backend
.\gradlew bootRun
```

	- To run on a different port (example `8000`):

```powershell
.\gradlew bootRun --args='--server.port=8000'
```

2. Start the Flutter app

```powershell
cd C:\Users\JJWDe\fyp
flutter pub get
flutter run
```

3. API endpoints to test

	- Health check (permitted without auth): `http://localhost:8080/api/health`
	- Actuator health (if enabled): `http://localhost:8080/actuator/health`

Notes:

- Android emulator: the ApiClient maps to `http://10.0.2.2:8080` so the emulator reaches the host machine.
- Physical devices: use your PC LAN IP, for example `http://192.168.1.42:8080` and allow the port through your firewall.
- If you want `/actuator/**` accessible during development, add `management.endpoints.web.exposure.include=health,info` to `backend/src/main/resources/application.properties` and permit `/actuator/**` in `SecurityConfig`.
