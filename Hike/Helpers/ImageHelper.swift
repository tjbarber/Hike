//
//  ImageHelper.swift
//  Hike
//
//  Created by TJ Barber on 8/22/17.
//  Copyright © 2017 Novel. All rights reserved.
//

import UIKit

class ImageHelper {
    private init() { }
    static let sharedInstance = ImageHelper()
    
    let images = [String: UIImage]()
    
    func getImage(withObjectId: URL) -> UIImage? {
        return nil
    }
}
