# HAKATON-PROD

1.
ЗАПУСК БЭКЭНДА

cd auth-app/backend
python -m venv venv
venv\Scripts\activate  # Windows
source venv/bin/activate  # Mac/Linux
pip install -r requirements.txt
python app.py

2.
Запуск iOS приложения:

Откройте Xcode

Создайте новый проект "Single View App"

Замените содержимое файлов на код из Swift раздела

В Info.plist добавьте:

xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>

Запустите на симуляторе
