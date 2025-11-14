use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct IngredientQuantity {
    pub name: String,
    pub amount: f32,
    pub unit: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MealAnalysis {
    pub dish: String,
    pub quantity: String,
    pub ingredients: Vec<String>,
    pub ingredient_quantities: Vec<IngredientQuantity>,
}

