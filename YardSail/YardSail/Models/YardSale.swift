//
//  YardSale.swift
//  YardSail
//
//  Created by Matthew Piasecki on 3/5/19.
//  Copyright © 2019 Matthew Piasecki. All rights reserved.
//

import Foundation
import Firebase

class YardSale {
    
    var title: String
    var location: String
    var date: String
    var time: String
    var desc: String
    var pricing: String
    var image: String
    let ref: DatabaseReference?
    
    
    init(title: String, location: String, date: String, time: String, desc: String, pricing: String, image: String) {
        self.title = title
        self.location = location
        self.date = date
        self.time = time
        self.desc = desc
        self.pricing = pricing
        self.image = image
        ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        let snapvalues = snapshot.value as! [String : AnyObject]
        self.title = snapvalues["title"] as! String
        //print("snapvalues: \(snapvalues)")
        self.location = snapvalues["location"] as! String
        self.date = snapvalues["date"] as! String
        self.time = snapvalues["time"] as! String
        self.pricing = snapvalues["pricing"] as! String
        self.desc = snapvalues["desc"] as! String
        self.image = snapvalues["image"] as! String
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "title" : title,
            "location" : location,
            "date" : date,
            "time" : time,
            "pricing" : pricing,
            "desc" : desc,
            "image" : image
        ]
    }
}
