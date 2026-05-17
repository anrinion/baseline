# The Baseline

| Icon | Description |
|:---:|:---|
| <img width="48" height="48" alt="App icon" src="https://github.com/user-attachments/assets/c7a550f7-979d-4823-ab4e-afa483745af9"> | **Gentle self-care for depression, disability, chronic illness, or burnout.** |

[![GitHub license](https://img.shields.io/github/license/anrinion/baseline)](https://github.com/anrinion/baseline/blob/main/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/anrinion/baseline)](https://github.com/anrinion/baseline/stargazers)
[![GitHub release](https://img.shields.io/github/v/release/anrinion/baseline)](https://github.com/anrinion/baseline/releases)

[<img src="https://f-droid.org/badge/get-it-on.png" alt="Get it on F-Droid" width="200">](https://f-droid.org/packages/io.github.anrinion.baseline)

> [!IMPORTANT]
> Your (yes, your 🫵!) feedback is needed to make Baseline better. What functionality is missing? How can we improve your experience? Any feedback, positive or negative, is appreciated - please just create a new issue.

## About

🇷🇺 version is [below](#about_ru).

**The Baseline** is a minimal, gentle self-care app companion designed for people who struggle to maintain basic level of functioning (hence the name). It aims to help with these foundations, without pressure, motivation attempts or guilt promotion.

### Install

**Option 1: F-Droid** (recommended for automatic updates)
- Install via [F-Droid](https://f-droid.org/packages/io.github.anrinion.baseline)

**Option 2: Obtainium**
1. Install [Obtainium](https://github.com/ImranR98/Obtainium)
2. "Add App" and enter this repository URL: `https://github.com/anrinion/baseline`

**Option 3: Manual APK**
- Download the latest APK from [GitHub Releases](https://github.com/anrinion/baseline/releases)

### Preview

| Main screen | Sleep | Meds | Settings |
|:---:|:---:|:---:|:---:|
| <img width="200" alt="main" src="https://github.com/user-attachments/assets/836fa056-9f41-47bd-85c7-491f7a33cfb2" /> | <img width="200" alt="sleep" src="https://github.com/user-attachments/assets/0b69740a-35a4-4cf5-960c-9c49cf10970a" /> | <img width="200" alt="meds" src="https://github.com/user-attachments/assets/75713817-8146-466e-b72e-e447899ffac3" /> | <img width="200" alt="settings" src="https://github.com/user-attachments/assets/b1adc0f5-224c-465b-9ba5-49ff6daf150c" /> |


| Compact mode |
|:---:|
| <img width="200" alt="main_compact" src="https://github.com/user-attachments/assets/d5f600c1-51da-46bd-9862-5ba37b22a5f8" /> | 

### Features

The app consists of modules that can be enabled or disabled as needed.

The most important modules are:

- **Food** — make sure you eat at least something every day.
- **Movement** — moving around is really beneficial.
- **Sleep** — if you don't wear any tracking device, you may want to check that you sleep enough.

Additional modules:

- **Mental state** - tools inspired by Cognitive Behavioral Therapy (CBT) principles. You can use one tool at a time. Experiment with them to find what works for you.
- **Medications** — Medication reminders with optional notifications. ⚠️ **DO NOT USE this feature for critical medications, where delay is life-threatening. Mobile OS can be quite agressive with battery optimizations and/or focus modes, so notifications might be delayed or even missed ⚠️**. 
- **Grounding** — this is basically a big green button that you can press. It may or may not help, but it's there.

### Privacy and other policies

- **No tracking** — No analytics, cloud sync, or data collection. The app does not use network connection, ever.
- **No health data access** - The app does not connect to Google Fit/Apple Health or any other health data source.
- **No history** — The app does not store your history of sleep, medications, or food intake. The state resets each day. No user-sourced daily state persists between days *(what does persist? preferences, medications schedule, randomizer results)*.
- **No advertising** — The app does not have any advertisements and will never have.
- **No paywalls reducing functionality** — Available functionality will remain available and won't be removed/paywalled with the next release.

## Russian version: База <a id='about_ru'></a>

**База** - минималистичное приложение для заботы о себе, разработанное для людей, которые испытывают трудности с поддержанием базового уровня функционирования (отсюда и название).

### Установка

**Вариант 1: F-Droid** (рекомендуется для автоматических обновлений)
- Установите через [F-Droid](https://f-droid.org/packages/io.github.anrinion.baseline)

**Вариант 2: Obtainium**
1. Установите <a href="https://github.com/ImranR98/Obtainium"><img src="https://raw.githubusercontent.com/ImranR98/Obtainium/main/assets/graphics/icon_small.png" alt="Obtainium icon" width="18" height="18">Obtainium</a>
2. "Add App", и введите этот репозиторий в качестве URL: `https://github.com/anrinion/baseline`

**Вариант 3: APK вручную**
- Скачайте последний APK из [GitHub Releases](https://github.com/anrinion/baseline/releases)

### Функции приложения

Приложение состоит из модулей, которые можно включать и выключать по необходимости:

- Питание
- Движение
- Сон
- Психологическое здоровье
- Медикаменты ⚠️ **ВАЖНО: не используйте это для жизненно критичных медикаментов, это никогда не будет достаточно надёжно в связи с оптимизациями мобильных ОС.** ⚠️ 
- Осознанность

### Приватность

- **База** не имеет выхода в Интернет - никакой аналитики, синхронизации, рекламы.
- **База** не хранит ваши ежедневные данные в истории - только настройки, расписание медикаментов и свои метаданные.
- **База** не получает доступ к данным от других приложений, включая Google Fit/Apple Health.

## Development

### Milestones & Features Checklist

- [x] Initial demo: food + movement 
- [x] Product design
- [x] State setup (Provider + Hive)  
- [x] Settings
- [x] Food module
- [x] Movement module
- [x] Grounding module
- [x] Adaptive mobile design
- [x] Localization (English + Russian for now) 
- [x] CBT module
- [x] Meds module
- [x] Sleep module
- [x] Sources: explanations + references for all modules  
- [x] Testing (unit, e2e, dogfooding)
- [x] Final design polish
- [x] Fixing bugs
- [x] Android release

### v2 Ideas
- [ ] iOS release
- [ ] "Help" module with regular & emergency paths  
- [ ] More languages
- [ ] More color themes
- [ ] Additional CBT tools or prompts
- [ ] More modules (?)

### Anti-plans

There will be:
- No backend / cloud sync
- No history tracking or past data
- No analytics or usage tracking
- No calorie counting or macro tracking
- No gamification, streaks, or rewards
- No social features or sharing
- No notifications (except optional medication reminders)
- No “perfect days” or performance scores

If you want any of those, try (not sponsored, they are just good):

- **Finch** – gamified pet self-care  
- **Daylio** – mood & history  
- **HabitKit** – streaks & analytics  
- **Yazio** – calorie counting

### Run

flutter pub get  
flutter run
