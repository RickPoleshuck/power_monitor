import 'dart:async';
import 'dart:convert';

import 'package:battery_plus/battery_plus.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:power_monitor/config.dart';

class Power {
  final battery = Battery();
  Timer? _timer;
  final Config _config;

  Power(this._config);

  run() {
    battery.onBatteryStateChanged.listen((BatteryState state) {
      switch (state) {
        case BatteryState.charging:
          _stopCountDown();
          break;
        case BatteryState.discharging:
          _startCountDown();
          break;
        case BatteryState.unknown:
          throw Exception('Battery state is unknown.');
      }
    });
  }

  void _stopCountDown() {
    _timer?.cancel();
  }

  void _startCountDown() {
    var d = Duration(
      minutes: _config.delayMin.toInt(),
      seconds: ((_config.delayMin - _config.delayMin.toInt()) * 60).toInt(),
    );
    _timer = Timer(d, _shutdown);
  }

  void _shutdown() async {
    final socket = await SSHSocket.connect(_config.host, 22);
    final client = SSHClient(
      socket,
      username: _config.user,
      onPasswordRequest: () {
        return _config.passwd;
      },
    );

    final uptime = await client.run('uptime');
    print(utf8.decode(uptime));
    client.close();
    await client.done;
  }
}
