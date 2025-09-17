import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/console.dart';

class ConsolesScreen extends StatefulWidget {
  const ConsolesScreen({super.key});

  @override
  State<ConsolesScreen> createState() => _ConsolesScreenState();
}

class _ConsolesScreenState extends State<ConsolesScreen> {
  final _uuid = const Uuid();
  final String _storageKey = 'gc_v14_consoles';
  List<GameConsole> _consoles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadConsoles();
  }

  Future<void> _loadConsoles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final list = (jsonDecode(raw) as List)
          .map((e) => GameConsole.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        _consoles = list;
      });
    }
    setState(() => _loading = false);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _storageKey, jsonEncode(_consoles.map((e) => e.toJson()).toList()));
  }

  Future<void> _addConsole() async {
    final name = await _promptName(context, title: 'Añadir consola');
    if (name == null || name.trim().isEmpty) return;
    setState(() {
      _consoles.add(GameConsole(id: _uuid.v4(), name: name.trim()));
    });
    _persist();
  }

  Future<void> _editConsole(GameConsole c) async {
    final name =
        await _promptName(context, title: 'Renombrar consola', initial: c.name);
    if (name == null || name.trim().isEmpty) return;
    setState(() {
      c.name = name.trim();
    });
    _persist();
  }

  Future<void> _deleteConsole(GameConsole c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar consola'),
        content: Text('¿Eliminar "${c.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() {
      _consoles.removeWhere((x) => x.id == c.id);
    });
    _persist();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('GameControl • V.14'),
      ),
      body: _consoles.isEmpty
          ? const Center(
              child: Text('Todavía no hay consolas.\nPulsa + para añadir.',
                  textAlign: TextAlign.center),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _consoles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final c = _consoles[i];
                return Card(
                  child: ListTile(
                    title: Text(c.name),
                    subtitle: Text('ID: ${c.id.substring(0, 8)}…'),
                    onTap: () => _editConsole(c),
                    onLongPress: () => _deleteConsole(c),
                    trailing: const Icon(Icons.edit),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addConsole,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<String?> _promptName(BuildContext context,
      {required String title, String? initial}) async {
    final controller = TextEditingController(text: initial ?? '');
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nombre',
            hintText: 'Ej. PS5, Xbox Series X…',
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Guardar')),
        ],
      ),
    );
  }
}
