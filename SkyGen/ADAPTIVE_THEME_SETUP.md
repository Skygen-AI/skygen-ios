# Настройка адаптивной темы SkyGen

## Что нужно сделать в Assets.xcassets

### 1. Добавить цветовые наборы в Assets.xcassets

Для каждого цвета создайте **Color Set** с поддержкой Appearance (Light/Dark):

#### Фоновые цвета:
- `BackgroundColor` 
  - **Light**: `#FFFFFF` (белый)
  - **Dark**: `#202020` (темно-серый)
- `BackgroundSecondaryColor`
  - **Light**: `#F8F9FA` (светло-серый)
  - **Dark**: `#282828`
- `BackgroundTertiaryColor`
  - **Light**: `#F1F3F4` (серый)
  - **Dark**: `#303030`

#### Поверхности:
- `SurfaceColor`
  - **Light**: `#FFFFFF` (белый)
  - **Dark**: `#303030`
- `SurfaceElevatedColor`
  - **Light**: `#FFFFFF` с тенью
  - **Dark**: `#383838`
- `SurfaceHighestColor`
  - **Light**: `#FFFFFF` с сильной тенью
  - **Dark**: `#404040`

#### Текст:
- `TextPrimaryColor`
  - **Light**: `#000000` (черный)
  - **Dark**: `#FFFFFF` (белый)
- `TextSecondaryColor`
  - **Light**: `#666666` (темно-серый)
  - **Dark**: `#CCCCCC` (светло-серый)
- `TextTertiaryColor`
  - **Light**: `#999999` (серый)
  - **Dark**: `#999999`
- `TextDisabledColor`
  - **Light**: `#CCCCCC` (светло-серый)
  - **Dark**: `#666666` (темно-серый)

#### Границы:
- `BorderColor`
  - **Light**: `#E0E0E0` (светлая граница)
  - **Dark**: `#505050` (темная граница)
- `BorderSubtleColor`
  - **Light**: `#F0F0F0`
  - **Dark**: `#484848`
- `DividerColor`
  - **Light**: `#DADCE0`
  - **Dark**: `#606060`

#### Интерактивные элементы:
- `InteractivePressedColor`
  - **Light**: `#4D99E6` (темнее акцента)
  - **Dark**: `#4D99E6`
- `InteractiveDisabledColor`
  - **Light**: `#E0E0E0` (светлый)
  - **Dark**: `#4D4D4D` (темный)

#### Семантические цвета:
- `SuccessColor`
  - **Light**: `#34A853` (зеленый)
  - **Dark**: `#33CC66` (светло-зеленый)
- `WarningColor`
  - **Light**: `#FBBC04` (оранжевый)
  - **Dark**: `#FFCC33` (желтый)
- `ErrorColor`
  - **Light**: `#EA4335` (красный)
  - **Dark**: `#FF4D4D` (ярко-красный)

### 2. Как создать Color Set в Xcode:

1. Откройте `Assets.xcassets`
2. Нажмите **+** → **Color Set**
3. Назовите цвет (например, `BackgroundColor`)
4. В **Attributes Inspector** установите **Appearances**: `Any, Light, Dark`
5. Настройте цвета для каждого режима:
   - **Any/Light**: цвет для светлой темы
   - **Dark**: цвет для темной темы

### 3. Автоматическое переключение

После настройки цветов приложение будет автоматически:
- ✅ Следовать системным настройкам (Light/Dark mode)
- ✅ Переключаться в реальном времени при изменении темы
- ✅ Сохранять состояние при перезапуске

### 4. Принудительное переключение темы (опционально)

Если нужно добавить переключатель темы в настройках:

```swift
// В SettingsView добавить:
@Environment(\.colorScheme) var colorScheme

// Кнопка переключения:
Button("Toggle Theme") {
    // Переключение через UserDefaults
}
```

### 5. Результат

После настройки:
- **Светлая тема**: белый фон, черный текст, светлые поверхности
- **Темная тема**: темный фон, белый текст, темные поверхности  
- **Плавные переходы** между темами
- **Системная интеграция** с iOS
