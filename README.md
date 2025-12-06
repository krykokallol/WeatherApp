# WeatherApp
Public weather app for demo

🌦️ WeatherApp

A clean MVVM-C Weather App built with SwiftUI, UIKit, Combine, and Swift Concurrency.

📱 Overview

WeatherApp is a native iOS application that allows users to:

Search weather by US city name

View detailed weather information

Fetch weather using current device location

See weather icons loaded and cached from OpenWeather

Automatically load the last searched city

Enjoy adaptive UI supporting dark/light mode, orientation changes, size classes

Experience robust error handling and smooth performance

The app is built using MVVM-C, SwiftUI, and UIKit (no storyboards), following clean architectural principles.

🧰 Features
🔍 Weather Search

Enter any US city name

Fetch weather data from OpenWeather REST API

Auto-save and auto-load last searched city

📍 Location-Based Weather

Request precise location access

If permission granted → fetch weather automatically

“Use Current Location” button clears prior search input and reloads weather

🌤 Weather Details Screen

Temperature, feels-like

Min / Max temperatures

Description

Humidity

Wind speed

Sunrise & Sunset

Visibility

Weather icon displayed with circular background + caching

🧩 Architecture

MVVM-C (Model–View–ViewModel–Coordinator)

SwiftUI for views

UIKit NavigationController for flow coordination

Combine for location authorization stream

Swift structured concurrency (async/await) for networking

🗂 Local Data

Saves last searched city

Automatic restore on launch

🌐 Networking

Uses native URLSession

No third-party dependencies

Clean error handling for network, decoding, and API failures

🖼 Image Loading & Caching

Custom ImageLoader + in-memory cache

Background fetch + main-thread updates

🌍 Localization

Uses Swift String Catalog (.xcstrings)

English & Spanish example translations included

UI fully prepared for additional languages

♿ Accessibility

VoiceOver accessible labels

Accessibility identifiers for UI testing

High-contrast ready

🧪 Testing Support

✔ Unit Tests

ViewModel logic

State mapping

Location access logic

Search validation

Test-only injection APIs

✔ UI Tests

Launch → Search → Preview → Details

Location button clears input

Accessibility identifiers added for stability
