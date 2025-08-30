import 'dart:math';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

void main() {
  runApp(EarthCurvatureApp());
}

class EarthCurvatureApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Curvatura de la Tierra',
      theme: ThemeData.dark(),
      home: EarthCurvatureScreen(),
    );
  }
}

class EarthCurvatureScreen extends StatefulWidget {
  @override
  _EarthCurvatureScreenState createState() => _EarthCurvatureScreenState();
}

class _EarthCurvatureScreenState extends State<EarthCurvatureScreen> {
  final TextEditingController _distController = TextEditingController(text: "100");
  final TextEditingController _heightController = TextEditingController(text: "2");

  String _result = "";

  static const double R_KM = 6371.0;

  double curvatureDropAtArcDistance(double sKm) {
    double theta = sKm / R_KM;
    double dropKm = R_KM * (1 - cos(theta));
    return dropKm * 1000.0;
  }

  double horizonArcDistanceForHeight(double hM) {
    double hKm = hM / 1000.0;
    double val = R_KM / (R_KM + hKm);
    val = val > 1.0 ? 1.0 : val;
    double theta = acos(val);
    return R_KM * theta;
  }

  double lineOfSightDistanceForHeight(double hM) {
    double hKm = hM / 1000.0;
    return sqrt(pow(R_KM + hKm, 2) - pow(R_KM, 2));
  }

  void _calculate() {
    try {
      double dist = double.parse(_distController.text);
      double h = double.parse(_heightController.text);

      double dropM = curvatureDropAtArcDistance(dist);
      double horizonKm = horizonArcDistanceForHeight(h);
      double losKm = lineOfSightDistanceForHeight(h);
      bool visible = dist <= horizonKm;

      setState(() {
        _result = """
Distancia de observación: ${dist.toStringAsFixed(2)} km
Altura del observador: ${h.toStringAsFixed(2)} m
Descenso por curvatura: ${dropM.toStringAsFixed(2)} m
Distancia al horizonte: ${horizonKm.toStringAsFixed(2)} km
Distancia línea de visión: ${losKm.toStringAsFixed(2)} km
¿Es visible el punto?: ${visible ? "Sí" : "No"}
""";
      });
    } catch (e) {
      setState(() {
        _result = "Error en la entrada de datos";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Curvatura de la Tierra - 3D")),
      body: Column(
        children: [
          // Modelo 3D de la Tierra
          Expanded(
            flex: 3,
            child: ModelViewer(
              src: "https://modelviewer.dev/shared-assets/models/earth.glb",
              alt: "Tierra 3D",
              ar: false,
              autoRotate: true,
              cameraControls: true,
              disableZoom: false,
            ),
          ),
          // Inputs y resultados
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _distController,
                          decoration: InputDecoration(
                            labelText: "Distancia (km)",
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _heightController,
                          decoration: InputDecoration(
                            labelText: "Altura (m)",
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _calculate,
                    child: Text("Calcular"),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _result,
                        style: TextStyle(fontSize: 16, fontFamily: "monospace"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
