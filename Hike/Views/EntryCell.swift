//
//  EntryCell.swift
//  Hike
//
//  Created by TJ Barber on 8/22/17.
//  Copyright © 2017 Novel. All rights reserved.
//

import UIKit

class EntryCell: UITableViewCell {
    
    static let identifier = "\(EntryCell.self)"
    
    @IBOutlet weak var entryImageView: UIImageView!
    @IBOutlet weak var entryTitle: UILabel!
    @IBOutlet weak var entryText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(withEntry entry: Entry, operationQueue: OperationQueue) {
        // Clear everything in the cell
        self.entryImageView.image = nil
        self.entryText.text = nil
        self.entryTitle.text = nil
        
        // Assign new values
        if let imageData = entry.image {
            operationQueue.addOperation {
                let image = UIImage(data: imageData as Data)
                DispatchQueue.main.async {
                    self.entryImageView.image = image
                }
            }
        }
        
        self.entryTitle.text = entry.name
        self.entryText.text = entry.text
    }
}
