import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFE6FFF5),
        elevation: 2,
        title: const Text(
          'Sensores',
          style: TextStyle(
            color: Color(0xFF009E73),
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00E0A6)),
          onPressed: () {
            // Usar pop para evitar conflictos con Navigator.push desde MainMenu
            Navigator.pop(context);
          },
        ),
        iconTheme: const IconThemeData(color: Color(0xFF00E0A6)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          // Ajuste de altura por tile para evitar overflow con contenido
          childAspectRatio: 0.85,
          children: [
            SensorCardWithImage(
              titulo: "TEMPERATURA",
              imagePath: "assets/images/sensor_dashboard/s_temp.png",
              onTap: () => _abrirSensor("temperatura", "Temperatura"),
            ),
            SensorCardWithImage(
              titulo: "HUMEDAD",
              imagePath: "assets/images/sensor_dashboard/s_humedad.png",
              onTap: () => _abrirSensor("humedad", "Humedad"),
            ),
            SensorCardWithImage(
              titulo: "PH",
              imagePath: "assets/images/sensor_dashboard/s_ph.png",
              onTap: () => _abrirSensor("ph", "pH"),
            ),
            SensorCardWithImage(
              titulo: "TDS",
              imagePath: "assets/images/sensor_dashboard/s_tds.png",
              onTap: () => _abrirSensor("tds", "TDS"),
            ),
          ],
        ),
      ),
      // Mantener el BottomNavigation, resaltando Home para coherencia
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: 0),
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
          color: const Color(0xFFE6FFF5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF009E73), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 160, 120, 0.15),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  color: Color(0xFF009E73),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Icon(icono, color: Color(0xFF00E0A6), size: 36),
              const SizedBox(height: 10),
              SensorActionInfo(label: 'Show Details'),
            ],
          ),
        ),
      ),
    );
  }
}

class SensorCardWithImage extends StatelessWidget {
  final String titulo;
  final String imagePath;
  final VoidCallback onTap;

  const SensorCardWithImage({
    super.key,
    required this.titulo,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE6FFF5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF009E73), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 160, 120, 0.15),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Imagen dentro de la card (no superpuesta)
              Image.asset(
                imagePath,
                width: 96,
                height: 96,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.broken_image,
                    color: Color(0xFF00E0A6),
                    size: 96,
                  );
                },
              ),
              const SizedBox(height: 12),
              Text(
                titulo,
                style: const TextStyle(
                  color: Color(0xFF009E73),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              SensorActionInfo(label: 'Show Details'),
            ],
          ),
        ),
      ),
    );
  }
}
// Botón reutilizable tipo "píldora" para el Sensor Dashboard
class SensorActionButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const SensorActionButton({super.key, required this.label, required this.onTap});

  @override
  State<SensorActionButton> createState() => _SensorActionButtonState();
}

class _SensorActionButtonState extends State<SensorActionButton> {
  bool _hovering = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    const Color borderColor = Color(0xFF009E73);
    const Color bgBase = Color(0xFFE6FFF5); // fondo mint claro
    const Color bgHover = Color(0xFF6DFFF5); // hover mint
    final Color textColor = borderColor;
    final Color bg = _hovering ? bgHover : bgBase;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 160, 120, 0.15),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          transform: Matrix4.identity()..scale(_pressed ? 0.98 : 1.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Imagen pequeña dentro del botón
              Image.asset(
                'assets/icons/sensor_s.png',
                width: 22,
                height: 22,
              ),
              const SizedBox(width: 8),
              // Texto principal + mini texto
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'detalles',
                    style: TextStyle(
                      color: const Color(0xFF009E73).withOpacity(0.85),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Bloque informativo no interactivo (imagen + texto + mini texto)
class SensorActionInfo extends StatelessWidget {
  final String label;
  const SensorActionInfo({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF009E73),
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );
  }
}
