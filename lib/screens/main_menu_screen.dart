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
  bool _imageLoaded = false;
  bool _imageExists = false;
  bool _isDisposed = false; // Añadido para evitar setState después de dispose
  bool _isDataFetching =
      false; // Añadido para evitar múltiples llamadas simultáneas

  @override
  void initState() {
    super.initState();
    // Optimización: Cargar datos de forma asíncrona sin bloquear la UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadIpAndFetchData();
      _preloadImageAsync();
    });

    // Optimización: Reducir frecuencia del timer de 10s a 15s para mejor rendimiento
    _dataTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (!_isDisposed && mounted) {
        _fetchSensorDataWithDebounce();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _dataTimer?.cancel();
    super.dispose();
  }

  // Optimización: Precarga de imagen asíncrona para no bloquear la UI inicial
  Future<void> _preloadImageAsync() async {
    if (_isDisposed) return;

    try {
      await precacheImage(
        const AssetImage('assets/images/img_main_menu_screen.jpg'),
        context,
      );
      if (!_isDisposed && mounted) {
        setState(() {
          _imageExists = true;
          _imageLoaded = true;
        });
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        setState(() {
          _imageExists = false;
          _imageLoaded = true;
        });
      }
    }
  }

  // Optimización: Debouncing para evitar múltiples llamadas simultáneas
  Future<void> _fetchSensorDataWithDebounce() async {
    if (_isDataFetching || _isDisposed) return;
    _isDataFetching = true;

    try {
      await _fetchSensorData();
    } finally {
      _isDataFetching = false;
    }
  }

  Future<void> _loadIpAndFetchData() async {
    if (_isDisposed) return;

    final prefs = await SharedPreferences.getInstance();
    _esp32Ip = prefs.getString("esp32_ip") ?? "";
    await _fetchSensorDataWithDebounce();
  }

  Future<void> _fetchSensorData() async {
    if (_isDisposed || !mounted) return;

    if (_esp32Ip.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _sensorData = {};
        });
      }
      return;
    }

    try {
      // Optimización: Timeout reducido de 5s a 3s para respuesta más rápida
      final response = await http
          .get(
            Uri.parse('http://$_esp32Ip/sensors'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 3));

      if (!_isDisposed && mounted) {
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
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        setState(() {
          _sensorData = {};
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        255,
        255,
        255,
      ), // Verde muy claro de fondo
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen decorativa que cubre todo el header
          _buildHeaderImage(),

          // Contenido con padding en un Expanded para ocupar el resto del espacio
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Módulo introductorio
                    _buildIntroductoryModule(),

                    const SizedBox(height: 20),

                    // Accesos Rápidos
                    _buildQuickAccess(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: 0),
    );
  }

  Widget _buildIntroductoryModule() {
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
                const Icon(Icons.school, color: Color(0xFF498428), size: 24),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Guía',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Aquí se puede agregar la navegación al módulo introductorio
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Módulo introductorio próximamente'),
                      backgroundColor: Color(0xFF498428),
                    ),
                  );
                },
                icon: const Icon(Icons.play_circle_outline),
                label: const Text(
                  'Módulo introductorio',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF498428),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccess() {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardPadding = (screenWidth * 0.04).clamp(16.0, 20.0);
    double buttonSpacing = (screenWidth * 0.015).clamp(10.0, 12.0);
    
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF98C98D).withOpacity(0.4), // Efecto glass
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFCEE2BE).withOpacity(0.6),
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.flash_on,
                    color: Color(0xFF00444D), // Color principal de la paleta
                    size: 24,
                  ),
                  SizedBox(width: buttonSpacing * 0.8),
                  const Text(
                    'Accesos Rápidos',
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00444D), // Color principal de la paleta
                    ),
                  ),
                ],
              ),
              SizedBox(height: cardPadding * 0.8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    flex: 1,
                    child: _buildQuickAccessButton(
                      'Sensores',
                      Icons.dashboard,
                      const Color(0xFF63B069), // Verde medio de la paleta
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SensorDashboardScreen(ip: _esp32Ip),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: buttonSpacing),
                  Flexible(
                    flex: 1,
                    child: _buildQuickAccessButton(
                      'Galería',
                      Icons.photo_library,
                      const Color(0xFF247E5A), // Verde oscuro de la paleta
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
      ),
    );
  }

  Widget _buildQuickAccessButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
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

  Widget _buildHeaderImage() {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width: double.infinity,
      height: screenHeight * 0.35, // 35% de la altura de la pantalla
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        child: _buildImageContent(),
      ),
    );
  }

  Widget _buildImageContent() {
    // Si la imagen no ha terminado de cargar, muestra el fondo por defecto
    if (!_imageLoaded) {
      return _buildDefaultBackground();
    }

    // Si la imagen existe y está cargada, la muestra
    if (_imageExists) {
      return Image.asset(
        'assets/images/img_main_menu_screen.jpg',
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultBackground();
        },
      );
    } else {
      // Si no existe la imagen, usa el fondo por defecto
      return _buildDefaultBackground();
    }
  }

  Widget _buildDefaultBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/img_main_menu_screen.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
