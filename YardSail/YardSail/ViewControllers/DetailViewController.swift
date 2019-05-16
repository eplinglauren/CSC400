//
//  DetailViewController.swift
//  YardSail
//
//  Created by Matthew Piasecki on 3/5/19.
//  Copyright © 2019 Matthew Piasecki. All rights reserved.
//

import UIKit
import EventKit
import Firebase
import FirebaseUI

class DetailViewController: UIViewController {
    @IBOutlet weak var passedTitleLabel: UILabel!
    @IBOutlet weak var passedLocationLabel: UILabel!
    @IBOutlet weak var passedPriceLabel: UILabel!
    @IBOutlet weak var passedDateLabel: UILabel!
    @IBOutlet weak var passedTimeLabel: UILabel!
    @IBOutlet weak var passedDescLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var svdLabel: UILabel!
    
    
    var dataFromTable : YardSale?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navBar.title = dataFromTable?.title
        passedTitleLabel.text = dataFromTable?.title
        passedLocationLabel.text = dataFromTable?.location
        passedDateLabel.text = dataFromTable?.date
        passedTimeLabel.text = dataFromTable?.time
        passedPriceLabel.text = dataFromTable?.pricing
        passedDescLabel.text = dataFromTable?.desc
        
        let imageDownloadUrl = (dataFromTable?.image)!
        let imageStorageRef = (imageStorage?.storage.reference(forURL: imageDownloadUrl))!
        let placeholderImage = UIImage(named: "loading")
        self.image.sd_setImage(with: imageStorageRef, placeholderImage: placeholderImage)
    }
    
    func insertEvent(store: EKEventStore) {
        // 1
        let calendars = store.calendars(for: .event)
        let user = Auth.auth().currentUser?.email
        
        
        for calendar in calendars {
            // 2
            if calendar.title == "YardSail" {
                // 3
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/YY"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                let startDate = dateFormatter.date(from: dataFromTable!.date)
                // 2 hours
                let endDate = startDate!.addingTimeInterval(4 * 60 * 60)
                
                // 4
                let event = EKEvent(eventStore: store)
                event.calendar = calendar
                let title = passedTitleLabel.text! + user!
                event.title = title
                event.startDate = startDate
                event.endDate = endDate
                
                // 5
                do {
                    try store.save(event, span: .thisEvent)
                }
                catch {
                    print("Error saving event in calendar")             }
            }
        }
    }
    
    @IBAction func doneClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func messageClicked(_ sender: UIButton) {
        if msgLabel.isHidden {
            msgLabel.text = "Message action triggered"
            msgLabel.isHidden = false
        } else {
            msgLabel.isHidden = true
        }
    }
    
    @IBAction func heartClicked(_ sender: UIButton) {
        if svdLabel.isHidden {
            svdLabel.text = "Save action triggered"
            svdLabel.isHidden = false
        } else {
            svdLabel.isHidden = true
        }
        
//        let eventStore = EKEventStore()
//        
//        // 2
//        switch EKEventStore.authorizationStatus(for: .event) {
//        case .authorized:
//            insertEvent(store: eventStore)
//        case .denied:
//            print("Access denied")
//        case .notDetermined:
//            // 3
//            eventStore.requestAccess(to: .event, completion:
//                {[weak self] (granted: Bool, error: Error?) -> Void in
//                    if granted {
//                        self!.insertEvent(store: eventStore)
//                    } else {
//                        print("Access denied")
//                    }
//            })
//        default:
//            print("Case default")
//        }
    }
}
