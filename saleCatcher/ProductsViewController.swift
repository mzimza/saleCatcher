//
//  ProductsViewController.swift
//  saleCatcher
//
//  Created by Maja Zalewska on 01/08/16.
//  Copyright © 2016 Maja Zalewska. All rights reserved.
//

import Foundation
import UIKit

class ProductsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ProductsTableViewCellDelegate {
    
    var isOnline = true//false //markup for checking if data is loading properly
    var products = [Int32: Product]()//= []
    var selected: [Product] = []//Set<Product>()
    let tableView = UITableView()
    var refreshControl = UIRefreshControl()
    
    override func viewDidAppear(_ animated: Bool) {
            showRefreshControl(true)
            refresh(self.refreshControl)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
   
        refreshControl.addTarget(self, action: #selector(ProductsViewController.refresh(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl) //kółeczko ładowania
        
        tableView.register(ProductsTableViewCell.self, forCellReuseIdentifier: "aCell")
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
        let cell = ProductsTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "aCell")
        let item = products[Int32((indexPath as NSIndexPath).row)]
       // cell.textLabel?.text = item.displayInfo()
        if item!.isOnSale() {
            cell.label.textColor = UIColor.red
        }
        cell.selectionStyle = .none
        cell.delegate = self
        cell.product = item
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
// MARK: TableView Delegate
    
    // adds selected product to the observerd list
    func productSelected(_ product: Product) {
      //  let index = (products as NSArray).indexOfObject(product)
      //  if index == NSNotFound { return }
      //  print("w products po zaznaczeniu", products[index].selected)
        print("product to select:", product, "czy jest:", selected.contains(product))
        //product.selected = true
        if !selected.contains(product) {
            selected.append(product)
            saveProducts()
            saveSelectedProducts()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        //    cell.backgroundColor = colorForIndex(indexPath.row)
    }
    
    func refresh(_ refreshControl: UIRefreshControl) {
        // Do your job, when done:
        if self.isOnline {
            Crawler().crawl({
                prods in
                self.products = self.arrayToMap(prods)
                self.selected = self.loadSelectedProducts()!
                OperationQueue.main.addOperation({
                    self.tableView.reloadData()
                    if self.refreshControl.isRefreshing {
                        self.refreshControl.endRefreshing()
                    }
                })
            })
            saveProducts()
            updateSelected()
            //self.isOnline = false
        } else {
            self.products = loadProducts()!
            self.selected = loadSelectedProducts()!
            for (index, prod) in products.enumerated() {
                if prod.1.selected {
                    print("SELECTED!: ", prod.1.id, index)
                }
            }
            OperationQueue.main.addOperation({
                self.tableView.reloadData()
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
            })
            print("Data loaded", products.count)
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
    
    
    func arrayToMap(_ prods: [Product]) -> [Int32: Product] {
        var tmp = [Int32: Product]()
        for item in prods {
            let id = item.id
            tmp[id] = item
        }
        return tmp
    }
    
    
// MARK: NSCoding
    func saveProducts() {
        let toSave = Array(products.values)
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(toSave, toFile: Product.ArchiveURLAll.path)
        if !isSuccessfulSave {
            print("Failed to save all products...")
        }
    }
    
    func saveSelectedProducts() {
        print("zapisuje", selected.count)
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(selected, toFile: Product.ArchiveURLSelected.path)
        if !isSuccessfulSave {
            print("Failed to save selected products...")
        }
    }
    
    func loadProducts() -> [Int32: Product]? {
        let saved = NSKeyedUnarchiver.unarchiveObject(withFile: Product.ArchiveURLAll.path) as?[Product]
        var tmp = [Int32: Product]()
        for item in saved! {
            let id = item.id
            tmp[id] = item
        }
        return tmp
    }
    
    func loadSelectedProducts() -> [Product]? {//Set<Product>? {
        
        let saved = NSKeyedUnarchiver.unarchiveObject(withFile: Product.ArchiveURLSelected.path) as? [Product]//Set<Product>
        saved?.forEach{ item in
            //let index = (products as NSArray).indexOfObject(item)
            //if index == NSNotFound { print("Saved selected item not found..."); return }
            products[item.id]!.selected = true
            print("w products po zaznaczeniu", products[item.id]!.selected)
        }
        return saved != nil ? saved! : []//Set<Product>())
        
    }
    
    func updateSelected() {
        for item in self.selected {
            item.priceOnSale = (self.products[item.id]?.priceOnSale)!
        }
        saveSelectedProducts()
    }
    
    // background fetch
    func fetch(completion: () -> Void) {
        print("fetch")
        completion()
    }

}
