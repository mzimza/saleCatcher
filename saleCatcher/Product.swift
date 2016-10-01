//
//  Product.swift
//  saleCatcher
//
//  Created by Maja Zalewska on 10/08/16.
//  Copyright © 2016 Maja Zalewska. All rights reserved.
//

import Foundation

func ==(lhs: Product, rhs: Product) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

// MARK: Types

struct PropertyKey {
    static let idKey = "id"
    static let producerKey = "producer"
    static let nameKey = "name"
    //static let imageKey = "image"
    static let descKey = "desc"
    static let priceKey = "price"
    static let priceOnSaleKey = "priceOnSale"
    static let selectedKey = "selected"
}

class Product: NSObject, NSCoding {
// MARK: Properties
    var id: Int32
    var producer: String
    var name: String
    var desc: String
    var price: NSDecimalNumber
    var priceOnSale: NSDecimalNumber
    var selected: Bool
    let lengthWhenOnSale = 6
    override var hashValue : Int {
        get {
            return self.id.hashValue
        }
    }

    
// MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURLAll = DocumentsDirectory.appendingPathComponent("products")
    static let ArchiveURLSelected = DocumentsDirectory.appendingPathComponent("productsSelected")

    init(nameString: String, prices: [String], id: Int32) {
       // print("?????\n",nameString,"\n?????")
        let details = nameString.characters.split { $0 == "," }.map(String.init)
       // print("!!!!!!!!!!!!!!!\n",details,"\n!!!!!!!!!!!!!")
     //   print(details[1])
        self.id = id
        self.producer = details[0]
        self.name = details[1]
        self.desc = String(details[details.indices.suffix(from: details.startIndex.advanced(by: 2))].joined(separator: ","))
        //print(prices, prices[1])
        self.price = NSDecimalNumber(string: prices[0].characters.split { $0 == ","}.map(String.init).joined(separator: ""))
        self.priceOnSale = NSDecimalNumber(string: (prices.count > lengthWhenOnSale ? prices[1] : prices[0]).characters.split { $0 == ","}.map(String.init).joined(separator: ""))
        //print("price:", price.decimalNumberByDividingBy(100))
        //print("priceOnSale:", priceOnSale.decimalNumberByDividingBy(100))
        self.selected = false
        super.init()
    }
    
    init(id: Int32, producer: String, name: String, desc: String, price: NSDecimalNumber, priceOnSale: NSDecimalNumber, selected: Bool) {
        self.id = id
        self.producer = producer
        self.name = name
        self.desc = desc
        self.price = price
        self.priceOnSale = priceOnSale
        self.selected = selected
        super.init()
    }
    
    func isOnSale() -> Bool {
        return price != priceOnSale
    }
    
    func priceDifference() -> NSDecimalNumber {
        let diff = price.subtracting(priceOnSale)
        //print (diff, diff.description)
        return diff
    }
    
    func displayInfo() -> String {
        if self.isOnSale() {
            var diff = String(describing: priceDifference())
            diff.insert(",", at: diff.characters.index(diff.endIndex, offsetBy: -2))
            return "-" + diff + "zł! " + producer + "," + desc
        } else {
            return producer + ", " + desc
        }
    }
    
    // MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encodeCInt(id, forKey: PropertyKey.idKey)
        aCoder.encode(producer, forKey: PropertyKey.producerKey)
        aCoder.encode(name, forKey: PropertyKey.nameKey)
  //      aCoder.encodeObject(image, forKey: PropertyKey.imageKey)
        aCoder.encode(desc, forKey: PropertyKey.descKey)
        aCoder.encode(price, forKey: PropertyKey.priceKey)
        aCoder.encode(priceOnSale, forKey: PropertyKey.priceOnSaleKey)
        aCoder.encode(selected, forKey: PropertyKey.selectedKey)
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeCInt(forKey: PropertyKey.idKey)
        let producer = aDecoder.decodeObject(forKey: PropertyKey.producerKey) as! String
        let name = aDecoder.decodeObject(forKey: PropertyKey.nameKey) as! String
        let desc = aDecoder.decodeObject(forKey: PropertyKey.descKey) as! String
        let price = aDecoder.decodeObject(forKey: PropertyKey.priceKey) as! NSDecimalNumber
        let priceOnSale = aDecoder.decodeObject(forKey: PropertyKey.priceOnSaleKey) as! NSDecimalNumber
        //let selected = aDecoder.decodeBoolForKey(PropertyKey.selectedKey)
        self.init(id: id, producer: producer, name: name, desc: desc, price: price, priceOnSale: priceOnSale, selected: false)//selected)
    }
}
