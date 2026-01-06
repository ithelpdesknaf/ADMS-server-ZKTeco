<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\DeviceController;
use App\Http\Controllers\iclockController;
use App\Http\Controllers\EmployeeController;
use App\Http\Controllers\UserController;


Route::middleware(['auth'])->group(function () {
    Route::get('/change-password', [App\Http\Controllers\UserController::class, 'showChangePasswordForm'])->name('password.change');
    Route::post('/change-password', [App\Http\Controllers\UserController::class, 'changePassword'])->name('admin-password.update');
});

Route::middleware(['auth', 'changePwd'])->group(function () {
    Route::get('/', function () {
        return redirect('attendance');
    });

    Route::get('attendance', [DeviceController::class, 'Attendance'])->name('devices.Attendance');
    Route::get('attendance/data', [DeviceController::class, 'getAttendance'])->name('devices.getAttendance');

    Route::get('daily', [DeviceController::class, 'daily'])->name('devices.daily');
    Route::get('daily/data', [DeviceController::class, 'getDailyAttendanceSummary'])->name('devices.getDailyAttendanceSummary');
    Route::get('monthly', [DeviceController::class, 'monthly'])->name('devices.monthly');
    Route::get('monthly/data', [DeviceController::class, 'getMonthlyAttendanceSummary'])->name('devices.getMonthlyAttendanceSummary');

    Route::middleware(['admin'])->group(function () {
        Route::get('map_id', [EmployeeController::class, 'Index'])->name('employee.MapId');
        Route::post('map_id', [EmployeeController::class, 'Store'])->name('employee.store');
        Route::get('devices', [DeviceController::class, 'Index'])->name('devices.index');
        Route::get('devices-log', [DeviceController::class, 'DeviceLog'])->name('devices.DeviceLog');
        Route::get('finger-log', [DeviceController::class, 'FingerLog'])->name('devices.FingerLog');
        Route::get('users', [UserController::class, 'Index'])->name('users.index');
        Route::post('users', [UserController::class, 'Store'])->name('users.store');
        Route::delete('/users/{id}', [UserController::class, 'Destroy'])->name('users.destroy');
    });
});

Auth::routes(['register' => false]);

Route::get('/home', function () {
    return redirect('/attendance');
});


/************************************************************************************************************/
//                                Restricted area don't remove or update                                    //
/************************************************************************************************************/

// Restriste
Route::middleware(['iclock.auth'])->group(function () {
    Route::get('/iclock/cdata', [iclockController::class, 'handshake']);
    Route::post('/iclock/cdata', [iclockController::class, 'receiveRecords']);

    Route::get('/iclock/test', [iclockController::class, 'test']);
    Route::get('/iclock/getrequest', [iclockController::class, 'getrequest']);
});

