# VoxA

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

<p align="center">
  <img
    src="https://github.com/williamtheodoruswijaya/VoxA/blob/95a20a5f21379affc27246799d723472c17a9221/VoxA.png"
    alt="VoxA Logo"
    width="200"
  />
</p>
<p align="center">
  <strong>VoxA: Record. Summarize. Understand. Anywhere.</strong>
</p>

---

## 🎯 Problem Statement

In a world of endless meetings, lectures, and voice notes, people struggle to retain key information. Many:

* Forget important points after long sessions.
* Waste time reviewing entire recordings.
* Face language barriers in multilingual environments.

---

## ✨ The VoxA Solution

**VoxA** helps users **record audio**, automatically **transcribe**, **summarize**, and optionally **translate** it into their preferred language — all within seconds. Powered by AI and natural language processing, VoxA delivers quick understanding and accessibility for everyone.

---

## 🚀 Key Features

* 🎤 **Audio Recording**: Record meetings, lectures, or voice notes directly from your phone.
* 🧠 **AI Summarization**: Automatically generate concise summaries using NLP models.
* 📝 **Transcription**: Convert audio to text with punctuation and speaker identification.
* 🌐 **Translation (Optional)**: Translate summaries into another languages.
* 📂 **History & Search**: Access past recordings and summaries easily.
* 🔒 **Privacy-Oriented**: Audio never stored without consent. End-to-end secure processing.

---

## 👥 Target Users

* Students needing lecture summaries
* Professionals in meetings
* Journalists or researchers reviewing interviews
* Language learners or translators

---

## 🧰 Tech Stack

### Backend (Golang)

* **Framework**: Gin Gonic
* **Speech-to-Text**: Integration with external APIs (OpenAI Whisper)
* **Summarization**: AI model inference (via Python microservice)
* **Translation**: Google Cloud Translation API / LibreTranslate
* **Authentication**: JWT-based
* **Database**: PostgreSQL
* **Deployment**: Docker + Render / Railway

### Mobile Frontend (Flutter)

* **Framework**: Flutter (Dart)
* **Audio Recorder**: `flutter_sound`, `permission_handler`
* **HTTP Client**: `dio`
* **State Management**: Riverpod / Bloc
* **UI**: Material Design + custom theming
* **Multiplatform**: Android & iOS

---

## 📱 App Flow

1. **Home Screen**
   → Start Recording → Stop → Audio is uploaded to server.

2. **Processing**
   → Server transcribes, summarizes, and translates audio.

3. **Result Page**
   → View Full Transcript
   → View Summary
   → Option to Translate Summary
   → Download / Share / Copy

4. **History Page**
   → Access all past records and summaries.

---

## 📦 Installation Guide

### 🔧 Backend (Golang)

```bash
git clone https://github.com/williamtheodoruswijaya/VoxA.git
cd server
go mod tidy
go run main.go
```

Ensure you have:

* `.env` for API keys
* PostgreSQL running
* Python microservice (if using custom summarizer)

### 📱 Frontend (Flutter)

```bash
git clone https://github.com/williamtheodoruswijaya/VoxA.git
cd client
flutter pub get
flutter run
```

Make sure:

* Dart SDK is installed
* Android/iOS emulator or real device is connected
* Permissions for microphone and storage are handled

---

## 🌍 Roadmap

* [x] Audio recording & upload
* [x] Basic summarization
* [x] Transcription with punctuation
* [x] Speaker diarization
* [x] Language auto-detection
* [ ] Offline mode
* [ ] Chat-based Q\&A over summaries

---

## 👨‍💻 Contributors

* **Frederick Krisna Suryopranoto**
* **Reynard Setiawan**
* **William Theodorus Wijaya**

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
