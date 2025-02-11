//
//  CoreData.swift
//  BarcodeTextScanner
//
//  Created by Aryan on 11/02/25.
//

import Foundation


import CoreData

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "MyDatabase")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}
