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

enum EntryStatus {
    case updating
    case inserting
}

class EntryDetailController: UITableViewController {
    
    var entryStatus: EntryStatus = .inserting
    var entryImage: UIImage?
    var entry: Entry?
    
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
    @IBOutlet weak var entryTextField: UITextView!
    
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
        if self.entry == nil {
            self.entry = Entry(context: EntryStore.sharedInstance.viewContext)
        }
        
        guard let entry = self.entry else {
            fatalError("No entry object avaliable!")
        }
        
        entry.name = titleLabel.text
        entry.text = entryTextField.text
        
        if entry.name == nil && entry.text == nil {
            AlertHelper.showAlert(withMessage: "You must give your entry a title or content!", presentingViewController: self)
            return
        }
    
        if let image = self.entryImage {
            if let imageData = UIImageJPEGRepresentation(image, 0.6) {
                entry.image = imageData as NSData
            }
        }
        
        var dataError: Error?
        switch self.entryStatus {
        case .inserting:
            self.insert(entry) { error in
                if let error = error {
                    dataError = error
                }
            }
        case .updating:
            self.update(entry) { error in
                if let error = error {
                    dataError = error
                }
            }
        }
        
        if let dataError = dataError {
            AlertHelper.showAlert(withMessage: dataError.localizedDescription, presentingViewController: self)
            return
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let entry = self.entry {
            if let imageData = entry.image {
                self.imageView.image = UIImage(data: imageData as Data)
            }
            self.titleLabel.text = entry.name
            self.entryTextField.text = entry.text
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

// MARK: - Core Data Wrappers

extension EntryDetailController {
    func update(_ entry: Entry, completion: @escaping (Error?) -> Void) {
        EntryStore.sharedInstance.update(entry) { error in
            completion(error)
        }
    }
    
    func insert(_ entry: Entry, completion: @escaping (Error?) -> Void) {
        EntryStore.sharedInstance.insert(entry) { error in
            completion(error)
        }
    }
}
