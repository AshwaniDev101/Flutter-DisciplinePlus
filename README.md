# DisciplinePlus

DisciplinePlus is a lightweight, offline-first productivity app I built to help users form habits, plan initiatives, and maintain a daily log.  
*A productivity app designed to help you build strong habits and master self-discipline. Set daily goals, track progress, and stay motivated with reminders and visual heatmaps.*

---

## 📸 Screenshots

### 📱 App Overview
<div style="text-align: center">
  <img src="screenshots/drawer.jpg" width="22%" alt="Drawer Menu" />
  <img src="screenshots/im_homepage.jpg" width="22%" alt="Initiative Homepage" />
  <img src="screenshots/lm_homepage.jpg" width="22%" alt="Log Homepage" />
  <img src="screenshots/htm_homepage.jpg" width="22%" alt="Habit Tracker Homepage" />
</div>

### 🎯 Initiative Manager
<div style="text-align: center">
  <img src="screenshots/im_global.jpg" width="22%" alt="Global Initiatives" />
  <img src="screenshots/im_homepage_c.jpg" width="22%" alt="Completed Initiatives" />
  <img src="screenshots/timerpage_pause.jpg" width="22%" alt="Timer Function" />
  <img src="screenshots/im_homepage_heatmap.jpg" width="22%" alt="Initiative Heatmap" />
</div>

### 📝 Daily Log & Notes
<div style="text-align: center">
  <img src="screenshots/lm_new_log.jpg" width="22%" alt="New Log Entry" />
  <img src="screenshots/lm_a_notes.jpg" width="22%" alt="Notes List" />
  <img src="screenshots/lm_tags.jpg" width="22%" alt="Tags Management" />
  <img src="screenshots/im_user_settings.jpg" width="22%" alt="User Settings" />
</div>

### 🔥 Habit Tracker
<div style="text-align: center">
  <img src="screenshots/htm_homepage.jpg" width="22%" alt="Habit Tracker Overview" />
</div>

---

## 🧩 Modules

### 1. Initiative Manager
Helps you create structured study/work initiatives and schedule them across the week.  
Features include reordering, timers, completion tracking, and history logs.

### 2. Habit Tracker
A simple daily habit system with marking, streaks, monthly heatmaps, and analytics.

### 3. Daily Log / Notes
A quick logging system for daily reflections. Logs can be linked to initiatives and sorted.  
Password protection is optional based on user settings.

---

## ⭐ Key Features

- Offline-first architecture using **Drift** as the local authoritative database
- Background synchronization with **Firebase Firestore**
- Cross-platform support (Android + Web; iOS possible)
- Clean UI with heatmaps and progress visuals
- JSON export / backup support
- Riverpod-based state management
- Drift migrations to ensure stable versioned data updates

---

## 🛠 Tech Stack

- **Flutter & Dart**
- **Drift (SQLite)** for local DB
- **Firebase Authentication + Firestore**
- **Riverpod** for state management
- **Flutter Test & Firebase Emulator** for testing workflow

---

## 🚀 Getting Started (Developer Setup)

### 1. Clone Repository
```bash
git clone https://github.com/AshwaniDev101/Flutter-DisciplinePlus.git
cd Flutter-DisciplinePlus
```

MIT License  
© 2025 Ashwani yadav
