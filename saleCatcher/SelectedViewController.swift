//
//  SelectedViewController.swift
//  saleCatcher
//
//  Created by Maja Zalewska on 11/08/16.
//  Copyright © 2016 Maja Zalewska. All rights reserved.
//

/*
 w widoku selected można:
 - usunąć z obserwowanych
 w widoku products można:
 - dodać do obserwowanych
 - przeglądać i wyszukiwać produkty
 
 */
 

import Foundation
import UIKit
import UserNotifications

class SelectedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SelectedTableViewCellDelegate {
    
    var isOnline = false //markup for checking if data is loading properly
    var selected : [Product] = []
    var products : [Product]? = nil
    var currentlyOnSale : [Product] = []
    let tableView = UITableView()
    var refreshControl = UIRefreshControl()
    
    override func viewDidAppear(_ animated: Bool) {
        showRefreshControl(true)
        refresh(self.refreshControl)
        print("refresh")
        notify()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        refreshControl.addTarget(self, action: #selector(ProductsViewController.refresh(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl) //kółeczko ładowania
        
        tableView.register(SelectedTableViewCell.self, forCellReuseIdentifier: "aCell")
        self.tableView.dataSource = self // przekazuje dane do ui
        self.tableView.delegate = self // odbiera komunikaty od ui
        
        //self.tableView.backgroundColor = UIColor.blueColor()
        self.tableView.frame = self.view.bounds
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 64, 0); // set the upper bound under the status bar, 64 for navigation bar
        
        self.tableView.separatorStyle = .none
        self.tableView.rowHeight = 50.0
        
        self.view.addSubview(tableView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: TableView DataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SelectedTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "aCell")
        let item = selected[(indexPath as NSIndexPath).row]
        // cell.textLabel?.text = item.displayInfo()
        if item.isOnSale() {
            cell.label.textColor = UIColor.green
        }
        cell.selectionStyle = .none
        cell.delegate = self
        cell.product = item
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selected.count
    }
    
    // MARK: TableView Delegate
    
    func productDeleted(_ product: Product) {
        let index = (selected as NSArray).index(of: product)
        if index == NSNotFound { return }
        
        // could removeAtIndex in the loop but keep it here for when indexOfObject works
        print("w products po usunieciu", selected[index].selected)
        selected.remove(at: index)
        saveSelectedProducts()
        // use the UITableView to animate the removal of this row
        tableView.beginUpdates()
        let indexPathForRow = IndexPath(row: index, section: 0)
        tableView.deleteRows(at: [indexPathForRow], with: .fade)
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        //    cell.backgroundColor = colorForIndex(indexPath.row)
    }
    
    func refresh(_ refreshControl: UIRefreshControl) {
        // Do your job, when done:
        if self.isOnline {
        } else {
            print("refresh selected")
            if let selected = loadSelectedProducts() {
                self.selected = selected
                self.currentlyOnSale = []
                for item in self.selected {
                    if item.isOnSale() {
                        currentlyOnSale.append(item)
                    }
                }
                print(self.selected)
                OperationQueue.main.addOperation({
                    self.tableView.reloadData()
                    if self.refreshControl.isRefreshing {
                        self.refreshControl.endRefreshing()
                    }
                })
                print("Selected loaded from file", selected.count)
            }
            else {
                print("ni ma nic")
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    func showRefreshControl(_ show: Bool) {
        if show {
            self.refreshControl.beginRefreshing()
            tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
        } else {
            self.refreshControl.endRefreshing()
        }
    }
    
    // MARK: NSCoding
    func saveProducts() {
        print("Saving...")
        for prod in products! {
            if prod.selected {
                print("SELECTED!: ", prod.displayInfo())
            }
        }
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(products!, toFile: Product.ArchiveURLAll.path)
        if !isSuccessfulSave {
            print("Failed to save all products...")
        }
    }
    
    func loadProducts() -> [Product]? {
        let saved = NSKeyedUnarchiver.unarchiveObject(withFile: Product.ArchiveURLAll.path) as? [Product]
        return saved != nil ? saved! : []
    }
    
    func saveSelectedProducts() {
        print("selected save", selected.count)
    //    let toSave = Set<Product>(selected)
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(selected, toFile: Product.ArchiveURLSelected.path)
        if !isSuccessfulSave {
            print("Failed to save selected products...")
        }
    }
    
    
    func loadSelectedProducts() -> [Product]? {
        let saved = NSKeyedUnarchiver.unarchiveObject(withFile: Product.ArchiveURLSelected.path) as? [Product]//Set<Product>
        print("loadSelectedProducts", saved)
        return saved != nil ? saved! : []
    }
    
    
    //MARK: Notifications
    
    func notify() {
        print("notify")
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "SaleCatcher", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "There are items on sale", arguments: nil)
        content.sound = UNNotificationSound.default()
        content.badge = 0
    
        
        // Fire in 1 minutes (60 seconds), must be >=1min to repeat
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: (60), repeats: false)
        let request = UNNotificationRequest.init(identifier: "notify", content: content, trigger: trigger)
        // Schedule the notification.
        let center = UNUserNotificationCenter.current()
        center.add(request)
    }
}
