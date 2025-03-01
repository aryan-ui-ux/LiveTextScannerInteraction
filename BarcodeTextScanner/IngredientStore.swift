//
//  IngredientStore.swift
//  BarcodeTextScanner
//
//  Created by Mustafa Yusuf on 18/02/25.
//

import NaturalLanguage

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
    // let nameScientific: String?
    // let description: String?
    // let itisId: String?
    // let wikipediaId: String?
    let foodGroup: String?
    // let foodSubgroup: String?
    // let foodType: String?
    // let category: String?
    // let ncbiTaxonomyId: Int?
    // let publicId: String?
    var ingredientType: IngredientType?
}

class IngredientStore {
    
    static let shared: IngredientStore = .init()
    var map: [String: Int] = [:]
    var ingredients: [Ingredient] = []
    
    // Add this property to store common words to skip

    let commonWordsToSkip: Set<String> = [
    "crushed", "ground", "roasted", "toasted", "refined", "raw", "fresh", "organic", "pure", "unrefined", "whole", "dehydrated", "filtered", "homogenized", "pasteurized",
    "extract", "concentrate", "syrup", "flour", "starch", "gel", "crystals", "emulsifier", "hydrolyzed", "enriched", "fortified", "maltodextrin", "modified", "isolate",
    "food", "ingredient", "substance", "blend", "formula", "mix", "compound", "elements", "contents", "portions", "preparation",
    "water", "alcohol", "vinegar", "milk", "broth", "stock", "essence", "infusion", "distillate",
    "lecithin", "antioxidant", "citric", "sorbate", "benzoate", "nitrate", "nitrite", "sulfite", "glutamate", "phosphate", "carbonate", "xanthan", "guar", "carrageenan",
    "flavor", "aroma", "sweetener", "artificial", "natural", "seasoning", "enhancer", "glucose", "fructose", "sucrose", "dextrose", "corn syrup", "cane",
    "powder", "flakes", "oil", "sugar", "white", "natural", "and", "acid", "wine", "mix", "seeds", "seed", "juice", "sauce", "product", "dried", "essence", "gum", "fiber", "coloring"
]
    
    init() {
        setup()
    }
    
    func setup() {
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
    
    func getIngredients(
        from items: [String],
        for preference: Preference
    ) -> (
        whitelisted: [String],
        blacklisted: [String],
        notSure: [String],
        unclassified: [String]
    ) {
        var addedIds: [Int] = []
        var whitelisted: [String] = []
        var blacklisted: [String] = []
        var notSure: [String] = []
        var unclassified: [String] = []

        func didFindAndAddIngredient(for text: String) -> Bool {
            let lowercasedItem = text.lowercased()
            var found = false
            
            if let index = map[lowercasedItem] {
                let ingredient = ingredients[index]
                if !addedIds.contains(ingredient.id) {
                    addedIds.append(ingredient.id)
                    let foodGroup = ingredient.foodGroup ?? ""
                    if preference.blacklistedIngredientGroups.contains(foodGroup) {
                        blacklisted.append(text)
                    } else if preference.unsureIngredients.contains(foodGroup) {
                        notSure.append(text)
                    } else {
                        whitelisted.append(text)
                    }
                }
                return true
            }
            
            /* Fuzzy search - i taken from stack overflow */
            var lastFoundIngredient: Ingredient?
            var isBlacklistedFound = false
            var isNotSureFound = false
            
            for ingredient in ingredients {
                let ingredientWords = ingredient.name.localizedLowercase.split(separator: " ")
                let searchWords = lowercasedItem.split(separator: " ")
                
                for searchWord in searchWords {
                    if commonWordsToSkip.contains(String(searchWord)) {
                        continue
                    }
                    
                    if ingredientWords.contains(where: { $0 == searchWord }) {
                        found = true
                        let foodGroup = ingredient.foodGroup ?? ""
                        
                        if preference.blacklistedIngredientGroups.contains(foodGroup) {
                            isBlacklistedFound = true
                            lastFoundIngredient = ingredient
                            break
                        } else if preference.unsureIngredients.contains(foodGroup) {
                            isNotSureFound = true
                            lastFoundIngredient = ingredient
                            break
                        } else {
                            lastFoundIngredient = ingredient
                        }
                    }
                }
                
                if isBlacklistedFound || isNotSureFound {
                    break
                }
            }
            
            if let ingredient = lastFoundIngredient, !addedIds.contains(ingredient.id) {
                addedIds.append(ingredient.id)
                let foodGroup = ingredient.foodGroup ?? ""
                
                if isBlacklistedFound {
                    blacklisted.append(text)
                } else if isNotSureFound {
                    notSure.append(text)
                } else {
                    whitelisted.append(text)
                }
            }
            
            return found
        }

        items.forEach { item in
            if !didFindAndAddIngredient(for: item) {
                unclassified.append(item)
            }
        }

        
        return (whitelisted, blacklisted, notSure, unclassified)
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
