//
//  ThirdViewController.swift
//  YardSail
//
//  Created by Matthew Piasecki on 3/3/19.
//  Copyright © 2019 Matthew Piasecki. All rights reserved.
//

import UIKit
import Firebase

var profileSales = [YardSale]()
class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var database: DatabaseReference?

    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var listingsLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    var dateFormatter = DateFormatter()
    
    @IBOutlet weak var profileTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.profileTableView.delegate = self
        self.profileTableView.dataSource = self
        profileTableView.layoutMargins = UIEdgeInsets.zero
        profileTableView.separatorInset = UIEdgeInsets.zero
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil {
                let email = user?.email ?? ""
                self.nameLabel.text = "Logged in as: "+email
            }
        }
        let userId = Auth.auth().currentUser?.uid
        let profilePath = "Profiles/"+userId!
        database = Database.database().reference(withPath: profilePath)
        database?.keepSynced(true)
        setRetrieveCallback()
    }
    
    
    func setRetrieveCallback() {
        let user = Auth.auth().currentUser?.uid
        database?.queryOrdered(byChild: user!).observe(.value, with:
            { snapshot in
                
                var newSales = [YardSale]()
                
                for item in snapshot.children {
                    newSales.append(YardSale(snapshot: item as! DataSnapshot))
                }
                profileSales = newSales
                self.profileTableView.reloadData()
        })
    }
    
    @IBAction func logoutClicked(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to log out?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { (_) in
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            self.performSegue(withIdentifier: "unwindToLoginVC", sender: self)
            print("User click Logout button")
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
            print("User click Dismiss button")
        }))
        self.present(alert, animated: true, completion: {
            print("Logout completion block:")
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88.0;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileSales.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as? CustomTableViewCell
        cell?.layoutMargins = UIEdgeInsets.zero
        // Configure the cell...
        let thisSale = profileSales[indexPath.row]
        cell?.titleLabel?.text = thisSale.title
        cell?.locationLabel?.text = thisSale.location
        cell?.dateLabel?.text = thisSale.date
        cell?.timeLabel?.text = thisSale.time
        cell?.priceLabel?.text = thisSale.pricing
        cell?.descLabel?.text = thisSale.desc
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected row: \(indexPath.row)")
        performSegue(withIdentifier: "showSelectedProfileSale", sender: indexPath.row)
    }
    
    // Enable row editing in order to enable 'Slide to Delete'
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // This is what should happen when we slide a row
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let bailedSale = profileSales[indexPath.row]
            let title = bailedSale.title
            let loc = bailedSale.location.replacingOccurrences(of: ".", with: "")
            let user = Auth.auth().currentUser?.uid
            let path = title+"-"+loc+"_"+user!
            let salesDb = Database.database().reference(withPath: "Public/"+path)
            salesDb.ref.removeValue()
            bailedSale.ref?.removeValue()
            profileSales.remove(at: indexPath.row)
            profileTableView.deleteRows(at: [indexPath], with: .fade)
            profileTableView.reloadData()
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSelectedProfileSale" {
            print("Editing an existing sale")
            // There are two segues to cross (look at the storyboard)
            let navC = segue.destination as? UINavigationController
            let destVC = navC?.topViewController as? EditSaleViewController
            let selectedIndexPath = profileTableView.indexPathForSelectedRow
            let currentSale: YardSale
            currentSale = profileSales[(selectedIndexPath?.row)!]
            destVC?.sale = currentSale
        }
    }
    
}

