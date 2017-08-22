//
//  EntryStore.swift
//  Hike
//
//  Created by TJ Barber on 8/21/17.
//  Copyright © 2017 Novel. All rights reserved.
//

import Foundation
import CoreData

class EntryStore {
    static let sharedInstance = EntryStore()
    let dataStoreContainer = DataStore.sharedInstance.persistantContainer
    let viewContext = DataStore.sharedInstance.persistantContainer.viewContext
    
    func all(completion: @escaping ([Entry]?, Error?) -> Void) {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        let sortByDateCreated = NSSortDescriptor(key: #keyPath(Entry.createdAt), ascending: true)
        
        fetchRequest.sortDescriptors = [sortByDateCreated]
        
        viewContext.perform { [unowned self] in
            do {
                let allEntries = try self.viewContext.fetch(fetchRequest)
                completion(allEntries, nil)
            } catch (let description) {
                print("\(description)")
            }
        }
    }
    
    func insert(_ entry: Entry, completion: @escaping () -> Void) {
        viewContext.perform {
        }
    }
}
