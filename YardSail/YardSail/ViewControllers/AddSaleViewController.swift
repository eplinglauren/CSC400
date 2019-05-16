//
//  AddSaleViewController.swift
//  YardSail
//
//  Created by Matthew Piasecki on 3/12/19.
//  Copyright © 2019 Matthew Piasecki. All rights reserved.
//

import UIKit
import SwiftValidator
import Photos
import os.log
import Firebase
import GooglePlaces

class AddSaleViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ValidationDelegate {
    
    var sale: YardSale?
    var placesClient: GMSPlacesClient!
    @IBOutlet weak var titleField: UITextField!
    private var titlePicker: UIPickerView?
    private let titleValues: NSArray = ["Yard Sale","Garage Sale","Estate Sale"]
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var image: UIImageView!
    private var pricePicker: UIPickerView?
    private let pickerValues: NSArray = ["$","$$","$$$","$$$$"]
    @IBOutlet weak var dateField: UITextField!
    private var datePicker: UIDatePicker?
    @IBOutlet weak var timeField: UITextField!
    private var timePicker: UIDatePicker?
    @IBOutlet weak var descriptionField: UITextView!
    
    let validator = Validator()
    let locationManager = CLLocationManager()
    var imageURL: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placesClient = GMSPlacesClient.shared()
        let toolBar = UIToolbar().ToolbarPiker(mySelect: #selector(AddSaleViewController.dismissPicker))
        titlePicker = UIPickerView()
        titlePicker?.delegate = self
        titlePicker?.dataSource = self
        titleField.inputView = titlePicker
        titleField.inputAccessoryView = toolBar
        locationField.inputAccessoryView = toolBar
        pricePicker = UIPickerView()
        pricePicker?.delegate = self
        pricePicker?.dataSource = self
        priceField.inputView = pricePicker
        priceField.inputAccessoryView = toolBar
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(AddSaleViewController.dateChanged(datePicker:)), for: .valueChanged)
        dateField.inputView = datePicker
        dateField.inputAccessoryView = toolBar
        timePicker = UIDatePicker()
        timePicker?.addTarget(self, action: #selector(AddSaleViewController.timeChanged(timePicker:)), for: .valueChanged)
        timePicker?.datePickerMode = .time
        timePicker?.minuteInterval = 10
        timeField.inputView = timePicker
        timeField.inputAccessoryView = toolBar
        descriptionField.inputAccessoryView = toolBar
        titleField.text = ""
        enableLocationServices()
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Current Place error: \(error.localizedDescription)")
                return
            }
            
            self.locationField.text = "No current place"
            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    self.locationField.text = place.name
                    //self.locationField.text = place.formattedAddress?.components(separatedBy: ", ")
                    //    .joined(separator: "\n")
                }
            }
        })
        descriptionField.text = ""
        priceField.text = ""
        dateField.text = ""
        timeField.text = ""
        titleField.delegate = self
        locationField.delegate = self
        descriptionField.delegate = self
        priceField.delegate = self
        dateField.delegate = self
        timeField.delegate = self
        
        image.isUserInteractionEnabled = true
        
        // Validation Rules are evaluated from left to right.
        validator.registerField(titleField, rules: [RequiredRule()])
        validator.registerField(locationField, rules: [RequiredRule()])
        validator.registerField(dateField, rules: [RequiredRule()])
        validator.registerField(timeField, rules: [RequiredRule()])
        validator.registerField(priceField, rules: [RequiredRule()])
        validator.registerField(descriptionField, rules: [RequiredRule()])
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == titlePicker {
            return titleValues.count
        } else if pickerView == pricePicker {
            return pickerValues.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == titlePicker {
            return titleValues[row] as? String
        } else if pickerView == pricePicker {
            return pickerValues[row] as? String
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == titlePicker {
            let title = titleValues[row] as? String
            titleField.text = title
        } else if pickerView == pricePicker {
            let price = pickerValues[row] as? String
            priceField.text = price
        }
    }
    
    @objc func dismissPicker(){
        self.view.endEditing(true)
    }
    
    @objc func dateChanged(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateField.text = dateFormatter.string(from: datePicker.date)
    }
    
    @objc func timeChanged(timePicker: UIDatePicker){
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        timeField.text = timeFormatter.string(from: timePicker.date)
    }
    
    // MARK: - Text Field Delagate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textViewShouldReturn(_ textView: UITextView) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func enableLocationServices() {
        locationManager.delegate = self as? CLLocationManagerDelegate
        
        if (CLLocationManager.authorizationStatus() == .notDetermined) {
            // Request when-in-use authorization initially
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    // ValidationDelegate methods
    func validationSuccessful() {
        performSegue(withIdentifier: "unwindFromAddSaleVC", sender: self)
    }
    
    func validationFailed(_ errors:[(Validatable ,ValidationError)]) {
        // turn the fields to red
        for (field, error) in errors {
            if let field = field as? UITextField {
                field.layer.borderColor = UIColor.red.cgColor
                field.layer.borderWidth = 2.0
            }
            if let field = field as? UITextView {
                field.layer.borderColor = UIColor.red.cgColor
                field.layer.borderWidth = 2.0
            }
            error.errorLabel?.text = error.errorMessage // works if you added labels
            error.errorLabel?.isHidden = false
        }
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        image.image = selectedImage
        
        guard let imageData = image.image?.jpegData(compressionQuality: 0.5) else {
            fatalError("Error translating image into png data form")
        }
        let user = Auth.auth().currentUser?.uid
        let title = titleField.text!
        let a = title+"_"+user!+"_"
        let date = dateField.text!
        let time = timeField.text!
        let b = date+"_"+time
        let imageName = a+b
        let imagePathRef = imageStorage!.child(imageName)
        //uploadTask
        let _ = imagePathRef.putData(imageData, metadata: nil) { (metadata, error) in
            guard metadata != nil else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type.
            // let size = metadata.size
            // You can also access to download URL after upload.
            imagePathRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                self.imageURL = downloadURL.absoluteURL.absoluteString
            }
        }
        //print("Validated! image url: "+self.imageURL!)
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func photoTapped(_ sender: UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            picker.sourceType = .photoLibrary
        } else {
            picker.sourceType = .camera
        }
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        validator.validate(self)
        
    }
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // Executed with 'Save' is hit
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as? HomeViewController
        let title = titleField.text!
        let loc = locationField.text!
        let date = dateField.text!
        let time = timeField.text!
        let price = priceField.text!
        let desc = descriptionField.text!
        let imgUrl = imageURL
        
        self.sale = YardSale(title: title, location: loc, date: date, time: time, desc: desc, pricing: price, image: imgUrl!)
        destVC?.addSale(newSale: sale!)
        destVC?.addProfileSale(newSale: sale!)
    }
}

extension UIToolbar {

    func ToolbarPiker(mySelect : Selector) -> UIToolbar {
        
        let toolBar = UIToolbar()
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
//        let previousButton = UIBarButtonItem(title: "Prev", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
//        previousButton.width = 30
        
//        let nextButton = UIBarButtonItem(title: "Next", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
//        nextButton.width = 30
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: mySelect)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([ /*previousButton, nextButton,*/ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }
    
}
