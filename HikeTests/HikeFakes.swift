//
//  HikeFakes.swift
//  Hike
//
//  Created by TJ Barber on 8/29/17.
//  Copyright © 2017 Novel. All rights reserved.
//

import XCTest
import CoreData
@testable import Hike

class HikeFakes: XCTestCase {
    
    var persistentStore: NSPersistentStore!
    var storeCoordinator: NSPersistentStoreCoordinator!
    var managedObjectContext: NSManagedObjectContext!
    var managedObjectModel: NSManagedObjectModel!
    
    var entryStore = EntryStore.sharedInstance
    var fakeEntry: Entry!
    
    override func setUp() {
        super.setUp()
        
        managedObjectModel = NSManagedObjectModel.mergedModel(from: nil)
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        do{
            try persistentStore = storeCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
            managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            managedObjectContext.persistentStoreCoordinator = storeCoordinator
        }
        catch{
            print("Unresolved error \(error)")
        }
        
        entryStore.viewContext = managedObjectContext
        
        fakeEntry = NSEntityDescription.insertNewObject(forEntityName: Entry.identifier, into:managedObjectContext) as! Entry
        fakeEntry.createdAt = Date() as NSDate
        fakeEntry.updatedAt = Date() as NSDate
        fakeEntry.name = "This is my entry"
        fakeEntry.text = "This is my entry's text."
        fakeEntry.location = "Denver, CO"
        
        do{
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error)")
        }
    }
    
    override func tearDown() {
        entryStore.deleteAll { [unowned self] error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
            
            self.persistentStore = nil
            self.storeCoordinator = nil
            self.managedObjectContext = nil
            self.managedObjectModel = nil
        }
        
        super.tearDown()
    }
    
    func testInsertEntry() {
        let expectation = XCTestExpectation(description: "Test entry insertion")
        let secondfakeEntry = NSEntityDescription.insertNewObject(forEntityName: Entry.identifier, into:managedObjectContext) as! Entry
        secondfakeEntry.name = "This is my second entry"
        secondfakeEntry.text = "This is my second entry's text."
        secondfakeEntry.location = "Colorado Springs, CO"
        
        entryStore.insert(secondfakeEntry) { [unowned self] error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
            
            self.entryStore.all { entries, error in
                if let error = error {
                    XCTFail(error.localizedDescription)
                }
                
                XCTAssert(entries!.count == 2, "More or less than 2 entries found")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testUpdateEntry() {
        let expectation = XCTestExpectation(description: "Test entry update")

        fakeEntry.name = "My first entry has been updated."
        let originalUpdatedDate = fakeEntry.updatedAt! as Date
        
        entryStore.update(fakeEntry) { [unowned self] error in
            if error != nil {
                XCTFail()
            }
            
            let newUpdateDate = self.fakeEntry.updatedAt! as Date
            
            XCTAssert(originalUpdatedDate != newUpdateDate, "updatedAt is the same as before the update.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testDeleteAllEntries() {
        let expectation = XCTestExpectation(description: "Test entire data deletion")

        entryStore.deleteAll { [unowned self] error in
            if error != nil {
                XCTFail()
            }
            
            self.entryStore.all { entries, error in
                if error != nil {
                    XCTFail()
                }
                
                XCTAssert(entries!.count == 0, "Delete failed. More than 0 entry found")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
}
