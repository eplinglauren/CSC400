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
    @IBOutlet weak var passedDescLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var svdLabel: UILabel!
    
    
    var dataFromTable : YardSale?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let title = (dataFromTable?.title)!
        let price = (dataFromTable?.pricing)!
        let navTitle = title + " ("+price+")"
        let subNavTitle = (dataFromTable?.location)!
        let date = (dataFromTable?.date)!
        let time = (dataFromTable?.time)!
        let subsubNavTitle = date + " " + time
        navBar.setTitle(title: navTitle,subtitle: subNavTitle,subsubtitle: subsubNavTitle)
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
                let title = dataFromTable!.title + user!
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

extension UINavigationItem {
    
    func setTitle(title: String, subtitle: String, subsubtitle: String) {
        let appearance = UINavigationBar.appearance()
        let textColor = appearance.titleTextAttributes?[NSAttributedString.Key.foregroundColor] as? UIColor ?? .black
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: UIFont.TextStyle.headline)
        titleLabel.textColor = textColor
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
        subtitleLabel.textColor = textColor.withAlphaComponent(0.75)
        
        let subsubtitleLabel = UILabel()
        subsubtitleLabel.text = subsubtitle
        subsubtitleLabel.font = .preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
        subsubtitleLabel.textColor = textColor.withAlphaComponent(0.75)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, subsubtitleLabel])
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        stackView.axis = .vertical
        
        self.titleView = stackView
    }
}
