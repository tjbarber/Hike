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
    var viewContext = DataStore.sharedInstance.persistantContainer.viewContext
    
    func all(completion: @escaping ([Entry]?, Error?) -> Void) {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        let sortByDateCreated = NSSortDescriptor(key: #keyPath(Entry.createdAt), ascending: false)
        
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
    
    func insert(_ entry: Entry, completion: @escaping (Error?) -> Void) {
        viewContext.perform {
            
            if let createdAt = entry.createdAt {
                entry.createdAt = createdAt
            } else {
                entry.createdAt = NSDate()
            }
            
            entry.updatedAt = NSDate()
            
            do {
                try self.viewContext.save()
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch (let e) {
                DispatchQueue.main.async {
                    completion(e)
                }
            }
        }
    }
    
    func update(_ entry: Entry, completion: @escaping (Error?) -> Void) {
        viewContext.perform {
            entry.updatedAt = Date() as NSDate
            
            do {
                try self.viewContext.save()
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch (let e) {
                DispatchQueue.main.async {
                    completion(e)
                }
            }
        }
    }
    
    func delete(_ entry: Entry, completion: @escaping (Error?) -> Void) {
        viewContext.perform {
            self.viewContext.delete(entry)
            do {
                try self.viewContext.save()
                DispatchQueue.main.async {
                    completion(nil)
                }
            }   catch (let e) {
                DispatchQueue.main.async {
                    completion(e)
                }
            }
        }
    }
    
    func deleteAll(completion: @escaping (Error?) -> Void) {
        self.all { entries, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
            
            guard let entries = entries else {
                return
            }
            
            let dispatchGroup = DispatchGroup()
            var deletionError: Error?
            
            for entry in entries {
                dispatchGroup.enter()
                self.delete(entry) { error in
                    if let error = error {
                        deletionError = error
                    }
                    
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: DispatchQueue.main) {
                completion(deletionError)
            }
        }
    }
}
