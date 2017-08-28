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
    case viewing
    case updating
    case inserting
}

enum EntryLocationStatus {
    case notDetermined
    case unknown
    case set
}

class EntryDetailController: UITableViewController, UINavigationControllerDelegate {
    
    var entryStatus: EntryStatus = .inserting
    var entryLocationStatus: EntryLocationStatus = .notDetermined
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
    
    let locationManager = LocationManager()
    let geocoder = CLGeocoder()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var entryTextField: UITextView!
    @IBOutlet weak var locationActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var actionBarButtonItem: UIBarButtonItem!
    @IBOutlet var imageViewGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var locationLabelGestureRecognizer: UITapGestureRecognizer!
    
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
    
    @IBAction func addLocation(_ sender: Any) {
        if self.entryLocationStatus != .set {
            self.locationActivityIndicator.startAnimating()
            self.locationLabel.isUserInteractionEnabled = false
            self.locationLabel.isHidden = true
            self.locationManager.requestLocation()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.determineLocationPermissionsAndUpdateView()
        
        if let entry = self.entry {
            
            if let imageData = entry.image {
                self.imageView.image = UIImage(data: imageData as Data)
            }
            
            if let location = entry.location {
                self.entryLocationStatus = .set
                self.locationLabel.text = location
            }
            
            self.titleLabel.text = entry.name
            self.entryTextField.text = entry.text
        }
        
        if self.entryStatus == .viewing {
            self.setMode(editing: false)
        }
        
        self.actionBarButtonItem.target = self
        self.actionBarButtonItem.action = #selector(actionButtonPressed(_:))
        
        self.locationManager.manager.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

// MARK: - Helper methods
extension EntryDetailController {
    func actionButtonPressed(_ sender: UIBarButtonItem) {
        switch self.entryStatus {
        case .inserting, .updating: save()
        case .viewing:
            self.entryStatus = .updating
            setMode(editing: true)
        }
    }
    
    func setMode(editing editable: Bool) {
        if !editable {
            self.actionBarButtonItem.title = "Edit"
            
            if self.entryLocationStatus != .set {
                self.locationLabel.text = "Location not provided"
            }
        } else {
            self.actionBarButtonItem.title = "Save"
            if self.entryLocationStatus != .set {
                determineLocationPermissionsAndUpdateView()
            }
        }
        
        self.titleLabel.isUserInteractionEnabled = editable
        self.entryTextField.isEditable = editable
        self.imageViewGestureRecognizer.isEnabled = editable
    }
    
    func determineLocationPermissionsAndUpdateView() {
        if self.entryStatus != .viewing {
            let isLocationServicesAuthorized = self.locationManager.authorizationStatus == .authorizedAlways ||
                self.locationManager.authorizationStatus == .authorizedWhenInUse
            
            self.locationLabel.isEnabled = isLocationServicesAuthorized
            self.locationLabelGestureRecognizer.isEnabled = isLocationServicesAuthorized
            
            if self.entryLocationStatus != .set {
                if isLocationServicesAuthorized {
                    self.locationLabel.text = "Tap to add location"
                } else {
                    self.locationLabel.text = "Location services not avaliable"
                }
            }
        }
    }
    
    func save() {
        if self.entry == nil {
            self.entry = Entry(context: EntryStore.sharedInstance.viewContext)
        }
        
        guard let entry = self.entry else {
            fatalError("No entry object avaliable!")
        }
        
        entry.name = titleLabel.text
        entry.text = entryTextField.text
        
        if self.entryLocationStatus == .set {
            entry.location = locationLabel.text
        }
        
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
        case .viewing:
            fatalError("You're viewing, you're not supposed to be here.")
        }
        
        if let dataError = dataError {
            AlertHelper.showAlert(withMessage: dataError.localizedDescription, presentingViewController: self)
            return
        }
        
        self.navigationController?.popViewController(animated: true)
    }
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
        
        self.imageView.image = self.entryImage
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

// MARK: - Core Location Manager Delegate and Location Helpers
extension EntryDetailController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationManager.authorizationStatus = status
        self.determineLocationPermissionsAndUpdateView()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        AlertHelper.showAlert(withMessage: error.localizedDescription, presentingViewController: self)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.reverse(location: location, withGeocoder: self.geocoder) { placemarkString, locationStatus, error in
                self.entryLocationStatus = locationStatus
                
                if let error = error {
                    AlertHelper.showAlert(withMessage: error.localizedDescription, presentingViewController: self)
                    return
                }
                
                if let placemarkString = placemarkString {
                    self.locationActivityIndicator.stopAnimating()
                    self.locationLabel.text = placemarkString
                    self.locationLabel.isHidden = false
                }
            }
        } else {
            AlertHelper.showAlert(withMessage: "Location services not available.", presentingViewController: self)
        }
    }
    
    func reverse(location: CLLocation, withGeocoder geocoder: CLGeocoder, completion: @escaping (String?, EntryLocationStatus, Error?) -> Void) {
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                completion(nil, .notDetermined, error)
            }
            
            guard let placemarks = placemarks else {
                fatalError("No placemarks yet no error")
            }
            
            if let placemark = placemarks.first  {
                guard let city = placemark.locality, let state = placemark.administrativeArea else {
                    completion("Location unknown.", .unknown, nil)
                    return
                }
                
                let placemarkString = "\(city), \(state)"
                completion(placemarkString, .set, nil)
            }
        }
    }
}
