# personal_tracker ✨

A simple, beautiful, and intuitive personal tracker built with Flutter. This app helps you stay on track with your daily goals and find motivation with a modern, clean interface.

## 🚀 Features

* **Personalized Dashboard:** A minimalist dashboard featuring a daily motivational quote and a to-do list that saves your tasks. Tapping the quote shows a pop-up with a blurred background.
* **Advanced To-Do List:** Create and manage tasks in a clean, vertical list. Your tasks are automatically saved and a history of completed tasks is available.
* **Interactive Analytics:** Visualize your task completion progress with a dynamic graph, a numeric summary, and options to switch between different timeframes.
* **Customizable Themes:** Switch between a variety of custom color palettes and a dynamic system theme directly from the Settings page.
* **Reorderable Favorites:** Save your favorite quotes and reorder them with a simple drag-and-drop interface.
* **Data Persistence:** All your tasks, favorites, and settings are saved locally on your device.

## 🛠️ Technology Stack

* **Flutter & Dart:** For building a beautiful, cross-platform app.
* **`http`:** To fetch daily quotes from an external API.
* **`shared_preferences`:** For local data storage and persistence.
* **`provider`:** A robust state management solution for themes and preferences.
* **`fl_chart`:** To create elegant and responsive data visualization graphs.
* **`url_launcher`:** To open external links from the app.
* **`flutter_launcher_icons`:** To generate a custom app icon.

## 💻 Getting Started

This guide will help you get the project up and running on your local machine.

### Prerequisites

* **Flutter SDK:** Make sure you have the Flutter SDK installed on your system.
* **Android Studio or VS Code:** You'll need a code editor with the Flutter and Dart extensions.
* **Platform-specific Setup:** You must have a working setup for either Android or iOS development.

### Flutter Setup Guides

#### On macOS
1.  **Install Xcode:** Install the latest version of Xcode from the Mac App Store.
2.  **Install CocoaPods:** Open your terminal and run `sudo gem install cocoapods`.
3.  **Install Android Studio:** Download and install Android Studio. In Android Studio, go to **Settings > Languages & Frameworks > Android SDK** and install the necessary SDKs.
4.  **Run `flutter doctor`:** Open a terminal and run `flutter doctor` to check if you have all the necessary components. It will guide you through any missing steps.

#### On Windows
1.  **Install Git:** Make sure you have Git installed.
2.  **Install Android Studio:** Download and install Android Studio. In Android Studio, go to **Settings > Languages & Frameworks > Android SDK** and install the necessary SDKs.
3.  **Set up Android Emulator:** Create and configure an Android Virtual Device (AVD) in Android Studio's AVD Manager.
4.  **Run `flutter doctor`:** Open PowerShell or Command Prompt and run `flutter doctor`. It will tell you if you need to install any additional components.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone [git clone [https://github.com/bwnbits/personal_tracker.git](https://github.com/bwnbits/personal_tracker.git)
    ```
2.  **Navigate to the project directory:**
    ```bash
    cd personal_tracker
    ```
3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Run the app:**
    ```bash
    flutter run
    ```
    *Note: If you encounter issues with the Dart SDK path, you can set it in your IDE settings.*

## 📖 Further Resources

* [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
* [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
* [Flutter Documentation](https://docs.flutter.dev/)
