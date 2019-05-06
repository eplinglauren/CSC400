//
//  FirstViewController.swift
//  YardSail
//
//  Created by Matthew Piasecki on 3/3/19.
//  Copyright © 2019 Matthew Piasecki. All rights reserved.
//

import UIKit
import Firebase

var imageStorage : StorageReference?
class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    var database : DatabaseReference?
    var profileDatabase : DatabaseReference?
    
    var ourSales = [YardSale]()
    var filteredSales = [YardSale]()
    private let refreshControl = UIRefreshControl()
    private let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var salesTV: UITableView!
    var dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imageStorage = Storage.storage().reference(withPath: "Images")
        database = Database.database().reference(withPath: "Public")
        profileDatabase = Database.database().reference(withPath: "Profiles")
        database!.keepSynced(true)
        profileDatabase!.keepSynced(true)
        setRetrieveCallback()
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            salesTV.refreshControl = refreshControl
        } else {
            salesTV.addSubview(refreshControl)
        }
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshStorage(_:)), for: .valueChanged)
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        // Configure Search Bar
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Sales"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = ["All", "Yard", "Garage", "Estate"]
        searchController.searchBar.delegate = self
    }
    
    func setRetrieveCallback() {
        database?.queryOrdered(byChild: "Public").observe(.value, with:
            { snapshot in
                
                var newSales = [YardSale]()
                
                for item in snapshot.children {
                    newSales.append(YardSale(snapshot: item as! DataSnapshot))
                }
                self.ourSales = newSales
                self.salesTV.reloadData()
        })
    }
    
    func addSale(newSale : YardSale) {
        ourSales.append(newSale)

        // add to Firebase
        let title = newSale.title
        let loc = newSale.location.replacingOccurrences(of: ".", with: "")
        let uid = Auth.auth().currentUser?.uid
        let newSaleRef = database?.child(title+"-"+loc+"_"+uid!)
        newSaleRef?.setValue(newSale.toAnyObject())
    }
    
    func addProfileSale(newSale : YardSale) {
        profileSales.append(newSale)
        
        // add to Firebase
        let user = Auth.auth().currentUser?.uid
        let title = newSale.title
        let newSaleRef = profileDatabase?.child(user!+"/"+title)
        newSaleRef?.setValue(newSale.toAnyObject())
    }
    
    @objc private func refreshStorage(_ sender: Any) {
        self.refreshControl.endRefreshing()
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredSales = ourSales.filter({( yardsale : YardSale) -> Bool in
            let doesCategoryMatch = (scope == "All") || (yardsale.title.contains(scope))
            if searchBarIsEmpty() {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && yardsale.desc.lowercased().contains(searchText.lowercased())
            }
        })
        salesTV.reloadData()
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    // TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredSales.count
        }
        return ourSales.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88.0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as? CustomTableViewCell
        
        // Configure the cell...
        let thisSale: YardSale
        if isFiltering() {
            thisSale = filteredSales[indexPath.row]
        } else {
            thisSale = ourSales[indexPath.row]
        }
        cell?.titleLabel?.text = thisSale.title
        cell?.locationLabel?.text = thisSale.location
        cell?.dateLabel?.text = thisSale.date
        cell?.timeLabel?.text = thisSale.time
        cell?.priceLabel?.text = thisSale.pricing
        cell?.descLabel?.text = thisSale.desc
        
        let imageDownloadUrl = thisSale.image
        let imageStorageRef = imageStorage?.storage.reference(forURL: imageDownloadUrl)
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        imageStorageRef?.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if error != nil {
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/---.png" is returned
                let img = UIImage(data: data!)
                cell?.photo.image = img
            }
        }
        return cell!
        //because return type is defined as non-optional UITableViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected row: \(indexPath.row)")
        performSegue(withIdentifier: "showSelectedSale", sender: indexPath.row)
    }
    
    // Enable row editing in order to enable 'Slide to Delete'
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // This is what should happen when we slide a row
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let bailedSale = ourSales[indexPath.row]
            bailedSale.ref?.removeValue()
            ourSales.remove(at: indexPath.row)
            salesTV.deleteRows(at: [indexPath], with: .fade)
            salesTV.reloadData()
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        // Switch on the segue's ID
        switch(segue.identifier ?? "") {
        case "showSelectedSale":
            print("Showing a sale")
            let destVC = segue.destination as? DetailViewController
            let selectedIndexPath = salesTV.indexPathForSelectedRow
            let currentSale: YardSale
            if isFiltering() {
                currentSale = filteredSales[(selectedIndexPath?.row)!]
            } else {
                currentSale = ourSales[(selectedIndexPath?.row)!]
            }
            destVC?.dataFromTable = currentSale
        case "AddSale":
            print("Adding a new sale")
        case "showProfile":
            print("Displaying profile")
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier!)")
        }
    }
    
    // MARK: - Actions
    @IBAction func unwindFromProfileVC(sender: UIStoryboardSegue){
        print("Return to Home View")
    }
    
    @IBAction func unwindFromDetail(segue:UIStoryboardSegue){
        print("Unwind to Home View")
    }
    
    @IBAction func unwindFromAddSaleVC(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? AddSaleViewController , let sale = sourceViewController.sale {
            ourSales.append(sale)
            salesTV.reloadData()
        }
    }
    
    @IBAction func unwindFromEditSaleVC(sender: UIStoryboardSegue) {
        salesTV.reloadData()
    }


}

extension HomeViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}

extension HomeViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}



