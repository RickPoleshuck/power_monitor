import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:power_monitor/config.dart';
import 'package:power_monitor/power.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _formKey = GlobalKey<FormBuilderState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Power Monitor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Power Monitor'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: _form());
  }

  Widget _form() {
    return FutureBuilder<Config>(
      builder: (context, snap) {
        if (!snap.hasData) {
          return const CircularProgressIndicator();
        }
        return Center(
          child: FormBuilder(
            key: _formKey,
            initialValue: snap.data!.toMap(),
            child: Column(
              children: <Widget>[
                FormBuilderSwitch(
                  name: 'active',
                  title: const Text('Active'),
                ),
                FormBuilderTextField(
                  name: 'host',
                  decoration: const InputDecoration(
                    labelText: 'SSH Host',
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(context),
                    FormBuilderValidators.max(context, 50),
                  ]),
                  keyboardType: TextInputType.text,
                ),
                FormBuilderTextField(
                  name: 'user',
                  decoration: const InputDecoration(
                    labelText: 'SSH User',
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(context),
                    FormBuilderValidators.max(context, 50),
                  ]),
                  keyboardType: TextInputType.text,
                ),
                FormBuilderTextField(
                  name: 'passwd',
                  decoration: const InputDecoration(
                    labelText: 'SSH Password',
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(context),
                    FormBuilderValidators.max(context, 50),
                    FormBuilderValidators.min(context, 5),
                  ]),
                  keyboardType: TextInputType.text,
                  obscureText: true,
                ),
                FormBuilderSlider(
                  name: 'delayMin',
                  decoration: const InputDecoration(
                    labelText: 'Delay in minutes',
                  ),
                  min: 1,
                  max: 10,
                  initialValue: snap.data!.delayMin,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: MaterialButton(
                        color: Theme.of(context).colorScheme.secondary,
                        child: const Text(
                          "Submit",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          _formKey.currentState?.save();
                          var validated = _formKey.currentState == null ? false : _formKey.currentState!.validate();
                          if (validated) {
                            final fields = _formKey.currentState!.fields;
                            Config c = Config(
                              fields['active']?.value,
                              fields['host']?.value,
                              fields['user']?.value,
                              fields['passwd']?.value,
                              fields['delayMin']?.value,
                            );
                            _save(c);
                          } else {
                            print("validation failed");
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: MaterialButton(
                        color: Theme.of(context).colorScheme.secondary,
                        child: const Text(
                          "Reset",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          Config c = await _read();
                          _formKey.currentState?.patchValue({
                            'active': c.active,
                            'host': c.host,
                            'user': c.user,
                            'passwd': c.passwd,
                          });
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
      future: _read(),
    );
  }

  Future<Config> _read() async {
    final prefs = await SharedPreferences.getInstance();
    final active = prefs.getBool('active') ?? false;
    final host = prefs.getString('host') ?? '';
    final user = prefs.getString('user') ?? '';
    final passwd = prefs.getString('passwd') ?? '';
    final delayMin = prefs.getDouble('delayMin') ?? 5.0;
    return Config(active, host, user, passwd, delayMin);
  }

  _save(Config c) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('active', c.active);
    prefs.setString('host', c.host);
    prefs.setString('user', c.user);
    prefs.setString('passwd', c.passwd);
    prefs.setDouble('delayMin', c.delayMin);
    if (c.active) {
      Power(c).run();
    }
  }
}
