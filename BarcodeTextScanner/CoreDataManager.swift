import Foundation
import CoreData
import SwiftUI

public class CoreDataManager: ObservableObject {
    public static let shared = CoreDataManager()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Food")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - Core Data Operations
    
    func createFood(name: String, foodGroup: String?, foodSubgroup: String?, description: String?, wikipediaId: String?) {
        let food = Food(context: container.viewContext)
        food.name = name
        food.foodGroup = foodGroup
        food.foodSubgroup = foodSubgroup
        food.desc = description
        food.wikipediaId = wikipediaId
        
        saveContext()
    }
    
    func fetchFoods() -> [Food] {
        let request: NSFetchRequest<Food> = Food.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Food.name, ascending: true)]
        
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Error fetching foods: \(error)")
            return []
        }
    }
    
    func deleteFood(_ food: Food) {
        container.viewContext.delete(food)
        saveContext()
    }
    
    func updateFood(_ food: Food) {
        saveContext()
    }
    
    // MARK: - Ingredient Classification
    
    public func classifyIngredient(_ ingredient: String) -> String {
        // First, try to find existing classification in Core Data
        let request: NSFetchRequest<Food> = Food.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", ingredient)
        
        do {
            let results = try container.viewContext.fetch(request)
            if let existingFood = results.first, let foodGroup = existingFood.foodGroup {
                return foodGroup
            }
        } catch {
            print("Error fetching ingredient classification: \(error)")
        }
        
        // If not found, create new random classification
        let classifications = ["veg", "non-veg", "vegan", "unknown"]
        let randomClassification = classifications.randomElement()!
        
        // Save the classification for future use
        let food = Food(context: container.viewContext)
        food.name = ingredient
        food.foodGroup = randomClassification
        saveContext()
        
        return randomClassification
    }
    
    // MARK: - Core Data Saving
    
    private func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
} 