import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'sensor_dashboard_screen.dart';
import 'image_gallery_screen.dart';
import '../widgets/bottom_navigation_widget.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  String _esp32Ip = '';
  Map<String, dynamic> _sensorData = {};
  bool _isLoading = true;
  Timer? _dataTimer;

  @override
  void initState() {
    super.initState();
    _loadIpAndFetchData();
    // Actualizar datos cada 10 segundos
    _dataTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchSensorData();
    });
  }

  @override
  void dispose() {
    _dataTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadIpAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    _esp32Ip = prefs.getString("esp32_ip") ?? "";
    await _fetchSensorData();
  }

  Future<void> _fetchSensorData() async {
    if (_esp32Ip.isEmpty) {
      setState(() {
        _isLoading = false;
        _sensorData = {};
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://$_esp32Ip/sensors'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        setState(() {
          _sensorData = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _sensorData = {};
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _sensorData = {};
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAEF9D), // Verde muy claro de fondo
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Esquinas completamente rectas
        ),
        clipBehavior: Clip.none, // Sin recorte que pueda crear bordes redondeados
        title: const Text(
          'IoT Monitor',
          style: TextStyle(color: Color(0xFF498428)), // Verde oscuro para el texto
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resumen de Sensores
                _buildSensorSummary(),
                
                const SizedBox(height: 20),
                
                // Accesos Rápidos
                _buildQuickAccess(),
                
                const SizedBox(height: 20),
                
                // Última Actualización
                _buildLastUpdate(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: 0),
    );
  }

  Widget _buildSensorSummary() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sensors, color: Color(0xFF498428), size: 24), // Verde oscuro
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Resumen de Sensores',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (_sensorData.isEmpty)
              const Center(
                child: Text(
                  'No hay datos disponibles\nVerifica la conexión ESP32',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              Column(
                children: [
                  _buildSensorRow('Temperatura', '${_sensorData['temperature'] ?? '--'}°C', Icons.thermostat, Colors.orange),
                  _buildSensorRow('Humedad', '${_sensorData['humidity'] ?? '--'}%', Icons.water_drop, Colors.blue),
                  _buildSensorRow('pH', '${_sensorData['ph'] ?? '--'}', Icons.science, Colors.green),
                  _buildSensorRow('TDS', '${_sensorData['tds'] ?? '--'} ppm', Icons.opacity, Colors.purple),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccess() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flash_on, color: Color(0xFF498428), size: 24), // Verde oscuro
                const SizedBox(width: 8),
                const Text(
                  'Accesos Rápidos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickAccessButton(
                    'Sensores',
                    Icons.dashboard,
                    const Color(0xFF80B155), // Verde medio
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SensorDashboardScreen(ip: _esp32Ip),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAccessButton(
                    'Galería',
                    Icons.photo_library,
                    const Color(0xFFC1D95C), // Verde lima
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ImageGalleryScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastUpdate() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Color(0xFF498428), size: 24), // Verde oscuro
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Última Actualización:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              _isLoading ? 'Cargando...' : DateTime.now().toString().substring(11, 19),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF498428), // Verde oscuro
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}