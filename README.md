# Skygen iOS

🍎 **iOS версия Skygen на React Native/SwiftUI**

## Особенности
- ✅ Нативная производительность iOS
- ✅ Оптимизация для iPhone/iPad
- ✅ Интеграция с iOS системными API
- ✅ Face ID/Touch ID авторизация
- ✅ Siri Shortcuts

## Установка и запуск

### Требования
- macOS (для разработки под iOS)
- Xcode 14+
- Node.js 18+
- iOS Simulator или физическое устройство iOS 12+
- Apple Developer Account (для публикации)

### Настройка среды разработки
```bash
npm install -g react-native-cli
cd ios && pod install
```

### Разработка
```bash
npm install
npm run ios
```

### Сборка для App Store
```bash
npm run build:ios
```

### Структура
```
skygen-ios/
├── src/               # React Native компоненты  
│   ├── components/    # UI компоненты
│   ├── screens/       # Экраны приложения
│   ├── services/      # API сервисы
│   └── navigation/    # Навигация
├── ios/               # Нативный iOS код (Swift)
├── assets/            # Изображения и ресурсы
└── package.json       # Зависимости
```

## iOS-специфичные функции
- ✅ App Store распространение
- ✅ iOS уведомления и badges
- ✅ Home Screen widgets
- ✅ Интеграция с iOS Share Sheet
- ✅ Background App Refresh
- ✅ Face ID/Touch ID
- ✅ Siri Shortcuts
- ✅ Apple Watch поддержка (планируется)
