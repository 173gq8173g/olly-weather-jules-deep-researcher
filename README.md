# Flutter Weather App

A simple Flutter application that demonstrates user login (mocked) and fetching/displaying current weather information based on the user's current location or a default location. This app is designed to run on mobile (Android/iOS) and web.

## Features

*   **Mock Login Screen:** A basic login form (email/password). Any non-empty input is considered a successful login for demonstration purposes.
*   **Weather Display Screen:**
    *   Fetches current weather data from the [OpenWeatherMap API](https://openweathermap.org/api).
    *   Attempts to use the device's current geolocation.
    *   Falls back to a default location (London) if geolocation fails, is denied, or if running on a platform where it's not easily available without further setup.
    *   Displays:
        *   City Name
        *   Current Temperature (in Celsius)
        *   Weather Description (e.g., "Clear Sky", "Cloudy")
        *   Weather Icon
        *   Humidity
        *   Wind Speed
    *   Loading and error states.
    *   Refresh button to re-fetch weather data.
    *   Logout button to return to the login screen.
*   **Responsive UI:** The layout is designed to be clean and usable on both small mobile screens and larger web browser windows.

## Getting Started

### Prerequisites

*   **Flutter SDK:** Version 3.0.0 or higher (null-safety enabled). Ensure Flutter is installed and configured in your PATH. You can find installation instructions at [flutter.dev](https://docs.flutter.dev/get-started/install).
*   **Supported Platforms Setup (for mobile):**
    *   For Android: Android Studio, Android SDK, and a configured emulator or physical device.
    *   For iOS (if on macOS): Xcode and CocoaPods.
*   **Web Browser:** Google Chrome is recommended for web development and testing (`flutter run -d chrome`).
*   **OpenWeatherMap API Key:** You need an API key from OpenWeatherMap to fetch weather data.
    *   Sign up at [OpenWeatherMap](https://home.openweathermap.org/users/sign_up).
    *   Subscribe to the "Current Weather Data" API (the free tier is sufficient).
    *   Find your API key under your account's API keys section.

### Setup API Key

1.  Open the project in your editor.
2.  Navigate to the file: `lib/services/weather_service.dart`.
3.  Find the following line:
    ```dart
    const String OPEN_WEATHER_MAP_API_KEY = 'YOUR_API_KEY_HERE';
    ```
4.  Replace `'YOUR_API_KEY_HERE'` with your actual OpenWeatherMap API key.

### Running the App

1.  **Clone the repository (if applicable) or ensure you have the project files.**
2.  **Get dependencies:**
    Open your terminal in the project root directory and run:
    ```bash
    flutter pub get
    ```
3.  **Run on Mobile (Android/iOS):**
    *   Ensure an emulator is running or a device is connected.
    *   Run:
        ```bash
        flutter run
        ```
    *   Select the desired device if prompted.
4.  **Run on Web:**
    *   Run:
        ```bash
        flutter run -d chrome
        ```
    *   This will build the app for the web and open it in Google Chrome.
    *   Alternatively, for a release build for web:
        ```bash
        flutter build web
        # Then serve the build/web directory using a local web server.
        # For example, using `dhttpd`:
        # pub global activate dhttpd (if not installed)
        # dhttpd --path build/web
        ```

## Running Tests

The project includes widget tests and unit tests.

1.  **Ensure dependencies are up to date:**
    ```bash
    flutter pub get
    ```
2.  **Run all tests:**
    From the project root directory, run:
    ```bash
    flutter test
    ```
    This command will execute both widget tests in `test/widget_test.dart` and any unit tests (e.g., in `test/unit/`).

    *   **Widget Tests (`test/widget_test.dart`):**
        *   Test the login screen UI and validation.
        *   Test login flow and navigation to the weather screen.
        *   Test weather screen display (loading, data, errors) using a mocked `WeatherService` to avoid real API calls.
        *   Test fallback mechanisms (e.g., to default city on location or API error).
    *   **Unit Tests (`test/unit/weather_info_test.dart`):**
        *   Test the `WeatherInfo.fromJson` factory for correct parsing of JSON data from the weather API.

## Project Structure

Key files and directories:

*   `lib/main.dart`: Main application entry point, MaterialApp setup, and routes.
*   `lib/login_screen.dart`: UI and logic for the login screen.
*   `lib/weather_screen.dart`: UI and logic for displaying weather information.
*   `lib/models/weather_info.dart`: Data model for storing parsed weather information.
*   `lib/services/weather_service.dart`: Service class responsible for:
    *   Fetching current geolocation.
    *   Making HTTP requests to the OpenWeatherMap API.
    *   Parsing JSON responses (though parsing logic is primarily in `WeatherInfo` model).
    *   Contains the `OPEN_WEATHER_MAP_API_KEY` constant that needs to be configured.
*   `test/`: Contains all tests.
    *   `test/widget_test.dart`: Widget tests for UI and interaction flows.
    *   `test/unit/weather_info_test.dart`: Unit tests for model logic.
*   `pubspec.yaml`: Project metadata and dependencies.
*   `README.md`: This file.

## Assumptions and Choices

*   **Mock Authentication:** Login is simulated. Any non-empty email and password will grant access. No actual backend authentication is implemented.
*   **Default Location:** If geolocation fails or is denied, the app defaults to fetching weather for "London". This is defined in `lib/services/weather_service.dart`.
*   **API Key Handling:** The API key is stored as a constant in `weather_service.dart`. For a production app, a more secure method (like environment variables or a configuration file not committed to the repository) would be used.
*   **State Management:** Simple `StatefulWidget` and `setState` are used for managing UI state, as per requirements for a small app.
*   **Error Handling:** Basic error handling is implemented for location failures, API errors, and network issues, typically displaying messages to the user or falling back to default behavior.
*   **Styling:** Uses Material 3 design with Flutter's built-in widgets. UI is clean and functional.

## Future Improvements (Optional)

*   **Real User Authentication:** Integrate with a proper authentication service (e.g., Firebase Auth, OAuth).
*   **More Robust Error Handling:** Provide more user-friendly error messages and recovery options.
*   **Manual Location Search:** Allow users to search for weather in other cities.
*   **Extended Forecast:** Display a 5-day or hourly forecast.
*   **Settings:** Allow users to customize units (Celsius/Fahrenheit), default location, etc.
*   **Improved UI/UX:** More polished design, animations, and potentially custom weather icons.
*   **Advanced State Management:** For larger apps, consider providers like Riverpod or BLoC/Cubit.
*   **CI/CD:** Set up continuous integration and deployment pipelines.
*   **Platform-Specific Optimizations:** Further tailor UI/UX for specific platform conventions if needed.
