import 'package:flutter/material.dart';
import '../../models/diet_food.dart';
import '../../models/food_stats.dart';
import '../../core/utils/helper.dart';

class AddEditDietFoodDialog {
  /// Opens the Add/Edit DietFood Dialog
  static void show(
      BuildContext context, {
        DietFood? food,
        required Function(DietFood dietFood) onAdd,
      }) {
    final formKey = GlobalKey<FormState>();

    // Pre-fill values if editing
    String name = food?.name ?? '';
    String calories = food?.foodStats.calories.toString() ?? '';
    String proteins = food?.foodStats.proteins.toString() ?? '';
    String carbohydrates = food?.foodStats.carbohydrates.toString() ?? '';
    String fats = food?.foodStats.fats.toString() ?? '';
    String vitamins = food?.foodStats.vitamins.toString() ?? '';
    String minerals = food?.foodStats.minerals.toString() ?? '';

    InputDecoration buildInputDecoration(String label) {
      return InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        floatingLabelStyle: const TextStyle(
          color: Colors.pink,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: Colors.grey[100],
        isDense: true,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      );
    }

    Widget buildNumberField({
      required String label,
      required String initialValue,
      required Function(String) onSaved,
    }) {
      return Expanded(
        child: TextFormField(
          initialValue: initialValue,
          decoration: buildInputDecoration(label),
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 14),
          onSaved: (v) => onSaved(v ?? '0'),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Center(
          child: Text(
            food == null ? 'Add New Diet Food' : 'Edit Diet Food',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.pink,
            ),
          ),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- Food Name ---
                TextFormField(
                  initialValue: name,
                  decoration: buildInputDecoration('Food Name'),
                  style: const TextStyle(fontSize: 14),
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
                  onSaved: (v) => name = v!.trim(),
                ),
                const SizedBox(height: 12),

                // --- Calories ---
                TextFormField(
                  initialValue: calories,
                  decoration: buildInputDecoration('Calories'),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 14),
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
                  onSaved: (v) => calories = v!.trim(),
                ),
                const SizedBox(height: 12),

                // --- Row 1: Proteins, Vitamins, Fats ---
                Row(
                  children: [
                    buildNumberField(
                      label: 'Proteins',
                      initialValue: proteins,
                      onSaved: (v) => proteins = v,
                    ),
                    const SizedBox(width: 12),
                    buildNumberField(
                      label: 'Vitamins',
                      initialValue: vitamins,
                      onSaved: (v) => vitamins = v,
                    ),
                    const SizedBox(width: 12),
                    buildNumberField(
                      label: 'Fats',
                      initialValue: fats,
                      onSaved: (v) => fats = v,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // --- Row 2: Carbs, Minerals ---
                Row(
                  children: [
                    buildNumberField(
                      label: 'Carbohydrates',
                      initialValue: carbohydrates,
                      onSaved: (v) => carbohydrates = v,
                    ),
                    const SizedBox(width: 12),
                    buildNumberField(
                      label: 'Minerals',
                      initialValue: minerals,
                      onSaved: (v) => minerals = v,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'CANCEL',
              style: TextStyle(fontSize: 13, color: Colors.pink[300]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();

                final updatedDietFood = DietFood(
                  id: food?.id ?? generateReadableTimestamp(),
                  name: name,
                  count: 0,
                  time: DateTime.now(),
                  foodStats: FoodStats(
                    proteins: int.tryParse(proteins) ?? 0,
                    carbohydrates: int.tryParse(carbohydrates) ?? 0,
                    fats: int.tryParse(fats) ?? 0,
                    vitamins: int.tryParse(vitamins) ?? 0,
                    minerals: int.tryParse(minerals) ?? 0,
                    calories: int.tryParse(calories) ?? 0,
                  ),
                );

                onAdd(updatedDietFood);
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink[300],
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
            child: Text(
              food == null ? 'ADD' : 'SAVE',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
