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
        whitelisted: [Ingredient],
        blacklisted: [Ingredient],
        unclassified: [String]
    ) {
        
        var addedIds: [Int] = []
        var addedItems: [String] = []
        var whitelisted: [Ingredient] = []
        var blacklisted: [Ingredient] = []
        var unclassified: [String] = []
                
        Set(items).forEach { item in
            let lowercasedItem = item.lowercased()
            if let index = map[lowercasedItem] ?? map[singularizeWord(lowercasedItem)] {
                
                let ingredient = ingredients[index]
                if !addedIds.contains(ingredient.id) {
                    if preference.blacklistedIngredientGroups.contains(ingredient.foodGroup ?? "") {
                        blacklisted.append(ingredient)
                    } else {
                        whitelisted.append(ingredient)
                    }
                }
            } else if !addedItems.contains(item) {
                unclassified.append(item)
            }
        }
        
        return (whitelisted, blacklisted, unclassified)
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
