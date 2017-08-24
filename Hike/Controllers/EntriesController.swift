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
    @IBOutlet weak var noEntriesView: UIView!
    
    var entries = [Entry]()
    lazy var entryImageQueue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableViewDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EntryCell.identifier, for: indexPath) as! EntryCell
        cell.configure(withEntry: self.entries[indexPath.row], operationQueue: entryImageQueue)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension EntriesController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 420.0
    }
}

// MARK: - Data Source Methods

extension EntriesController {
    func loadAllEntries() {
        EntryStore.sharedInstance.all { [unowned self] entries, error in
            if let error = error {
                // If we can't load the data at this point, we might as well crash.
                fatalError("\(error.localizedDescription)")
            }
            
            guard let entries = entries else {
                fatalError("No entries but error not caught.")
            }
            
            self.entries = entries
            
            DispatchQueue.main.async {
                self.refreshDisplay()
            }
        }
    }
    
    func refreshDisplay() {
        if entries.isEmpty {
            self.tableView.isHidden = true
            self.tableView.isUserInteractionEnabled = false
            self.noEntriesView.isHidden = false
            self.noEntriesView.isUserInteractionEnabled = true
        } else {
            self.tableView.isHidden = false
            self.tableView.isUserInteractionEnabled = true
            self.noEntriesView.isHidden = true
            self.noEntriesView.isUserInteractionEnabled = false
            self.tableView.reloadData()
        }
        
    }
}
