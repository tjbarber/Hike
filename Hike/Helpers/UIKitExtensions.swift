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
        let scale: CGFloat = 1.0
        UIGraphicsBeginImageContextWithOptions(newSize, !hasAlpha, scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
}
