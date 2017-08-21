//
//  DataStore.swift
//  Hike
//
//  Created by TJ Barber on 8/21/17.
//  Copyright © 2017 Novel. All rights reserved.
//

import Foundation
import CoreData

class DataStore {
    static let sharedInstance = DataStore()
    
    let persistantContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Hike")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Error setting up Core Data.")
            }
        }
        return container
    }()
}
