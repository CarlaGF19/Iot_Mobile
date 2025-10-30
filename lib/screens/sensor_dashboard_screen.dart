import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sensor_detail_page.dart';
import '../widgets/bottom_navigation_widget.dart';

class SensorDashboardScreen extends StatefulWidget {
  final String ip;
  
  const SensorDashboardScreen({super.key, required this.ip});

  @override
  State<SensorDashboardScreen> createState() => _SensorDashboardScreenState();
}

class _SensorDashboardScreenState extends State<SensorDashboardScreen> {
  String? esp32Ip;

  @override
  void initState() {
    super.initState();
    esp32Ip = widget.ip.isNotEmpty ? widget.ip : null;
    _loadIp();
  }

  Future<void> _loadIp() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      esp32Ip = prefs.getString("esp32_ip");
    });
  }

  Future<void> _setIpDialog() async {
    final TextEditingController controller = TextEditingController(
      text: esp32Ip ?? "",
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Configurar IP del ESP32"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: "Dirección IP",
              hintText: "http://192.168.x.xxx",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString("esp32_ip", controller.text.trim());
                setState(() {
                  esp32Ip = controller.text.trim();
                });
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  void _abrirSensor(String tipo, String titulo) {
    if (esp32Ip == null || esp32Ip!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Primero configura la IP del ESP32")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SensorDetailPage(esp32Ip: esp32Ip!, tipo: tipo, titulo: titulo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Esquinas completamente rectas
        ),
        title: Text(
          "IoT Monitor",
          style: TextStyle(
            color: const Color(0xFF498428), // Verde oscuro para el texto
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF498428)), // Verde oscuro para el ícono
            onPressed: _setIpDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            SensorCard(
              titulo: "TEMPERATURA",
              icono: Icons.device_thermostat,
              onTap: () => _abrirSensor("temperatura", "Temperatura"),
            ),
            SensorCard(
              titulo: "HUMEDAD",
              icono: Icons.water_drop,
              onTap: () => _abrirSensor("humedad", "Humedad"),
            ),
            SensorCard(
              titulo: "PH",
              icono: Icons.science,
              onTap: () => _abrirSensor("ph", "pH"),
            ),
            SensorCard(
              titulo: "TDS",
              icono: Icons.water,
              onTap: () => _abrirSensor("tds", "TDS"),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: 2), // Device
    );
  }
}

class SensorCard extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final VoidCallback onTap;

  const SensorCard({
    super.key,
    required this.titulo,
    required this.icono,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 64, 95, 65),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  color: Color(0xFFDDDDDD),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Icon(icono, color: Color(0xFFDDDDDD), size: 36),
              const SizedBox(height: 10),
              const Text(
                "Ver detalles",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
