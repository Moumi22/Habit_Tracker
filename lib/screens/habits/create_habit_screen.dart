import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/habit_provider.dart';
import '../../models/habit_model.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class CreateHabitScreen extends StatefulWidget {
  const CreateHabitScreen({super.key});

  @override
  State<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  HabitCategory _selectedCategory = HabitCategory.health;
  HabitFrequency _selectedFrequency = HabitFrequency.daily;
  DateTime? _selectedStartDate;
  bool _hasStartDate = false;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedStartDate) {
      setState(() {
        _selectedStartDate = picked;
        _hasStartDate = true;
      });
    }
  }

  Future<void> _createHabit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);

    if (authProvider.currentUser == null) return;

    final success = await habitProvider.createHabit(
      userId: authProvider.currentUser!.uid,
      title: _titleController.text.trim(),
      category: _selectedCategory,
      frequency: _selectedFrequency,
      startDate: _hasStartDate ? _selectedStartDate : null,
      notes:
          _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Habit created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(habitProvider.error ?? '❌ Failed to create habit'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create New Habit',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CustomTextField(
                    controller: _titleController,
                    labelText: 'Habit Title *',
                    hintText: 'e.g., Drink 8 glasses of water',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Habit title is required';
                      }
                      if (value.trim().length < 3) {
                        return 'Habit title must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Category Selection
              Text(
                'Category',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children:
                    HabitCategory.values.map((category) {
                      final isSelected = _selectedCategory == category;
                      return ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(category.icon),
                            const SizedBox(width: 6),
                            Text(category.displayName),
                          ],
                        ),
                        selected: isSelected,
                        selectedColor: _getCategoryColor(category),
                        backgroundColor: _getCategoryColor(
                          category,
                        ).withOpacity(0.15),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (_) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      );
                    }).toList(),
              ),

              const SizedBox(height: 20),

              // Frequency Selection
              Text(
                'Frequency',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ToggleButtons(
                borderRadius: BorderRadius.circular(12),
                isSelected:
                    HabitFrequency.values
                        .map((f) => f == _selectedFrequency)
                        .toList(),
                onPressed: (index) {
                  setState(() {
                    _selectedFrequency = HabitFrequency.values[index];
                  });
                },
                children:
                    HabitFrequency.values.map((frequency) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Text(
                          frequency.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
              ),

              const SizedBox(height: 20),

              // Start Date
              SwitchListTile(
                title: const Text('Set Start Date'),
                value: _hasStartDate,
                onChanged: (value) {
                  setState(() {
                    _hasStartDate = value;
                    if (!_hasStartDate) _selectedStartDate = null;
                  });
                },
              ),
              if (_hasStartDate)
                InkWell(
                  onTap: _selectStartDate,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 12),
                          Text(
                            _selectedStartDate != null
                                ? '${_selectedStartDate!.day}/${_selectedStartDate!.month}/${_selectedStartDate!.year}'
                                : 'Pick a date',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Notes Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CustomTextField(
                    controller: _notesController,
                    labelText: 'Notes (Optional)',
                    hintText: 'Add any details about your habit...',
                    maxLines: 3,
                    prefixIcon: Icons.note_outlined,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Submit Button
              CustomButton(
                onPressed: habitProvider.isLoading ? null : _createHabit,
                text: habitProvider.isLoading ? 'Creating...' : 'Create Habit',
                isLoading: habitProvider.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(HabitCategory category) {
    switch (category) {
      case HabitCategory.health:
        return Colors.green;
      case HabitCategory.study:
        return Colors.blue;
      case HabitCategory.fitness:
        return Colors.orange;
      case HabitCategory.productivity:
        return Colors.purple;
      case HabitCategory.mentalHealth:
        return Colors.teal;
      case HabitCategory.others:
        return Colors.grey;
    }
  }
}
