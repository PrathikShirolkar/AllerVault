import 'engine_api.dart';

class EngineApiImpl {
  Future<MealAnalysis> processMealPhoto(String imagePath) async {
    // Web stub to keep browser testing simple.
    await Future.delayed(const Duration(milliseconds: 300));
    return const MealAnalysis(
      dish: 'Sample Dish',
      quantity: '1 plate (approx 300 g)',
      ingredients: ['ingredient_a', 'ingredient_b', 'ingredient_c'],
      ingredientQuantities: [
        IngredientQuantity(name: 'ingredient_a', amount: 150, unit: 'g'),
        IngredientQuantity(name: 'ingredient_b', amount: 100, unit: 'g'),
        IngredientQuantity(name: 'ingredient_c', amount: 50, unit: 'g'),
      ],
    );
  }
}

