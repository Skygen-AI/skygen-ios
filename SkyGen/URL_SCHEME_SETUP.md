# Настройка URL схемы для Deep Links

## Инструкция по настройке `skygen://` URL схемы в Xcode:

### Шаги настройки:

1. **Откройте проект в Xcode**
   - Откройте `SkyGen.xcodeproj`

2. **Выберите Target**
   - Выберите проект "SkyGen" в навигаторе проектов (слева)
   - Выберите target "SkyGen" в разделе TARGETS

3. **Перейдите в Info**
   - Перейдите на вкладку "Info"
   - Найдите раздел "URL Types"

4. **Добавьте URL Type**
   - Нажмите "+" чтобы добавить новый URL Type
   - Заполните поля:
     - **Identifier**: `com.skygen.deeplink`
     - **URL Schemes**: `skygen`
     - **Role**: `Editor` (по умолчанию)

### Результат:
После настройки приложение будет обрабатывать URL вида:
- `skygen://chat/123`
- `skygen://device/456` 
- `skygen://action/789`
- `skygen://integration/gmail`
- `skygen://settings`
- `skygen://settings/profile`

### Тестирование:
Можно тестировать deep links через:
- Симулятор: Device → Device → URL Scheme
- Terminal: `xcrun simctl openurl booted "skygen://chat/test"`
- Safari на устройстве: введите URL в адресной строке

### Альтернативный способ (через Info.plist):
Если предпочитаете редактировать Info.plist напрямую, добавьте в корень:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.skygen.deeplink</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>skygen</string>
        </array>
    </dict>
</array>
```

После настройки URL схемы deep links будут работать автоматически через код в `DeepLinkManager` и `MainTabView`.
