//
//  EditSaleViewController.swift
//  YardSail
//
//  Created by Matthew Piasecki on 3/12/19.
//  Copyright © 2019 Matthew Piasecki. All rights reserved.
//

import UIKit
import os.log
import Firebase
import FirebaseUI
import SwiftValidator

class EditSaleViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ValidationDelegate {
    
    @IBOutlet weak var titleLabel: UITextField!
    private var titlePicker: UIPickerView?
    private let titleValues: NSArray = ["Yard Sale","Garage Sale","Estate Sale"]
    @IBOutlet weak var locationLabel: UITextField!
    @IBOutlet weak var priceLabel: UITextField!
    private var pricePicker: UIPickerView?
    private let pickerValues: NSArray = ["$","$$","$$$","$$$$"]
    @IBOutlet weak var dateLabel: UITextField!
    private var datePicker: UIDatePicker?
    @IBOutlet weak var timeLabel: UITextField!
    private var timePicker: UIDatePicker?
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var uploadWheel: UIActivityIndicatorView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var imageURL: String!
    let validator = Validator()
    var sale: YardSale?
    override func viewDidLoad() {
        super.viewDidLoad()
        let toolBar = UIToolbar().ToolbarPiker(mySelect: #selector(EditSaleViewController.dismissPicker))
        titlePicker = UIPickerView()
        titlePicker?.delegate = self
        titlePicker?.dataSource = self
        titleLabel.inputView = titlePicker
        titleLabel.inputAccessoryView = toolBar
        pricePicker = UIPickerView()
        pricePicker?.delegate = self
        pricePicker?.dataSource = self
        priceLabel.inputView = pricePicker
        priceLabel.inputAccessoryView = toolBar
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(AddSaleViewController.dateChanged(datePicker:)), for: .valueChanged)
        dateLabel.inputView = datePicker
        dateLabel.inputAccessoryView = toolBar
        timePicker = UIDatePicker()
        timePicker?.addTarget(self, action: #selector(AddSaleViewController.timeChanged(timePicker:)), for: .valueChanged)
        timePicker?.datePickerMode = .time
        timePicker?.minuteInterval = 10
        timeLabel.inputView = timePicker
        timeLabel.inputAccessoryView = toolBar
        descriptionLabel.inputAccessoryView = toolBar
        titleLabel.text = sale?.title
        locationLabel.text = sale?.location
        priceLabel.text = sale?.pricing
        dateLabel.text = sale?.date
        timeLabel.text = sale?.time
        descriptionLabel.text = sale?.desc
        
        let imageDownloadUrl = sale!.image
        self.imageURL = imageDownloadUrl
        let imageStorageRef = (imageStorage?.storage.reference(forURL: imageDownloadUrl))!
        let placeholderImage = UIImage(named: "loading")
        self.image.sd_setImage(with: imageStorageRef, placeholderImage: placeholderImage)
        
        titleLabel.delegate = self
        locationLabel.delegate = self
        priceLabel.delegate = self
        dateLabel.delegate = self
        timeLabel.delegate = self
        descriptionLabel.delegate = self
        image.isUserInteractionEnabled = true
        
        // Validation Rules are evaluated from left to right.
        validator.registerField(titleLabel, rules: [RequiredRule()])
        validator.registerField(locationLabel, rules: [RequiredRule()])
        validator.registerField(dateLabel, rules: [RequiredRule()])
        validator.registerField(timeLabel, rules: [RequiredRule()])
        validator.registerField(priceLabel, rules: [RequiredRule()])
        validator.registerField(descriptionLabel, rules: [RequiredRule()])
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
            titleLabel.text = title
        } else if pickerView == pricePicker {
            let price = pickerValues[row] as? String
            priceLabel.text = price
        }
    }
    
    @objc func dismissPicker(){
        self.view.endEditing(true)
    }
    
    @objc func dateChanged(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateLabel.text = dateFormatter.string(from: datePicker.date)
    }
    
    @objc func timeChanged(timePicker: UIDatePicker){
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        timeLabel.text = timeFormatter.string(from: timePicker.date)
    }
    
    // ValidationDelegate methods
    func validationSuccessful() {
        performSegue(withIdentifier: "unwindFromEditSaleVC", sender: self)
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
    
    // MARK: - Text Field Delagate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
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
        saveButton.isEnabled = false
        image.isOpaque = true
        uploadWheel.isHidden = false
        uploadWheel.startAnimating()
        guard let imageData = image.image?.jpegData(compressionQuality: 0.5) else {
            fatalError("Error translating image into png data form")
        }
        let user = Auth.auth().currentUser?.uid
        let title = titleLabel.text!
        let a = title+"_"+user!+"_"
        let date = dateLabel.text!
        let time = timeLabel.text!
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
                self.uploadWheel.stopAnimating()
                self.uploadWheel.isHidden = true
                self.image.isOpaque = false
                self.saveButton.isEnabled = true
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
    
    @IBAction func deleteTapped(_ sender: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Deleting Sale", message: "Are you sure you want to delete this sale?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
            let bailedSale = self.sale
            let title = bailedSale!.title
            let loc = bailedSale!.location.replacingOccurrences(of: ".", with: "")
            let user = Auth.auth().currentUser?.uid
            let path = title+"-"+loc+"_"+user!
            let salesDb = Database.database().reference(withPath: "Public/"+path)
            salesDb.ref.removeValue()
            bailedSale?.ref?.removeValue()
            self.dismiss(animated: true, completion: nil)
            print("User click Delete button")
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
            print("User click Dismiss button")
        }))
        self.present(alert, animated: true, completion: {
            print("Delete completion block:")
        })
    }
    
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        validator.validate(self)
    }
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as? HomeViewController
        let initSale = self.sale
        sale?.title = (titleLabel?.text!)!
        sale?.location = locationLabel.text!
        sale?.pricing = priceLabel.text!
        sale?.date = dateLabel.text!
        sale?.time = timeLabel.text!
        sale?.desc = descriptionLabel.text!
        sale?.image = self.imageURL
        initSale?.ref?.removeValue()
        destVC?.addSale(newSale: sale!)
        destVC?.addProfileSale(newSale: sale!)
    }
    
}
