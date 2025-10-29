import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IpScreen extends StatefulWidget {
  const IpScreen({super.key});

  @override
  State<IpScreen> createState() => _IpScreenState();
}

class _IpScreenState extends State<IpScreen> {
  final TextEditingController _ipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedIp();
  }

  Future<void> _loadSavedIp() async {
    final prefs = await SharedPreferences.getInstance();
    _ipController.text = prefs.getString("esp32_ip") ?? "";
  }

  Future<void> _saveIp() async {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("esp32_ip", ip);

    if (!mounted) return;
    context.go('/home', extra: ip);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configurar IP del ESP32")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Ingresa la dirección IP del ESP32"),
            const SizedBox(height: 16),
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: "Ejemplo: http://192.168.1.10",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saveIp,
              icon: const Icon(Icons.save),
              label: const Text("Guardar y continuar"),
            ),
          ],
        ),
      ),
    );
  }
}
