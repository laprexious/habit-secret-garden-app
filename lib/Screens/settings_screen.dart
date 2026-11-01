import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});


  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}
// add previously saved settings when screen opens
class _SettingsScreenState extends State<SettingsScreen> {
  int _weeklyTarget = 4;
  bool _reduceMotion = false;
    @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  //load saved settings
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _weeklyTarget = prefs.getInt('weeklyTarget') ?? 4;
      _reduceMotion = prefs.getBool('reduceMotion') ?? false;
    });
  }
  // save changes button for app
    // save settings
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('weeklyTarget', _weeklyTarget);
    await prefs.setBool('reduceMotion', _reduceMotion);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved!')),
    );
  }
  // app widget buikld
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: const Color(0xFFE2D9C9),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Default Weekly Target',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '$_weeklyTarget days per week',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  // slider ui 
                    Slider(
                      value: _weeklyTarget.toDouble(),
                      min: 1,
                      max: 7,
                      divisions: 6,
                      onChanged: (value) {
                        setState(() {
                          _weeklyTarget = value.round();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
               // toggle ui
            Card(
              color: const Color(0xFFE2D9C9),
              child: SwitchListTile(
                        title: const Text(
                          'Reduce Motion',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          'Reduce animations throughout the app.',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        value: _reduceMotion,
                        activeThumbColor: Theme.of(context).colorScheme.primary,
                        onChanged: (value) {
                          setState(() {
                            _reduceMotion = value;
                          });
                        },
                      ),
                    ),
                    //setting visual
                    const Spacer(),
                    Image.asset(
                      'assets/images/settings-visual.png',
                      fit: BoxFit.contain,
                    ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: _saveSettings,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(16),
          ),
          child: const Text(
            'Save Changes',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
