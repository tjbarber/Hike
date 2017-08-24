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
    
    var entryImage: UIImage?
    
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
    @IBOutlet weak var entryTextField: UITextField!
    
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
    
    @IBAction func save(_ sender: Any) {
        // FIXME: Currently only supports adding new, not updating
        let entry = Entry(context: EntryStore.sharedInstance.viewContext)
        
        // FIXME: You have to have either a text entry or image
        guard let name = titleLabel.text else {
            AlertHelper.showAlert(withMessage: "You must give your entry a name!", presentingViewController: self)
            return
        }
        
        entry.name = name
        entry.text = entryTextField.text
        
        if let image = self.entryImage {
            if let imageData = UIImageJPEGRepresentation(image, 0.6) {
                entry.image = imageData as NSData
            }
        }
        
        EntryStore.sharedInstance.insert(entry) { error in
            if let error = error {
                AlertHelper.showAlert(withMessage: error.localizedDescription, presentingViewController: self)
            }
            
            // We saved!
            self.navigationController?.popViewController(animated: true)
        }
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
        if let scaledImage = image.scaleImageTo(newSize: CGSize(width: (image.size.width / 4), height: (image.size.height) / 4)) {
            self.entryImage = scaledImage
        } else {
            // Couldn't resize image for some reason...
            self.entryImage = image
        }
        
        imageView.image = self.entryImage
        dismiss(animated: true, completion: nil)
    }
}
