//
//  EntryDetailController.swift
//  Hike
//
//  Created by TJ Barber on 8/21/17.
//  Copyright © 2017 Novel. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class EntryDetailController: UITableViewController {
    
    lazy var imagePickerController: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        
        return imagePicker
    }()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var entry: UITextField!
    
    @IBAction func dismissKeyboard(_ sender: Any) {
        tableView.endEditing(true)
    }
    
    @IBAction func takePicture(_ sender: Any) {
        if (UIImagePickerController.isSourceTypeAvailable(.camera) && !checkPermissionsFor(sourceType: .camera)) {
            AlertHelper.showAlert(withMessage: "Please allow Hike to access camera in Settings!", presentingViewController: self)
            return
        }
    
        if (!checkPermissionsFor(sourceType: .photoLibrary) || !checkPermissionsFor(sourceType: .savedPhotosAlbum)) {
            AlertHelper.showAlert(withMessage: "Please allow Hike to access camera in Settings!", presentingViewController: self)
            return
        }
        
        self.present(imagePickerController, animated: true, completion: nil)
    }
}

extension EntryDetailController: UINavigationControllerDelegate {
    
}

// MARK: - Camera Helper Methods

extension EntryDetailController {
    func checkPermissionsFor(sourceType: UIImagePickerControllerSourceType) -> Bool {
        switch sourceType {
        case .camera:
            if (AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == AVAuthorizationStatus.denied) {
                return false
            }
                    case .photoLibrary, .savedPhotosAlbum:
            if (PHPhotoLibrary.authorizationStatus() == .restricted) {
                return false
            }
        }
        
        return true
    }
}

// MARK: - UIImagePickerControllerDelegate

extension EntryDetailController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = image
        dismiss(animated: true, completion: nil)
    }
}
