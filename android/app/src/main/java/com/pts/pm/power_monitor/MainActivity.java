package com.pts.pm.power_monitor;

import android.content.Intent;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine
                .getDartExecutor()
                .getBinaryMessenger(), "power_monitor_service")
                .setMethodCallHandler(
                        (call, result) -> {
                            switch (call.method) {
                                case "startService":
                                    Intent intent =
                                            new Intent(this, PowerMonitorService.class);
                                    startService(intent);
                                    result.success(Boolean.TRUE);
                                    break;
                                default:
                                    throw new RuntimeException("Invalid method: " + call.method);
                            }
                        }
                );
    }
}
