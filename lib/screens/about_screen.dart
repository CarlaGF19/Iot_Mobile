import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_widget.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Acerca de',
          style: TextStyle(color: Color(0xFF498428)), // Verde oscuro para el texto
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProjectHeader(),
            const SizedBox(height: 20),
            _buildProjectDescription(),
            const SizedBox(height: 20),
            _buildTechnicalSpecs(),
            const SizedBox(height: 20),
            _buildFeatures(),
            const SizedBox(height: 20),
            _buildTeamInfo(),
            const SizedBox(height: 20),
            _buildVersionInfo(),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: 2),
    );
  }

  Widget _buildProjectHeader() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF498428), // Verde oscuro
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.sensors,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'IoT Monitor App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF498428), // Verde oscuro
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sistema de Monitoreo IoT con ESP32',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectDescription() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.description, color: Color(0xFF498428)), // Verde oscuro
                const SizedBox(width: 8),
                const Text(
                  'Descripción del Proyecto',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Esta aplicación móvil permite monitorear en tiempo real sensores IoT conectados a un microcontrolador ESP32. '
              'El sistema recopila datos de temperatura, humedad, pH y TDS (sólidos disueltos totales), '
              'proporcionando una interfaz intuitiva para visualizar y analizar la información.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'Características principales:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildFeatureItem('📊', 'Monitoreo en tiempo real'),
            _buildFeatureItem('📱', 'Interfaz móvil intuitiva'),
            _buildFeatureItem('🌐', 'Conectividad WiFi'),
            _buildFeatureItem('📸', 'Galería de imágenes'),
            _buildFeatureItem('⚙️', 'Configuración de dispositivos'),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicalSpecs() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.memory, color: Color(0xFF498428)), // Verde oscuro
                const SizedBox(width: 8),
                const Text(
                  'Especificaciones Técnicas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSpecItem('Microcontrolador', 'ESP32'),
            _buildSpecItem('Conectividad', 'WiFi 802.11 b/g/n'),
            _buildSpecItem('Sensores', 'Temperatura, Humedad, pH, TDS'),
            _buildSpecItem('Protocolo', 'HTTP/TCP'),
            _buildSpecItem('Plataforma Móvil', 'Flutter (Android/iOS)'),
            _buildSpecItem('Arquitectura', 'GoRouter + Material Design'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatures() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFF498428)), // Verde oscuro
                const SizedBox(width: 8),
                const Text(
                  'Funcionalidades',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFunctionalityItem(
              Icons.dashboard,
              'Dashboard Principal',
              'Vista general de todos los sensores con datos en tiempo real',
            ),
            _buildFunctionalityItem(
              Icons.settings_input_antenna,
              'Gestión de Dispositivos',
              'Configuración y monitoreo del estado de conexión ESP32',
            ),
            _buildFunctionalityItem(
              Icons.photo_library,
              'Galería de Imágenes',
              'Visualización de imágenes capturadas por el sistema',
            ),
            _buildFunctionalityItem(
              Icons.analytics,
              'Análisis de Datos',
              'Gráficos y estadísticas detalladas de los sensores',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamInfo() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.group, color: Color(0xFF498428)), // Verde oscuro
                const SizedBox(width: 8),
                const Text(
                  'Información del Equipo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Proyecto desarrollado como parte del curso de Sistemas IoT.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            _buildTeamMember('👨‍💻', 'Desarrollo de Software', 'Aplicación móvil Flutter'),
            _buildTeamMember('🔧', 'Hardware IoT', 'Configuración ESP32 y sensores'),
            _buildTeamMember('🌐', 'Conectividad', 'Protocolos de comunicación'),
            _buildTeamMember('📊', 'Análisis de Datos', 'Procesamiento y visualización'),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF498428)), // Verde oscuro
                const SizedBox(width: 8),
                const Text(
                  'Información de Versión',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildVersionItem('Versión de la App', '1.0.0'),
            _buildVersionItem('Fecha de Compilación', DateTime.now().toString().split(' ')[0]),
            _buildVersionItem('Flutter SDK', '3.x.x'),
            _buildVersionItem('Plataforma', 'Android/iOS'),
            const SizedBox(height: 16),
            const Text(
              '© 2024 IoT Monitor App. Todos los derechos reservados.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSpecItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$title:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFunctionalityItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2196F3), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMember(String emoji, String role, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2196F3),
            ),
          ),
        ],
      ),
    );
  }
}