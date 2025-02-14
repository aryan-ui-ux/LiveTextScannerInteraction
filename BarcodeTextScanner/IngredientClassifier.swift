import Foundation
import CoreData
import SwiftUI
import Combine

@MainActor
public class IngredientClassifier: ObservableObject {
    public static let shared = IngredientClassifier()
    
    @Published public private(set) var classifications: [String: String] = [:]
    private let container: NSPersistentContainer
    
    private init() {
        container = NSPersistentContainer(name: "Food")
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading Core Data: \(error.localizedDescription)")
            }
            // Load existing classifications after store is loaded
            Task { @MainActor in
                self.loadStoredClassifications()
            }
        }
    }
    
    private func loadStoredClassifications() {
        classifications = getAllClassifications()
    }
    
    public func classifyIngredient(_ ingredient: String) -> String {
        // First check if we have it in memory
        if let existingClassification = classifications[ingredient] {
            return existingClassification
        }
        
        // Then check Core Data
        let request: NSFetchRequest<Ingredient> = Ingredient.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", ingredient)
        
        do {
            let results = try container.viewContext.fetch(request)
            if let existingIngredient = results.first, let classification = existingIngredient.classification {
                // Update memory cache
                classifications[ingredient] = classification
                return classification
            }
        } catch {
            print("Error fetching ingredient: \(error.localizedDescription)")
        }
        
        // If not found, create new random classification
        let possibleClassifications = ["veg", "non-veg", "vegan", "unknown"]
        let randomClassification = possibleClassifications.randomElement()!
        
        // Save the new classification
        let newIngredient = Ingredient(context: container.viewContext)
        newIngredient.name = ingredient
        newIngredient.classification = randomClassification
        
        do {
            try container.viewContext.save()
            // Update memory cache
            classifications[ingredient] = randomClassification
            objectWillChange.send()
        } catch {
            print("Error saving ingredient: \(error.localizedDescription)")
        }
        
        return randomClassification
    }
    
    public func clearAllClassifications() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Ingredient.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try container.viewContext.execute(deleteRequest)
            try container.viewContext.save()
            classifications.removeAll()
            objectWillChange.send()
        } catch {
            print("Error clearing classifications: \(error.localizedDescription)")
        }
    }
    
    public func getAllClassifications() -> [String: String] {
        let request: NSFetchRequest<Ingredient> = Ingredient.fetchRequest()
        
        do {
            let results = try container.viewContext.fetch(request)
            var newClassifications: [String: String] = [:]
            
            for ingredient in results {
                if let name = ingredient.name, let classification = ingredient.classification {
                    newClassifications[name] = classification
                }
            }
            
            return newClassifications
        } catch {
            print("Error fetching all classifications: \(error.localizedDescription)")
            return [:]
        }
    }
} 