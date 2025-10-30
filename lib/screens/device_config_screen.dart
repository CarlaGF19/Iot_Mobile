import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceConfigScreen extends StatefulWidget {
  const DeviceConfigScreen({super.key});

  @override
  State<DeviceConfigScreen> createState() => _DeviceConfigScreenState();
}

class _DeviceConfigScreenState extends State<DeviceConfigScreen> {
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
    context.go('/main-menu');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco
      appBar: AppBar(
        backgroundColor: Colors.transparent, // AppBar transparente
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Esquinas completamente rectas
        ),
        clipBehavior: Clip.none, // Sin recorte que pueda crear bordes redondeados
        title: const Text(
          "Configurar IP del ESP32",
          style: TextStyle(color: Color(0xFF498428)), // Verde oscuro para el texto
        ),
        iconTheme: const IconThemeData(color: Color(0xFF498428)), // Verde oscuro para los iconos
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Ingresa la dirección IP del ESP32",
              style: TextStyle(
                color: Color(0xFF498428), // Verde oscuro para el texto
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: "Ejemplo: http://192.168.1.10",
                labelStyle: TextStyle(color: Color(0xFF80B155)), // Verde medio para el label
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF498428), width: 2), // Verde oscuro para el borde activo
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF80B155)), // Verde medio para el borde normal
                ),
              ),
              style: const TextStyle(color: Color(0xFF498428)), // Verde oscuro para el texto ingresado
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saveIp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF80B155), // Verde medio para el fondo del botón
                foregroundColor: Colors.white, // Texto blanco
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                "Guardar y continuar",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: const Color(0xFF498428), // Verde oscuro en lugar del azul
        onPressed: () {
          context.go('/main-menu');
        },
        child: const Icon(
          Icons.arrow_forward,
          size: 20,
          color: Colors.white,
        ),
      ),
    );
  }
}
