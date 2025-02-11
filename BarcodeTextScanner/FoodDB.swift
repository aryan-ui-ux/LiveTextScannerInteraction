import Foundation
import CoreData

@objc(FoodDB)
public class FoodDB: NSManagedObject {
    @NSManaged public var name: String?
    @NSManaged public var food_group: String?
    @NSManaged public var food_subgroup: String?
}

extension FoodDB {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FoodDB> {
        return NSFetchRequest<FoodDB>(entityName: "FoodDB")
    }
} 