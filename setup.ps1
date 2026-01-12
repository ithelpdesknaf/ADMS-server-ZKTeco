# يطبع رسالة بداية لإعلام المستخدم بأن السكربت قد بدأ
Write-Host "Starting the project setup script for Windows..." -ForegroundColor Green

# الخطوة 1: التحقق من وجود Docker
$dockerCheck = docker --version
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Docker is not running or not installed. Please start Docker Desktop and try again." -ForegroundColor Red
    exit 1
}

# الخطوة 2: نسخ ملف البيئة إذا لم يكن موجودًا
if (-not (Test-Path ".env")) {
    Write-Host "Creating .env file from .env.example..."
    Copy-Item .env.example .env
} else {
    Write-Host ".env file already exists. Skipping creation."
}

# الخطوة 3: بناء وتشغيل حاويات Docker
# سيقوم هذا الأمر ببناء الصور وتشغيل الحاويات في الخلفية
Write-Host "Building and starting Docker containers... (This may take a while on the first run)"
./vendor/bin/sail up -d --build
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to build and start containers. Please check the Docker logs." -ForegroundColor Red
    exit 1
}

# الخطوة 4: تثبيت الاعتماديات (Composer & NPM)
# يقوم بتشغيل الأوامر داخل حاوية التطبيق
Write-Host "Installing Composer dependencies..."
./vendor/bin/sail composer install
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to install Composer dependencies." -ForegroundColor Red
    exit 1
}

Write-Host "Installing NPM dependencies..."
./vendor/bin/sail npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "NPM install failed, but continuing setup..." -ForegroundColor Yellow
}


# الخطوة 5: إعادة تشغيل الحاويات لبدء الخادم بشكل صحيح
Write-Host "Restarting containers to ensure the server starts correctly..."
./vendor/bin/sail restart
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to restart containers." -ForegroundColor Red
    exit 1
}


# الخطوة 6: توليد مفتاح التطبيق
Write-Host "Generating application key..."
./vendor/bin/sail artisan key:generate
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to generate application key." -ForegroundColor Red
    exit 1
}

# الخطوة 7: تشغيل ترحيل قاعدة البيانات
Write-Host "Running database migrations..."
./vendor/bin/sail artisan migrate
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to run database migrations. You may need to run them manually." -ForegroundColor Yellow
}

# رسالة النهاية
Write-Host "Setup Complete! The application is now running." -ForegroundColor Green
Write-Host "Backend URL: http://localhost:8080"
Write-Host "Mailpit (Email Capture): http://localhost:8025"
Write-Host "You can stop the containers by running: ./vendor/bin/sail down"
