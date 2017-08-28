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
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        
        formatter.locale = Locale(identifier: "en-US")
        formatter.setLocalizedDateFormatFromTemplate("MMMM dd, yyyy")
        
        return formatter
    }()
    
    @IBOutlet weak var entryImageView: UIImageView!
    @IBOutlet weak var entryTitle: UILabel!
    @IBOutlet weak var entryText: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var lastUpdatedDateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.entryImageView.image = nil
        self.entryText.text = nil
        self.entryTitle.text = nil
        self.dateLabel.text = nil
        self.lastUpdatedDateLabel.text = nil
        self.locationLabel.text = nil
        self.locationLabel.isHidden = true
    }
    
    func configure(withEntry entry: Entry, operationQueue: OperationQueue) {
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
        
        if let createdAt = entry.createdAt {
            self.dateLabel.text = dateFormatter.string(from: createdAt as Date)
            
        }
        
        if let updatedAt = entry.updatedAt {
            let lastUpdatedDateString = dateFormatter.string(from: updatedAt as Date)
            
            self.lastUpdatedDateLabel.text = "Last updated on \(lastUpdatedDateString)"
        }
        
        if let location = entry.location {
            self.locationLabel.text = location
            self.locationLabel.isHidden = false
        }
        self.entryText.sizeToFit()
    }
}
