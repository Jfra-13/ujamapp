import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'models/participant.dart';

void main() {
  runApp(const UJamApp());
}

class UJamApp extends StatelessWidget {
  const UJamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'uJam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Participant> integrantes = [
      Participant(id: '1', name: 'Juanfra23', status: PaymentStatus.verde), // Tú como Admin
      Participant(id: '2', name: 'Amigo 2', status: PaymentStatus.naranja),
      Participant(id: '3', name: 'Amigo 3', status: PaymentStatus.gris),
      Participant(id: '4', name: 'Amigo 4', status: PaymentStatus.gris),
      Participant(id: '5', name: 'Joaquinllj', status: PaymentStatus.verde),
      Participant(id: '6', name: 'Amigo 6', status: PaymentStatus.gris),
      Participant(id: '7', name: 'MariaKamila16', status: PaymentStatus.verde),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('uJam - Dia de Playa'),
        backgroundColor: Colors.orange.shade100,
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Icon(Icons.inventory_2, size: 80, color: Colors.orangeAccent),
          const Text(
            "Estado del Jam",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: integrantes.length,
              itemBuilder: (context, index) {
                final persona = integrantes[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getColor(persona.status),
                    child: Text(persona.name[0]),
                  ),
                  title: Text(persona.name),
                  subtitle: Text(_getStatusText(persona.status)),
                  trailing: const Icon(Icons.chevron_right),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Lógica para los colores de estado de uJam
  Color _getColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.verde: return Colors.green;
      case PaymentStatus.naranja: return Colors.orange;
      case PaymentStatus.gris: return Colors.grey;
    }
  }

  String _getStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.verde: return "Pago Verificado";
      case PaymentStatus.naranja: return "Esperando Validación";
      case PaymentStatus.gris: return "Pendiente";
    }
  }
}