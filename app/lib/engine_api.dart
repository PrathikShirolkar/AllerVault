import 'engine_api_impl_mobile.dart' if (dart.library.html) 'engine_api_impl_web.dart' as impl;

class MealAnalysis {
  final String dish;
  final String quantity;
  final List<String> ingredients;
  final List<IngredientQuantity> ingredientQuantities;

  const MealAnalysis({
    required this.dish,
    required this.quantity,
    required this.ingredients,
    required this.ingredientQuantities,
  });
}

class IngredientQuantity {
  final String name;
  final double amount;
  final String unit;

  const IngredientQuantity({
    required this.name,
    required this.amount,
    required this.unit,
  });
}

class EngineApi {
  Future<MealAnalysis> processMealPhoto(String imagePath) {
    return impl.EngineApiImpl().processMealPhoto(imagePath);
  }
}
