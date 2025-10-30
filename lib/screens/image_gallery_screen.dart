import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'image_detail_screen.dart';
import '../models/image_data.dart';
import '../widgets/bottom_navigation_widget.dart';

class ImageGalleryScreen extends StatefulWidget {
  const ImageGalleryScreen({super.key});

  @override
  State<ImageGalleryScreen> createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  List<ImageData> images = [];
  bool isLoading = false;
  bool isCapturing = false;
  String? esp32Ip;

  @override
  void initState() {
    super.initState();
    _loadEsp32Ip();
    _loadImages();
  }

  Future<void> _loadEsp32Ip() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      esp32Ip = prefs.getString('esp32_ip');
    });
  }

  Future<void> _loadImages() async {
    setState(() {
      isLoading = true;
    });

    // Simulación de carga de imágenes (aquí iría la lógica real)
    await Future.delayed(const Duration(seconds: 1));
    
    // Imágenes de ejemplo
    setState(() {
      images = [
        ImageData(
          id: '1',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          size: '1.2 MB',
        ),
        ImageData(
          id: '2',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          size: '980 KB',
        ),
        ImageData(
          id: '3',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          size: '1.5 MB',
        ),
      ];
      isLoading = false;
    });
  }

  Future<void> _captureImage() async {
    if (esp32Ip == null) {
      _showSnackBar('Error: IP del ESP32 no configurada', Colors.red);
      return;
    }

    setState(() {
      isCapturing = true;
    });

    try {
      // Simulación de captura (aquí iría la llamada HTTP real al ESP32)
      await Future.delayed(const Duration(seconds: 2));
      
      // Agregar nueva imagen a la lista
      final newImage = ImageData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        size: '1.1 MB',
      );
      
      setState(() {
        images.insert(0, newImage);
        isCapturing = false;
      });
      
      _showSnackBar('Imagen capturada exitosamente', Colors.green);
    } catch (e) {
      setState(() {
        isCapturing = false;
      });
      _showSnackBar('Error al capturar imagen: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Galería de Imágenes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF498428), // Verde oscuro para el texto
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF498428)), // Verde oscuro para el ícono
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF498428)), // Verde oscuro
            onPressed: _loadImages,
          ),
        ],
      ),
      body: Column(
        children: [
          // Estado de conexión y estadísticas
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total de imágenes',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '${images.length}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: esp32Ip != null ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: esp32Ip != null ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        esp32Ip != null ? 'Conectado' : 'Desconectado',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: esp32Ip != null ? Colors.green.shade700 : Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Grid de imágenes
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.purple,
                    ),
                  )
                : images.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_library_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay imágenes',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Captura tu primera imagen',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            final image = images[index];
                            return _buildImageCard(image);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isCapturing ? null : _captureImage,
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        icon: isCapturing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.camera_alt),
        label: Text(isCapturing ? 'Capturando...' : 'Capturar'),
      ),
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: 0), // Índice 0 para "Home"
    );
  }

  Widget _buildImageCard(ImageData image) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageDetailScreen(image: image),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen placeholder
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Icon(
                  Icons.image,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
            
            // Información de la imagen
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDateTime(image.timestamp),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      image.size,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Ahora';
    }
  }
}