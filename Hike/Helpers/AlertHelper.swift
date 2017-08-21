//
//  AlertHelper.swift
//  Hike
//
//  Created by TJ Barber on 8/21/17.
//  Copyright © 2017 Novel. All rights reserved.
//

import UIKit

class AlertHelper {
    static func showAlert(withMessage message: String, presentingViewController: UIViewController) {
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        presentingViewController.present(alertController, animated: true, completion: nil)
    }
}
