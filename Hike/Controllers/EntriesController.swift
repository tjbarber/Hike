//
//  ViewController.swift
//  Hike
//
//  Created by TJ Barber on 8/21/17.
//  Copyright © 2017 Novel. All rights reserved.
//

import UIKit

class EntriesController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var entries: [Entry]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableViewDataSource()
        loadAllEntries()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

// MARK: - UITableViewDataSource

extension EntriesController: UITableViewDataSource {
    func configureTableViewDataSource() {
        self.tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath)
        return cell
    }
}

// MARK: - Data Source Methods

extension EntriesController {
    func loadAllEntries() {
        EntryStore.sharedInstance.all { [unowned self] entries, error in
            if let error = error {
                // FIXME: HANDLE ERROR
                print("\(error)")
            }
            
            guard let entries = entries else {
                fatalError("No entries but error not caught.")
            }
            
            self.entries = entries
            
            DispatchQueue.main.async {
                self.refreshDisplayIfNoEntries()
            }
        }
    }
    
    func refreshDisplayIfNoEntries() {
        if let entries = self.entries {
            
            if entries.isEmpty {
                self.tableView.isHidden = true
                self.tableView.isUserInteractionEnabled = false
            } else {
                self.tableView.isHidden = false
                self.tableView.isUserInteractionEnabled = true
                self.tableView.reloadData()
            }
        }
    }
}
