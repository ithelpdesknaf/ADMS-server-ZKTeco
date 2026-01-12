#!/bin/bash

# دالة لطباعة الرسائل الملونة
print_message() {
    COLOR=$1
    MESSAGE=$2
    NC='\033[0m' # No Color
    case $COLOR in
        "green")
            echo -e "\033[0;32m${MESSAGE}${NC}"
            ;;
        "red")
            echo -e "\033[0;31m${MESSAGE}${NC}"
            ;;
        "yellow")
            echo -e "\033[0;33m${MESSAGE}${NC}"
            ;;
        *)
            echo "${MESSAGE}"
            ;;
    esac
}

# بداية السكربت
print_message "green" "Starting the project setup script for Linux/macOS..."

# الخطوة 1: التحقق من وجود Docker
if ! docker info > /dev/null 2>&1; then
    print_message "red" "Error: Docker is not running or not installed. Please start Docker and try again."
    exit 1
fi

# الخطوة 2: نسخ ملف البيئة إذا لم يكن موجودًا
if [ ! -f ".env" ]; then
    print_message "green" "Creating .env file from .env.example..."
    cp .env.example .env
else
    print_message "yellow" ".env file already exists. Skipping creation."
fi

# الخطوة 3: بناء وتشغيل حاويات Docker
print_message "green" "Building and starting Docker containers... (This may take a while on the first run)"
./vendor/bin/sail up -d --build
if [ $? -ne 0 ]; then
    print_message "red" "Failed to build and start containers. Please check the Docker logs."
    exit 1
fi

# الخطوة 4: تثبيت الاعتماديات (Composer & NPM)
print_message "green" "Installing Composer dependencies..."
./vendor/bin/sail composer install
if [ $? -ne 0 ]; then
    print_message "red" "Failed to install Composer dependencies."
    exit 1
fi

print_message "green" "Installing NPM dependencies..."
./vendor/bin/sail npm install
if [ $? -ne 0 ]; then
    print_message "yellow" "NPM install failed, but continuing setup..."
fi

# الخطوة 5: إعادة تشغيل الحاويات لبدء الخادم بشكل صحيح
print_message "green" "Restarting containers to ensure the server starts correctly..."
./vendor/bin/sail restart
if [ $? -ne 0 ]; then
    print_message "red" "Failed to restart containers."
    exit 1
fi

# الخطوة 6: توليد مفتاح التطبيق
print_message "green" "Generating application key..."
./vendor/bin/sail artisan key:generate
if [ $? -ne 0 ]; then
    print_message "red" "Failed to generate application key."
    exit 1
fi

# الخطوة 7: تشغيل ترحيل قاعدة البيانات
print_message "green" "Running database migrations..."
./vendor/bin/sail artisan migrate
if [ $? -ne 0 ]; then
    print_message "yellow" "Failed to run database migrations. You may need to run them manually."
fi

# رسالة النهاية
print_message "green" "=========================================="
print_message "green" "Setup Complete! The application is now running."
print_message "green" "Backend URL: http://localhost:8080"
print_message "green" "Mailpit (Email Capture): http://localhost:8025"
print_message "green" "You can stop the containers by running: ./vendor/bin/sail down"
print_message "green" "=========================================="
