import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'sensor_dashboard_screen.dart';
import 'image_gallery_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  String _connectionStatus = 'Verificando...';
  Color _connectionColor = Colors.orange;
  Timer? _connectionTimer;
  String _esp32Ip = '';

  @override
  void initState() {
    super.initState();
    _loadIpAndCheckConnection();
    // Verificar conexión cada 30 segundos
    _connectionTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkConnection();
    });
  }

  @override
  void dispose() {
    _connectionTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadIpAndCheckConnection() async {
    final prefs = await SharedPreferences.getInstance();
    _esp32Ip = prefs.getString("esp32_ip") ?? "";
    await _checkConnection();
  }

  Future<void> _checkConnection() async {
    if (_esp32Ip.isEmpty) {
      setState(() {
        _connectionStatus = 'IP no configurada';
        _connectionColor = Colors.red;
      });
      return;
    }

    try {
      setState(() {
        _connectionStatus = 'Verificando...';
        _connectionColor = Colors.orange;
      });

      final response = await http.get(
        Uri.parse('http://$_esp32Ip/status'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        setState(() {
          _connectionStatus = 'ESP32 Conectado';
          _connectionColor = Colors.green;
        });
      } else {
        setState(() {
          _connectionStatus = 'ESP32 Desconectado';
          _connectionColor = Colors.red;
        });
      }
    } catch (e) {
      setState(() {
        _connectionStatus = 'ESP32 Desconectado';
        _connectionColor = Colors.red;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'IoT Monitor',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Estado de conexión
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _connectionColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _connectionColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _connectionColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _connectionStatus,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _connectionColor.withValues(alpha: 0.8),
                      ),
                    ),
                    const Spacer(),
                    if (_connectionStatus == 'Verificando...')
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(_connectionColor),
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Título de sección
              Text(
                'Selecciona una opción',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Accede a las funcionalidades principales',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Opciones del menú
              Expanded(
                child: ListView(
                  children: [
                    // Dashboard de Sensores
                    _buildMenuCard(
                      context: context,
                      icon: Icons.sensors,
                      title: 'Dashboard de Sensores',
                      description: 'Monitoreo de temperatura, humedad, pH, TDS',
                      color: Colors.blue,
                      onTap: () async {
                        // Usar la IP ya cargada
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SensorDashboardScreen(ip: _esp32Ip),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Galería de Imágenes
                    _buildMenuCard(
                      context: context,
                      icon: Icons.photo_library,
                      title: 'Galería de Imágenes',
                      description: 'Captura y visualización de imágenes',
                      color: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ImageGalleryScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 55,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.1),
                  color.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Row(
              children: [
                // Icono
                 Container(
                   width: 40,
                   height: 40,
                   decoration: BoxDecoration(
                     color: color.withValues(alpha: 0.2),
                     borderRadius: BorderRadius.circular(20),
                   ),
                   child: Icon(
                     icon,
                     size: 20,
                     color: color,
                   ),
                 ),
                
                const SizedBox(width: 16),
                
                // Contenido
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                         title,
                         style: TextStyle(
                           fontSize: 14,
                           fontWeight: FontWeight.bold,
                           color: Colors.grey.shade800,
                         ),
                         maxLines: 1,
                         overflow: TextOverflow.ellipsis,
                       ),
                       Text(
                         description,
                         style: TextStyle(
                           fontSize: 10,
                           color: Colors.grey.shade600,
                           height: 1.0,
                         ),
                         maxLines: 2,
                         overflow: TextOverflow.ellipsis,
                       ),
                    ],
                  ),
                ),
                
                // Flecha
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}