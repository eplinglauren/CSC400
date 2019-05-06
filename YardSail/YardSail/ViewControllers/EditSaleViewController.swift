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

class EditSaleViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var titleLabel: UITextField!
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
    var imageURL: String!
    
    var sale: YardSale?
    override func viewDidLoad() {
        super.viewDidLoad()
        let toolBar = UIToolbar().ToolbarPiker(mySelect: #selector(EditSaleViewController.dismissPicker))
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
        let imageStorageRef = imageStorage?.storage.reference(forURL: imageDownloadUrl)
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        imageStorageRef?.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if error != nil {
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/---.png" is returned
                let img = UIImage(data: data!)
                self.image.image = img
            }
        }
        
        titleLabel.delegate = self
        locationLabel.delegate = self
        priceLabel.delegate = self
        dateLabel.delegate = self
        timeLabel.delegate = self
        descriptionLabel.delegate = self
        image.isUserInteractionEnabled = true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerValues[row] as? String
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let price = pickerValues[row] as? String
        priceLabel.text = price
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
            print("Logout completion block:")
        })
    }
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as? HomeViewController
        sale?.title = (titleLabel?.text!)!
        sale?.location = locationLabel.text!
        sale?.pricing = priceLabel.text!
        sale?.date = dateLabel.text!
        sale?.time = timeLabel.text!
        sale?.desc = descriptionLabel.text!
        sale?.image = self.imageURL
        destVC?.addProfileSale(newSale: sale!)
    }
    
}
