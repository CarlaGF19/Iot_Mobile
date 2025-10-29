import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class SensorDetailPage extends StatefulWidget {
  final String esp32Ip;
  final String tipo;
  final String titulo;

  const SensorDetailPage({
    super.key,
    required this.esp32Ip,
    required this.tipo,
    required this.titulo,
  });

  @override
  State<SensorDetailPage> createState() => _SensorDetailPageState();
}

class _SensorDetailPageState extends State<SensorDetailPage> {
  List<double> valores = [];
  double valorActual = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _leerSensor();
    timer = Timer.periodic(const Duration(seconds: 5), (_) => _leerSensor());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _leerSensor() async {
    try {
      final response = await http.get(Uri.parse("${widget.esp32Ip}/${widget.tipo}"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        double valor = 0;

        switch (widget.tipo) {
          case "temperatura":
            valor = (data["temperatura"] ?? 0).toDouble();
            break;
          case "humedad":
            valor = (data["humedad"] ?? 0).toDouble();
            break;
          case "ph":
            valor = (data["ph"] ?? 0).toDouble();
            break;
          case "tds":
            valor = (data["tds"] ?? 0).toDouble();
            break;
        }

        setState(() {
          valorActual = valor;
          valores.add(valor);
          if (valores.length > 15) valores.removeAt(0);
        });
      }
    } catch (e) {
      debugPrint("Error de conexión: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.titulo)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Valor actual: ${valorActual.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: valores.isEmpty
                  ? const Center(child: Text("Sin datos aún..."))
                  : LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles:
                                SideTitles(showTitles: true, reservedSize: 35),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            color: Colors.green,
                            barWidth: 3,
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.green.withOpacity(0.2),
                            ),
                            dotData: const FlDotData(show: true),
                            spots: [
                              for (int i = 0; i < valores.length; i++)
                                FlSpot(i.toDouble(), valores[i]),
                            ],
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
}
