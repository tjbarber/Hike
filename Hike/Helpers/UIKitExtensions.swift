//
//  UIKitExtensions.swift
//  Hike
//
//  Created by TJ Barber on 8/23/17.
//  Copyright © 2017 Novel. All rights reserved.
//

import UIKit

extension UIImage {
    func scaleImageTo(newSize: CGSize) -> UIImage? {
        let hasAlpha = false
        // DONT USE 0.0 
        // If you use 0.0, it will use the system's default, so upon conversion to data
        // and bringing it back to a UIImage, the size will be doubled or tripled
        // depending on your device.
        let scale: CGFloat = 1.0
        UIGraphicsBeginImageContextWithOptions(newSize, !hasAlpha, scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
}
