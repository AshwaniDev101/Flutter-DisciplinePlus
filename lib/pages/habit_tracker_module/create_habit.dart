
import 'package:flutter/material.dart';
import 'habit_model.dart';
import 'shared_preferences_manager.dart';

class CreateHabitPage extends StatefulWidget {
  const CreateHabitPage({super.key});

  @override
  _CreateHabitPageState createState() => _CreateHabitPageState();
}

class _CreateHabitPageState extends State<CreateHabitPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.star;

  final List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
  ];

  final List<IconData> _icons = [
    Icons.star,
    Icons.favorite,
    Icons.work,
    Icons.fitness_center,
    Icons.book,
    Icons.music_note,
  ];

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newHabit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _title,
        color: _selectedColor,
        icon: _selectedIcon,
      );
      await SharedPreferencesManager.addHabit(newHabit);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Habit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _submit,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Habit Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              const SizedBox(height: 20),
              const Text('Color'),
              Wrap(
                spacing: 10,
                children: _colors
                    .map((color) => ChoiceChip(
                          label: CircleAvatar(backgroundColor: color),
                          selected: _selectedColor == color,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedColor = color;
                              });
                            }
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
              const Text('Icon'),
              Wrap(
                spacing: 10,
                children: _icons
                    .map((icon) => ChoiceChip(
                          label: Icon(icon),
                          selected: _selectedIcon == icon,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedIcon = icon;
                              });
                            }
                          },
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
