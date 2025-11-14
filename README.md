# MindWell – Mental Health Companion (Flutter)

MindWell is a cross-platform mental wellness application designed for university students.  
It provides tools for **mood tracking**, **guided journaling**, **curated mental health articles**, **anonymous community support**, and a **lightweight gamification system** to encourage consistent self-care.

This repository contains the project.

---

## ✨ Features

- 📅 **Mood Tracker** – Emoji-based monthly calendar with daily reflections  
- 📖 **Curated Articles** – Mental health content grouped by themes (anxiety, stress, self-care, etc.)  
- 💬 **Anonymous Community Forum** – Safe space to ask questions and share experiences under pseudonyms  
- 🎁 **Voice Encouragement Tree** – Send and receive supportive anonymous voice messages  
- 🏆 **Gamified Weekly Progress Ring** – Earn points for healthy actions and track weekly achievements  
- 👤 **Profile & Appointments** – View basic profile information, mood history, and upcoming appointments  

---

## 🧱 Tech Stack

- **Frontend:** Flutter (Dart SDK 3.8.1)  
- **State Management:** `provider`  
- **Networking:** `dio`  
- **Secure Storage:** `flutter_secure_storage`  
- **Backend API:** Spring Boot + MyBatis + MySQL 
- **Firebase:** For project configuration (e.g. hosting / analytics) via `firebase_options.dart`


---

# Basic Usage Flow

### 1. Register or Log In
- usage of google api to login
- might have to set up api on your end to enable it.

---

### 2. Onboarding Questionnaire
- Complete PHQ-9 and GAD-7 assessments  
- Used to personalize article recommendations
- the articles are in assets/articles for you to inlcude into your storage

---

### 3. Home Dashboard
- Weekly Progress Ring  
- Task list and points tracking  
- Quick navigation to features  

---

### 4. Mood Tracker
- Emoji selection for daily mood  
- Typed journal reflection  
- Monthly mood overview calendar  

---

### 5. Articles Section
- Browse curated mental health articles  
- Content grouped by topics (Anxiety, Stress, Self-care, etc.)  
- Personalized recommendations  

---

### 6. Community Forum
- Anonymous posting & replying  
- Peer support for mental health discussions  
- All posts moderated before publication  

---

### 7. Voice Encouragement Tree
- Send supportive voice messages  
- Receive random anonymous audio encouragement  

---

### 8. Profile Page
- View and edit user profile  
- Track weekly points and achievements  
- Record upcoming appointments  
- Access mood history  

---


