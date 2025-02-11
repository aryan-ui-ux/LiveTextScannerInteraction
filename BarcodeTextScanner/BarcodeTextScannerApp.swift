//
//  BarcodeTextScannerApp.swift
//  BarcodeTextScanner
//
//  Created by Alfian Losari on 6/25/22.
//

import SwiftUI
import CoreData


// MARK: - Persistence
class Persistence: ObservableObject {
    static let shared = Persistence()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "FoodDB")
        
        struct PersistenceApp: App {
            @StateObject private var dataController = DataController()

            var body: some Scene {
                WindowGroup {
                    ContentView()
                        .environment(\.managedObjectContext,
                                                                    dataController.container.viewContext)
                }
            }
        }
        
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("CoreData: error: Failed to load model named Food")
                print("Error: \(error.localizedDescription)")
                fatalError("Error: \(error.localizedDescription)")
            }
            print("Successfully loaded CoreData store")
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
    
// MARK: - App
@main
struct BarcodeTextScannerApp: App {
    
    @StateObject private var vm = AppViewModel()
    @StateObject private var persistence = Persistence.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vm)
                .environmentObject(persistence)
                .task {
                    await vm.requestDataScannerAccessStatus()
                    
                    // Import foods data if needed
                    if UserDefaults.standard.bool(forKey: "didImportInitialFoods") == false {
                        UserDefaults.standard.set(true, forKey: "didImportInitialFoods")
                    }
                    
                    // Check the data
//                    persistence.checkFoodData()
                }
                .environment(\.managedObjectContext, persistence.container.viewContext)
        }
    }
}
