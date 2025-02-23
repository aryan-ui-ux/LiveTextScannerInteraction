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
    private var map: [String: Int] = [:]
    private var ingredients: [Ingredient] = []
    
    // Add this property to store common words to skip
    private let commonWordsToSkip: Set<String> = [
        "evaporated",
        "sea",
        "flakes",
        "oil",
        "sugar",
        "powder",
        "white",
        "natural",
        "and",
        "acid",
        "wine",
        "mix",
        "seeds",
        "seed",
        "juice",
        "sauce",
        "product",
        "dried",
        "lecithin"
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
            
            // Try exact match first
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
            
            // Fuzzy search
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
            
            // Add the final result to appropriate list
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
