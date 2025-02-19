//
//  IngredientStore.swift
//  BarcodeTextScanner
//
//  Created by Mustafa Yusuf on 18/02/25.
//

import Foundation

enum IngredientType: String, Codable {
    case vegan
    case vegetarian
    case animal
    case both
    case eggetarian
    case pescatarian
}

struct Ingredient: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let nameScientific: String?
    let description: String?
    let itisId: String?
    let wikipediaId: String?
    let foodGroup: String?
    let foodSubgroup: String?
    let foodType: String
    let category: String?
    let ncbiTaxonomyId: Int?
    let publicId: String
    var ingredientType: IngredientType?
}

class IngredientStore {
    
    static let shared: IngredientStore = .init()
    private var map: [String: Int] = [:]
    private var ingredients: [Ingredient] = []
    private let knownIngredients: [String: IngredientType] = [
        "acesulfame_k": .vegan,
        "acetate": .both,
        "actinidin": .vegan,
        "adrenaline": .animal,
        "agar_agar": .vegan,
        "albumen": .both,
        "allantoin": .both,
        "allura_red": .both,
        "aloe_vera": .vegan,
        "alpha_hydroxy_acids": .both,
        "aluminum_hydroxide": .vegan,
        "aluminum_sulfate": .vegan,
        "ambergris": .animal,
        "amino_acids": .both,
        "amniotic_fluid": .animal,
        "amylase": .both,
        "anchovy": .animal,
        "angora": .animal,
        "annatto": .vegan,
        "anthocyanins": .vegan,
        "arachidonic_acid": .animal,
        "artificial": .both,
        "ascorbic_acid": .vegan,
        "aspartame": .vegan,
        "aspartic_acid": .both,
        "aspic": .animal,
        "astrakhan": .animal,
        "bakers_yeast": .vegan,
        "bauxite": .vegan,
        "bee_pollen": .animal,
        "beeswax": .both,
        "beet_sugar": .vegan,
        "benzoic_acid": .vegan,
        "beta_carotene": .vegan,
        "betatene": .vegan,
        "biotin": .both,
        "bone": .animal,
        "bonito": .animal,
        "brawn": .animal,
        "brewers_yeast": .vegan,
        "brilliant_blue_fcf": .both,
        "bristle": .animal,
        "bromelain": .vegan,
        "butane": .vegan,
        "calcium_carbonate": .both,
        "calcium_chloride": .vegan,
        "calcium_disodium_edta": .vegan,
        "calcium_hydroxide": .both,
        "calcium_lactate": .both,
        "calcium_phosphate": .both,
        "calcium_propionate": .vegan,
        "calcium_stearate": .both,
        "calcium_stearoyl_2_lactylate": .both,
        "candelilla_wax": .vegan,
        "cane_sugar": .both,
        "capiz": .animal,
        "caramel": .both,
        "carbamide": .both,
        "carbon_black": .both,
        "carbonic_acid": .vegan,
        "carnauba_wax": .vegan,
        "carotene": .vegan,
        "cashmere": .animal,
        "castor": .animal,
        "castor_oil": .vegan,
        "catalase": .both,
        "catgut": .animal,
        "caviar": .animal,
        "cellulose": .vegan,
        "cetyl_alcohol": .both,
        "cetyl_palmitate": .both,
        "chalk": .both,
        "charcoal": .both,
        "chitin": .animal,
        "chamois": .animal,
        "cholecalciferol": .both,
        "cholesterol": .animal,
        "chondroitin": .both,
        "chymosin": .both,
        "chymotrypsin": .animal,
        "cinnamic_acid": .vegan,
        "citric_acid": .vegan,
        "civet": .both,
        "coal_tar": .vegan,
        "cochineal": .animal,
        "cod_liver_oil": .animal,
        "colflo_67": .vegan,
        "collagen": .animal,
        "collagen_hydrolysate": .animal,
        "colors_dyes": .both,
        "confectioners_glaze": .animal,
        "coral": .animal,
        "cornstarch": .vegan,
        "corn_syrup": .vegan,
        "corticosteroid": .both,
        "cottonseed_oil": .vegan,
        "crospovidone": .vegan,
        "curcumin": .vegan,
        "cysteine": .both,
        "cystine": .both,
        "dashi": .both,
        "dc_colors": .both,
        "dextrin": .vegan,
        "dicalcium_phosphate": .both,
        "dihydroxyacetone": .both,
        "direct_reduced_iron": .vegan,
        "disodium_inosinate": .both,
        "down": .animal,
        "duodenum_substances": .animal,
        "elastin": .animal,
        "emu_oil": .animal,
        "enzymes": .both,
        "ergocalciferol": .both,
        "erythorbic_acid": .vegan,
        "estrogen": .animal,
        "fatty_acids": .both,
        "fdc_colors": .both,
        "fdc_blue_1": .both,
        "fdc_red_40": .both,
        "fdc_yellow_5": .both,
        "fdc_yellow_6": .both,
        "feathers": .animal,
        "felt": .both,
        "ferrous_lactate": .both,
        "ferrous_sulfate": .vegan,
        "ficin": .vegan,
        "folate": .both,
        "folic_acid": .vegan,
        "fructose_syrup": .vegan,
        "glucono_delta_lactone": .both,
        "gluconolactone": .both,
        "glucose": .both,
        "glucose_isomerate": .vegan,
        "glucosamine": .both,
        "glycerin": .both,
        "glycine": .both,
        "guanine": .animal,
        "guar_gum": .vegan,
        "gum_arabic": .vegan,
        "hide": .animal,
        "high_fructose_corn_syrup": .vegan,
        "honey": .animal,
        "hydrochloric_acid": .vegan,
        "hydroxypropyl_cellulose": .vegan,
        "hydroxypropyl_methylcelluose": .vegan,
        "inositol": .both,
        "insulin": .both,
        "inulin": .vegan,
        "katsuobushi": .animal,
        "keratin": .animal,
        "l_cysteine": .both,
        "l_cysteine_hydrochloride": .both,
        "lactic_acid": .both,
        "lactase": .vegan,
        "lactoflavin": .both,
        "lanolin": .animal,
        "laurel": .vegan,
        "lauric_acid": .vegan,
        "lauryl_alcohol": .vegan,
        "leather": .animal,
        "limestone": .vegan,
        "lipase": .both,
        "lipoxygenase": .vegan,
        "lutein": .both,
        "magnesium_stearate": .both,
        "malic_acid": .vegan,
        "maltodextrin": .vegan,
        "mannitol": .vegan,
        "mentha": .vegan,
        "metafolin": .vegan,
        "methanol": .vegan,
        "methyl_alcohol": .vegan,
        "methyl_cellulose": .vegan,
        "methyl_cinnamate": .vegan,
        "methyl_chloride": .vegan,
        "milk_sugar": .animal,
        "mink_oil": .animal,
        "modified_food_starch": .vegan,
        "mohair": .animal,
        "monoazo": .both,
        "monocalcium_phosphate": .both,
        "mono_diglycerides": .both,
        "monosodium_glutamate": .vegan,
        "musk": .both,
        "natural": .both,
        "natural_flavor": .both,
        "natural_red_4": .animal,
        "niacin": .both,
        "nicotinic_acid": .both,
        "nutrasweet": .vegan,
        "nutritional_yeast": .both,
        "octinoxate": .vegan,
        "octyl_methoxycinnamate": .vegan,
        "oestrogen": .animal,
        "oleic_acid": .both,
        "oleic_alcohol": .both,
        "oleoic_oil": .animal,
        "oleostearin": .animal,
        "oleth_2_through_50": .both,
        "orange_yellow_s": .both,
        "oxybenzone": .vegan,
        "palmitate": .both,
        "palmitic_acid": .both,
        "panthenol": .both,
        "papain": .vegan,
        "paracasein": .animal,
        "paraffin": .vegan,
        "parchment": .both,
        "pearl": .animal,
        "peg": .both,
        "pepsin": .animal,
        "petroleum": .vegan,
        "pharmaceutical_glaze": .animal,
        "phenol": .vegan,
        "phosphoric_acid": .vegan,
        "placenta": .animal,
        "polyethylene": .vegan,
        "polyglycerol_polyricinoleate": .both,
        "polysorbate_60": .both,
        "polysorbate_80": .both,
        "polyvinylpyrrolidone": .vegan,
        "polyoxyethylene_8_stearate": .both,
        "polyoxyethylene_40_stearate": .both,
        "potassium_chloride": .vegan,
        "potassium_hydroxide": .vegan,
        "potassium_lactate": .both,
        "potassium_sorbate": .vegan,
        "progesterone": .both,
        "propolis": .animal,
        "propylene": .vegan,
        "propylene_glycol": .both,
        "propylene_oxide": .vegan,
        "quinoline_yellow": .both,
        "reduced_iron": .vegan,
        "rennin": .both,
        "red_40": .both,
        "resinous_glaze": .animal,
        "reticulin": .animal,
        "riboflavin": .both,
        "riboflavin_5_phosphate": .both,
        "roe": .animal,
        "royal_jelly": .animal,
        "sable": .animal,
        "salicylic_acid": .vegan,
        "silk": .animal,
        "sodium_alginate": .vegan,
        "sodium_aluminum_sulfate": .vegan,
        "sodium_benzoate": .vegan,
        "sodium_bicarbonate": .vegan,
        "sodium_carbonate": .vegan,
        "sodium_hydroxide": .vegan,
        "sodium_lactate": .both,
        "sodium_phosphate": .both,
        "sodium_stearoyl_lactylate": .both,
        "sorbitol": .vegan,
        "spermaceti": .animal,
        "squalene": .animal,
        "stearic_acid": .both,
        "stearyl_alcohol": .both,
        "sucrose": .vegan,
        "sulfuric_acid": .vegan,
        "sunflower_lecithin": .vegan,
        "sunset_yellow_fcf": .both,
        "talc": .vegan,
        "tartaric_acid": .vegan,
        "tartrazine": .both,
        "thiamine": .both,
        "tocopherol": .both,
        "trypsin": .animal,
        "turmeric": .vegan,
        "urea": .both,
        "vanilla": .both,
        "vanillin": .both,
        "vegetable_carbon": .both,
        "vitamin_b1": .both,
        "vitamin_b2": .both,
        "vitamin_b3": .both,
        "vitamin_b5": .both,
        "vitamin_b6": .both,
        "vitamin_b7": .both,
        "vitamin_b9": .both,
        "vitamin_b12": .both,
        "vitamin_c": .vegan,
        "vitamin_d2": .both,
        "vitamin_d3": .both,
        "vitamin_e": .both,
        "wax": .both,
        "wool": .animal,
        "e100": .vegan,
        "e101": .both,
        "e101a": .both,
        "e102": .both,
        "e104": .both,
        "e110": .both,
        "e120": .animal,
        "e129": .both,
        "e133": .both,
        "e150a": .both,
        "e150b": .both,
        "e150c": .both,
        "e150d": .both,
        "e153": .both,
        "e160a": .vegan,
        "e160b": .vegan,
        "e160c": .vegan,
        "e162": .vegan,
        "e163": .vegan,
        "e170": .both,
        "e200": .vegan,
        "e202": .vegan,
        "e211": .vegan,
        "e223": .vegan,
        "e270": .both,
        "e282": .vegan,
        "e296": .vegan,
        "e300": .vegan,
        "e315": .vegan,
        "e322": .both,
        "e325": .both,
        "e326": .both,
        "e327": .both,
        "e341": .both,
        "e375": .both,
        "e385": .vegan,
        "e406": .vegan,
        "e407": .vegan,
        "e412": .vegan,
        "e415": .both,
        "e420": .vegan,
        "e421": .vegan,
        "e422": .both,
        "e430": .both,
        "e431": .both,
        "e432": .both,
        "e433": .both,
        "e434": .both,
        "e435": .both,
        "dried_egg": .eggetarian,
        "liquid_egg": .eggetarian,
        "egg_substitute": .eggetarian,
        "egg_lecithin": .eggetarian,
        "milk_powder": .vegetarian,
        "ghee": .vegetarian,
        "curd": .vegetarian,
        "paneer": .vegetarian,
        "whey_protein": .vegetarian,
        "buttermilk": .vegetarian,
        "skimmed_milk": .vegetarian,
        "condensed_milk": .vegetarian,
        "evaporated_milk": .vegetarian,
        "milk_solids": .vegetarian,
        "dairy": .vegetarian,
        "dairy_products": .vegetarian,
        "meat": .animal,
        "beef": .animal,
        "pork": .animal,
        "chicken": .animal,
        "mutton": .animal,
        "fish": .pescatarian,
        "seafood": .animal,
        "shrimp": .pescatarian,
        "prawn": .pescatarian,
        "crab": .pescatarian,
        "lobster": .pescatarian,
        "oyster": .pescatarian,
        "mussel": .pescatarian,
        "clam": .pescatarian,
        "squid": .pescatarian,
        "octopus": .pescatarian,
        "anchovies": .pescatarian,
        "fish_sauce": .pescatarian,
        "animal_fat": .animal,
        "rennet": .animal,
        "isinglass": .animal,
        "carmine": .animal,
        "shellac": .animal,
        "bone_char": .animal,
        "bone_phosphate": .animal,
        "salmon": .pescatarian,
        "tuna": .pescatarian,
        "cod": .pescatarian,
        "halibut": .pescatarian,
        "mackerel": .pescatarian,
        "sardines": .pescatarian,
        "scallop": .pescatarian,
        "seaweed": .vegan,
        "nori": .vegan,
        "wakame": .vegan,
        "kelp": .vegan,
        "lamb": .animal,
        "veal": .animal,
        "goat": .animal,
        "duck": .animal,
        "turkey": .animal,
        "bacon": .animal,
        "ham": .animal,
        "sausage": .animal,
        "gelatin": .animal,
        "lard": .animal,
        "tallow": .animal,
        "milk": .vegetarian,
        "cheese": .vegetarian,
        "butter": .vegetarian,
        "cream": .vegetarian,
        "yogurt": .vegetarian,
        "whey": .vegetarian,
        "casein": .vegetarian,
        "lactose": .vegetarian,
        "egg": .eggetarian,
        "egg_white": .eggetarian,
        "egg_yolk": .eggetarian,
        "albumin": .eggetarian,
        "egg_powder": .eggetarian,
        "egg_solids": .eggetarian,
        "tofu": .vegan,
        "tempeh": .vegan,
        "seitan": .vegan,
        "soy": .vegan,
        "lentils": .vegan,
        "beans": .vegan,
        "chickpeas": .vegan,
        "nuts": .vegan,
        "seeds": .vegan,
        "vegetables": .vegan,
        "fruits": .vegan,
        "grains": .vegan,
        "rice": .vegan,
        "wheat": .vegan,
        "corn": .vegan,
        "quinoa": .vegan,
        "sugar": .vegan,
        "salt": .vegan,
        "spices": .vegan,
        "herbs": .vegan,
        "oil": .vegan,
        "vinegar": .vegan,
        "yeast": .vegan,
        "starch": .vegan,
        "flour": .vegan,
        "baking_powder": .vegan,
        "baking_soda": .vegan,
        "pectin": .vegan,
        "agar": .vegan,
        "carrageenan": .vegan,
        "xanthan_gum": .vegan,
        "lecithin": .both,
        "natural_flavors": .both,
        "artificial_flavors": .both,
        "colors": .both,
        "preservatives": .both,
        "potato": .vegan,
        "onion": .vegan,
        "garlic": .vegan,
        "ginger": .vegan,
        "carrot": .vegan,
        "radish": .vegan,
        "beetroot": .vegan,
        "sweet_potato": .vegan,
        "turnip": .vegan,
        "yam": .vegan,
        "cassava": .vegan,
        "turmeric_root": .vegan,
        "mushroom": .vegan,
        "broccoli": .vegan,
        "cauliflower": .vegan,
        "cabbage": .vegan,
        "sprouts": .vegan,
        "bamboo_shoot": .vegan,
        "eggplant": .vegan,
        "asparagus": .vegan,
        "artichoke": .vegan,
        "leek": .vegan,
        "shallot": .vegan,
        "horseradish": .vegan,
        "parsnip": .vegan,
        "rutabaga": .vegan,
        "celeriac": .vegan,
        "wasabi": .vegan,
        "lotus_root": .vegan,
        "arrowroot": .vegan,
        "galangal": .vegan,
        "maca_root": .vegan,
        "burdock_root": .vegan,
        "sunchoke": .vegan,
        "jicama": .vegan,
        "brussels_sprouts": .vegan,
        "fiddleheads": .vegan,
        "water_chestnut": .vegan,
        "corn_sprouts": .vegan,
        "bean_sprouts": .vegan,
        "alfalfa_sprouts": .vegan,
        "microgreens": .vegan,
        "kohlrabi": .vegan,
        "romanesco": .vegan,
        "sea_vegetables": .vegan,
        "tomato": .vegan,
        "bell_pepper": .vegan,
        "chili_pepper": .vegan,
        "pumpkin": .vegan,
        "squash": .vegan,
        "cucumber": .vegan,
        "zucchini": .vegan,
        "okra": .vegan,
        "sauerkraut": .vegan,
        "kimchi": .vegan,
        "miso": .vegan,
        "natto": .vegan,
        "kombucha": .vegan,
        "pickled_vegetables": .vegan,
        "fermented_foods": .vegan,
        "night_harvested_vegetables": .vegan,
        "night_picked_vegetables": .vegan
    ]
    
