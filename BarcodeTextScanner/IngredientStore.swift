//
//  IngredientStore.swift
//  BarcodeTextScanner
//
//  Created by Mustafa Yusuf on 18/02/25.
//

import Foundation

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
        blacklisted: [Ingredient]
    ) {
        var whitelisted: [Ingredient] = []
        var blacklisted: [Ingredient] = []
        items.forEach { item in
            if let index = map[item.localizedLowercase] ?? map[singularizeWord(item).localizedLowercase] {
                let ingredient = ingredients[index]
                if let foodGroup = ingredient.foodGroup,
                    !preference.blacklistedIngredientGroups.contains(foodGroup) {
                    whitelisted.append(ingredient)
                } else {
                    blacklisted.append(ingredient)
                }
            } else {
                // assertionFailure()
            }
        }
        return (whitelisted, blacklisted)
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
