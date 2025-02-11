import Foundation
import CoreData

class FoodStore: ObservableObject {
    let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = context
    }
    
    func createFood(name: String, foodGroup: String?, foodSubgroup: String?, description: String?, wikipediaId: String?) {
        let food = Food(context: viewContext)
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
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching foods: \(error)")
            return []
        }
    }
    
    func deleteFood(_ food: Food) {
        viewContext.delete(food)
        saveContext()
    }
    
    func updateFood(_ food: Food) {
        saveContext()
    }
    
    private func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
} 