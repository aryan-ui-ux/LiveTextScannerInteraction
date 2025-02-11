import Foundation
import CoreData

class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "FoodDB")
        
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
    
    // MARK: - Core Data Saving
    
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    // MARK: - Ingredient Classification
    
    func classifyIngredient(_ ingredient: String) -> String {
        // Randomly return one of: "veg", "non-veg", "vegan", nil
        let classifications = ["veg", "non-veg", "vegan", nil]
        return classifications.randomElement() ?? "unknown"
    }
} 