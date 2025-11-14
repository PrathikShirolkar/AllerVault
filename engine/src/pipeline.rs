use crate::types::{IngredientQuantity, MealAnalysis};

pub fn run_pipeline(_image_path: &str) -> MealAnalysis {
    // Placeholder pipeline result; replace with real LLM/vision steps later.
    MealAnalysis {
        dish: "sample dish".to_string(),
        quantity: "1 plate (approx 300 g)".to_string(),
        ingredients: vec![
            "ingredient_a".to_string(),
            "ingredient_b".to_string(),
            "ingredient_c".to_string(),
        ],
        ingredient_quantities: vec![
            IngredientQuantity { name: "ingredient_a".to_string(), amount: 150.0, unit: "g".to_string() },
            IngredientQuantity { name: "ingredient_b".to_string(), amount: 100.0, unit: "g".to_string() },
            IngredientQuantity { name: "ingredient_c".to_string(), amount: 50.0, unit: "g".to_string() },
        ],
    }
}

