import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ====== MODELOS ======
class Movimiento {
  final String id;
  final DateTime fecha;
  final String descripcion;
  final double monto;
  final bool esIngreso; // true = ingreso, false = gasto

  Movimiento({
    required this.id,
    required this.fecha,
    required this.descripcion,
    required this.monto,
    required this.esIngreso,
  });
}

// ====== PROVIDER ======
class AppState with ChangeNotifier {
  final List<Movimiento> _movimientos = [];
  double _saldo = 0;

  List<Movimiento> get movimientos => List.unmodifiable(_movimientos);
  double get saldo => _saldo;

  void agregarMovimiento(Movimiento m) {
    _movimientos.insert(0, m);
    _saldo += m.esIngreso ? m.monto : -m.monto;
    notifyListeners();
  }
}

// ====== APP ======
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VNNOApp());
}

class VNNOApp extends StatelessWidget {
  const VNNOApp({super.key});

  @override
  Widget build(BuildContext context) {
    final negro = const Color(0xFF0A0A0A);
    final dorado = const Color(0xFFFFA000); // dorado cálido

    final tema = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: dorado,
        primary: dorado,
        secondary: dorado,
        surface: Colors.white,
        background: const Color(0xFFF7F5F2),
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: negro,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: negro,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: dorado,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: dorado,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
     cardTheme: const CardThemeData(
  elevation: 0,
  color: Colors.white,
  surfaceTintColor: Colors.white,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(18)),
  ),
),

    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'VNNO by JPR',
        theme: tema,
        home: const ShellVNNO(),
      ),
    );
  }
}

// ====== SHELL CON BOTTOM NAV ======
class ShellVNNO extends StatefulWidget {
  const ShellVNNO({super.key});
  @override
  State<ShellVNNO> createState() => _ShellVNNOState();
}

class _ShellVNNOState extends State<ShellVNNO> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final paginas = [
      const ResumenScreen(),
      const MovimientosScreen(esIngreso: true),
      const MovimientosScreen(esIngreso: false),
      const UtilidadesScreen(),
    ];

    final titulos = ['Resumen', 'Ingresos', 'Gastos', 'Más'];

    return Scaffold(
      appBar: AppBar(title: Text(titulos[_index])),
      body: paginas[_index],
      floatingActionButton: _index == 1 || _index == 2
          ? FloatingActionButton(
              onPressed: () => _mostrarFormularioMovimiento(
                context,
                esIngreso: _index == 1,
              ),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Resumen'),
          NavigationDestination(icon: Icon(Icons.trending_up), label: 'Ingresos'),
          NavigationDestination(icon: Icon(Icons.trending_down), label: 'Gastos'),
          NavigationDestination(icon: Icon(Icons.widgets_outlined), label: 'Más'),
        ],
      ),
    );
  }

  void _mostrarFormularioMovimiento(BuildContext context, {required bool esIngreso}) {
    final descCtrl = TextEditingController();
    final montoCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Text(
                esIngreso ? 'Nuevo Ingreso' : 'Nuevo Gasto',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: montoCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final monto = double.tryParse(montoCtrl.text.replaceAll(',', '.')) ?? 0;
                        if (monto <= 0 || descCtrl.text.trim().isEmpty) return;
                        final m = Movimiento(
                          id: DateTime.now().microsecondsSinceEpoch.toString(),
                          fecha: DateTime.now(),
                          descripcion: descCtrl.text.trim(),
                          monto: monto,
                          esIngreso: esIngreso,
                        );
                        context.read<AppState>().agregarMovimiento(m);
                        Navigator.pop(context);
                      },
                      child: const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ====== PANTALLAS ======
class ResumenScreen extends StatelessWidget {
  const ResumenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final saldo = context.watch<AppState>().saldo;
    final movimientos = context.watch<AppState>().movimientos;
    final ingresos = movimientos.where((m) => m.esIngreso).fold<double>(0, (a, b) => a + b.monto);
    final gastos = movimientos.where((m) => !m.esIngreso).fold<double>(0, (a, b) => a + b.monto);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Tarjeta de saldo
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Saldo actual', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text('\$ ${saldo.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniStat(title: 'Ingresos', value: ingresos),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MiniStat(title: 'Gastos', value: gastos, negativo: true),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Últimos movimientos
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Últimos movimientos',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 8),
          for (final m in movimientos.take(6))
            ListTile(
              leading: CircleAvatar(
                child: Icon(m.esIngreso ? Icons.trending_up : Icons.trending_down),
              ),
              title: Text(m.descripcion),
              subtitle: Text('${m.fecha.day}/${m.fecha.month}/${m.fecha.year}'),
              trailing: Text(
                (m.esIngreso ? '+ ' : '- ') + '\$${m.monto.toStringAsFixed(2)}',
                style: TextStyle(
                  color: m.esIngreso ? Colors.green[700] : Colors.red[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String title;
  final double value;
  final bool negativo;
  const _MiniStat({required this.title, required this.value, this.negativo = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: negativo ? Colors.red[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            (negativo ? '- ' : '+ ') + '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: negativo ? Colors.red[700] : Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }
}

class MovimientosScreen extends StatelessWidget {
  final bool esIngreso;
  const MovimientosScreen({super.key, required this.esIngreso});

  @override
  Widget build(BuildContext context) {
    final items = context.watch<AppState>().movimientos.where((m) => m.esIngreso == esIngreso).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final m = items[i];
        return Card(
          child: ListTile(
            leading: CircleAvatar(child: Icon(esIngreso ? Icons.trending_up : Icons.trending_down)),
            title: Text(m.descripcion),
            subtitle: Text('${m.fecha.day}/${m.fecha.month}/${m.fecha.year}'),
            trailing: Text(
              (esIngreso ? '+ ' : '- ') + '\$${m.monto.toStringAsFixed(2)}',
              style: TextStyle(
                color: esIngreso ? Colors.green[700] : Colors.red[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }
}

class UtilidadesScreen extends StatelessWidget {
  const UtilidadesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.flag_outlined),
            title: const Text('Metas de ahorro (próximo paso)'),
            subtitle: const Text('Crea metas y seguimiento mensual.'),
            trailing: ElevatedButton(
              onPressed: () {},
              child: const Text('Pronto'),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Recordatorios de pagos'),
            subtitle: const Text('Envío 2 días antes del vencimiento.'),
            trailing: ElevatedButton(
              onPressed: () {},
              child: const Text('Pronto'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Versión gratuita con funciones limitadas.\nPremium: \$1.99/mes con IA para planes personalizados.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