    init() {
        setup()
    }
    
    private func setup() {
        guard let url = Bundle.main.url(forResource: "Food", withExtension: "json") else {
            assertionFailure()
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let ingredients = try decoder.decode([Ingredient].self, from: data)
            
            self.ingredients = ingredients
            var map: [String: Int] = [:]
            ingredients.enumerated().forEach { offset, ingredient in
                map.updateValue(offset, forKey: ingredient.name.localizedLowercase)
            }
            self.map = map
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
    
    private func classifyIngredient(_ name: String) -> IngredientType {
        // Convert ingredient name to a format matching our known ingredients dictionary
        let formattedName = name.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "_")
        
        print("\n=== Attempting to classify ingredient: \(name) ===")
        print("Formatted name: \(formattedName)")
        
        // First try exact match with formatted name
        if let type = knownIngredients[formattedName] {
            print("✅ Found exact match for ingredient: \(formattedName)")
            return type
        }
        print("❌ No exact match found for: \(formattedName)")
        
        // If no exact match, try case-insensitive search
        for (key, value) in knownIngredients {
            if key.lowercased() == formattedName.lowercased() {
                print("✅ Found case-insensitive match: \(formattedName) -> \(key)")
                return value
            }
        }
        print("❌ No case-insensitive match found for: \(formattedName)")
        
        // Try partial matching if no exact match found
        for (key, value) in knownIngredients {
            if key.lowercased().contains(formattedName.lowercased()) || 
               formattedName.lowercased().contains(key.lowercased()) {
                print("✅ Found partial match: \(formattedName) -> \(key)")
                return value
            }
        }
        print("❌ No partial match found for: \(formattedName)")
        
        print("⚠️ No matches found - defaulting to .vegetarian for: \(formattedName)")
        return .vegetarian // Default to vegetarian if unknown, instead of .both
    }
    
    func getIngredients(
        from items: [String],
        for preference: Preference
    ) -> (
        whitelisted: [Ingredient],
        blacklisted: [Ingredient],
        vegan: [Ingredient],
        nonVegan: [Ingredient],
        unclassified: [Ingredient]
    ) {
        print("\n=== Starting ingredient classification ===")
        print("Number of items to process: \(items.count)")
        print("Raw items: \(items)")
        
        var whitelisted: [Ingredient] = []
        var blacklisted: [Ingredient] = []
        var vegan: [Ingredient] = []
        var nonVegan: [Ingredient] = []
        var unclassified: [Ingredient] = []
        
        // Define vegan food groups
        let veganFoodGroups = [
            "Vegetables",
            "Fruits",
            "Herbs and spices",
            "Nuts",
            "Pulses",
            "Coffee and coffee products"
        ]
        
        // Define non-vegetarian food groups
        let nonVegFoodGroups = [
            "Animal foods",
            "Aquatic foods"
        ]
        
        // Track processed items to avoid duplicates
        var processedItems = Set<String>()
        
        items.forEach { item in
            let cleanedItem = item.trimmingCharacters(in: .whitespacesAndNewlines)
            let lowercasedItem = cleanedItem.lowercased()
            
            print("\n--- Processing item: \(cleanedItem) ---")
            print("Lowercased: \(lowercasedItem)")
            
            // Skip if we've already processed this item
            guard !processedItems.contains(lowercasedItem) else {
                print("⏭️ Skipping duplicate item: \(lowercasedItem)")
                return
            }
            processedItems.insert(lowercasedItem)
            
            if let index = map[lowercasedItem] ?? map[singularizeWord(lowercasedItem)] {
                print("📍 Found in ingredient database: \(ingredients[index].name)")
                var ingredient = ingredients[index]
                
                // First check if the ingredient belongs to a non-veg food group
                if let foodGroup = ingredient.foodGroup,
                   nonVegFoodGroups.contains(foodGroup) {
                    print("🍖 Ingredient belongs to non-vegetarian food group: \(foodGroup)")
                    ingredient.ingredientType = .animal
                }
                // Then check if it belongs to a vegan food group
                else if let foodGroup = ingredient.foodGroup,
                        veganFoodGroups.contains(foodGroup) {
                    print("🌱 Ingredient belongs to vegan food group: \(foodGroup)")
                    ingredient.ingredientType = .vegan
                } else {
                    print("🔍 Classifying ingredient using known ingredients list")
                    ingredient.ingredientType = classifyIngredient(cleanedItem)
                }
                
                // Classify based on ingredient type and user preference
                if let type = ingredient.ingredientType {
                    switch (type, preference) {
                    case (.vegan, _):
                        // Vegan ingredients are safe for all preferences
                        print("✅ Vegan ingredient - safe for all preferences")
                        vegan.append(ingredient)
                        
                    case (.vegetarian, .vegan):
                        // Dairy is not safe for vegans
                        print("🚫 Dairy ingredient - not safe for vegans")
                        nonVegan.append(ingredient)
                        
                    case (.vegetarian, _):
                        // Dairy is safe for vegetarians and others
                        print("✅ Dairy ingredient - safe for non-vegan preferences")
                        vegan.append(ingredient)
                        
                    case (.animal, _):
                        // Animal products are never safe
                        print("🚫 Animal ingredient - not safe for any preference")
                        nonVegan.append(ingredient)
                        
                    case (.eggetarian, .eggetarian),
                         (.eggetarian, .pescatorian):
                        // Eggs are safe for eggetarians and pescatarians
                        print("✅ Egg ingredient - safe for eggetarian/pescatarian")
                        vegan.append(ingredient)
                        
                    case (.eggetarian, _):
                        // Eggs are not safe for others
                        print("🚫 Egg ingredient - not safe for this preference")
                        nonVegan.append(ingredient)
                        
                    case (.pescatarian, .pescatorian):
                        // Fish is safe for pescatarians
                        print("✅ Fish/seafood ingredient - safe for pescatarians")
                        vegan.append(ingredient)
                        
                    case (.pescatarian, _):
                        // Fish is not safe for others
                        print("🚫 Fish/seafood ingredient - not safe for this preference")
                        nonVegan.append(ingredient)
                        
                    case (.both, _):
                        // For uncertain ingredients, classify as non-vegan to be safe
                        print("⚠️ Uncertain ingredient - classifying as non-vegan")
                        nonVegan.append(ingredient)
                    }
                } else {
                    // If no ingredient type is set, check food group again
                    if let foodGroup = ingredient.foodGroup,
                       veganFoodGroups.contains(foodGroup) {
                        print("🌱 No type set, but belongs to vegan food group: \(foodGroup)")
                        vegan.append(ingredient)
                    } else {
                        print("⚠️ No type set and no vegan food group - classifying as non-vegan")
                        nonVegan.append(ingredient)
                    }
                }
                
                // Classify based on food group preference
                if let foodGroup = ingredient.foodGroup {
                    if !preference.blacklistedIngredientGroups.contains(foodGroup) {
                        print("✅ Food group not blacklisted: \(foodGroup)")
                        whitelisted.append(ingredient)
                    } else {
                        print("⛔️ Food group is blacklisted: \(foodGroup)")
                        blacklisted.append(ingredient)
                    }
                }
            } else {
                // Skip common non-ingredient text patterns
                let skipPatterns = [
                    "www", "com", "alamy", "image", "id",
                    "suitable", "vegetarian", "vegan",
                    "eet", "ohh", "rgot", "sar",
                    "ingredients", "contains", "may contain",
                    "manufactured", "produced", "packed",
                    "best before", "use by"
                ]
                
                if skipPatterns.contains(where: { lowercasedItem.contains($0) }) {
                    print("⏭️ Skipping non-ingredient text: \(lowercasedItem)")
                    return
                }
                
                // Check in knownIngredients first
                let formattedName = cleanedItem.lowercased().replacingOccurrences(of: " ", with: "_")
                if let type = knownIngredients[formattedName] {
                    print("📍 Found in known ingredients list: \(cleanedItem)")
                    let knownIngredient = Ingredient(
                        id: -Int.random(in: 1...999999),
                        name: cleanedItem.capitalized,
                        nameScientific: nil,
                        description: nil,
                        itisId: nil,
                        wikipediaId: nil,
                        foodGroup: nil,
                        foodSubgroup: nil,
                        foodType: "known",
                        category: nil,
                        ncbiTaxonomyId: nil,
                        publicId: "known_\(UUID().uuidString)",
                        ingredientType: type
                    )
                    
                    switch type {
                    case .vegan:
                        print("✅ Known vegan ingredient")
                        vegan.append(knownIngredient)
                    case .vegetarian:
                        print("🥚 Known vegetarian ingredient")
                        nonVegan.append(knownIngredient)
                    case .animal:
                        print("🚫 Known animal ingredient")
                        nonVegan.append(knownIngredient)
                    case .both:
                        print("")
                    case .eggetarian:
                        print("🥚 Known eggetarian ingredient")
                        nonVegan.append(knownIngredient)
                    case .pescatarian:
                        print("🐟 Known pescatarian ingredient")
                        nonVegan.append(knownIngredient)
                    }
                    return
                }
                
                print("🔍 Searching for similar ingredients")
                // Try to find a similar ingredient in the database
                let similarIngredients = ingredients.filter { ingredient in
                    let similarName = ingredient.name.lowercased()
                    return similarName.contains(lowercasedItem) || lowercasedItem.contains(similarName)
                }
                
                if let matchedIngredient = similarIngredients.first {
                    print("📍 Found similar ingredient: \(matchedIngredient.name)")
                    // Use the matched ingredient's food group to classify
                    if let foodGroup = matchedIngredient.foodGroup,
                       veganFoodGroups.contains(foodGroup) {
                        print("✅ Similar ingredient belongs to vegan food group: \(foodGroup)")
                        var veganIngredient = matchedIngredient
                        veganIngredient.ingredientType = .vegan
                        vegan.append(veganIngredient)
                        return
                    }
                }
                
                print("❓ No matches found - adding to unclassified")
                // Create a temporary ingredient for unclassified items
                let unclassifiedIngredient = Ingredient(
                    id: -Int.random(in: 1...999999),
                    name: cleanedItem.capitalized,
                    nameScientific: nil,
                    description: nil,
                    itisId: nil,
                    wikipediaId: nil,
                    foodGroup: nil,
                    foodSubgroup: nil,
                    foodType: "unknown",
                    category: nil,
                    ncbiTaxonomyId: nil,
                    publicId: "unclassified_\(UUID().uuidString)",
                    ingredientType: nil
                )
                unclassified.append(unclassifiedIngredient)
            }
        }
        
        print("\n=== Final classification counts ===")
        print("Whitelisted: \(whitelisted.count)")
        print("Blacklisted: \(blacklisted.count)")
        print("Vegan: \(vegan.count)")
        print("Non-vegan: \(nonVegan.count)")
        print("Unclassified: \(unclassified.count)")
        
        // Remove duplicates while preserving order
        whitelisted = Array(NSOrderedSet(array: whitelisted).array as! [Ingredient])
        blacklisted = Array(NSOrderedSet(array: blacklisted).array as! [Ingredient])
        vegan = Array(NSOrderedSet(array: vegan).array as! [Ingredient])
        nonVegan = Array(NSOrderedSet(array: nonVegan).array as! [Ingredient])
        unclassified = Array(NSOrderedSet(array: unclassified).array as! [Ingredient])
        
        // Remove ingredients from whitelisted/blacklisted if they're already in vegan/non-vegan
        let veganNonVeganIds = Set(vegan.map { $0.id } + nonVegan.map { $0.id })
        whitelisted = whitelisted.filter { !veganNonVeganIds.contains($0.id) }
        blacklisted = blacklisted.filter { !veganNonVeganIds.contains($0.id) }
        
        return (whitelisted, blacklisted, vegan, nonVegan, unclassified)
    }
    
    func singularizeWord(_ word: String) -> String {
        let tagger = NSLinguisticTagger(tagSchemes: [.lemma], options: 0)
        tagger.string = word
        var singularForm = word
        
        tagger.enumerateTags(
            in: NSRange(location: 0, length: word.utf16.count),
            unit: .word,
            scheme: .lemma,
            options: [.omitWhitespace, .omitPunctuation, .omitOther]
        ) { tag, tokenRange, _ in
            if let lemma = tag?.rawValue {
                singularForm = lemma
            }
        }
        
        return singularForm
    }
}
