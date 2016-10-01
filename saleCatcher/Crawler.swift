//
//  Crawler.swift
//  saleCatcher
//
//  Created by Maja Zalewska on 01/08/16.
//  Copyright © 2016 Maja Zalewska. All rights reserved.
//

import Foundation
import  Kanna

//przy starcie crawler w osobnym watku, i zapamietuje stan
//TODO zamien wlasne na id na to ze sklepu

class Crawler {

    let baseURL = "http://www.rossmann.pl/produkty"
    let tags = "//div[contains(concat(' ', normalize-space(@class), ' '), ' productslider ')]"
    var list = [Product]()
    let rows = 100
    let nameConst = ", nr"

    
    init() {
        list = []
    }
    
    func crawl(_ handler: (([Product]) -> Void)){
        let pages = getNumberOfPagesFor((baseURL + "?rows=" + String(rows)), rows: rows)
        var id = Int32(0)
        for page in 1...pages/pages {
            let urlString = baseURL + String(page) + "?rows=" + String(rows)
            print(id)
            subcrawl(urlString, tags: tags, _id: id)
            id += rows
            print("id", id)
        }
        handler(list)
    }
    
    func subcrawl(_ urlString: String, tags: String, _id: Int32) {
        guard let url = URL(string: urlString) else {
            print("Error: \(urlString) doesn't seem to be a valid URL")
            return
        }
        do {
            let html = try String(contentsOf: url)
            if let doc = Kanna.HTML(html: html, encoding: String.Encoding.utf8) {
                print("produkty")
                var id = _id
                for elem in doc.xpath(tags) {
                    let lines = elem.text?.characters.split { $0 == "\n" || $0 == "\r\n" }.map(String.init)
                  // print(lines)
              
                    var productName = ""
                    for (_, value) in lines!.enumerated() {
                        if let newEndIndex = value.range(of: nameConst)?.lowerBound {
                           // let idIndex = value.index(newEndIndex, offsetBy: 10) //length of , nr.kat.
                            productName = value[value.startIndex..<newEndIndex]
                           // let id = value[idIndex..<value.endIndex]
                            //print(id)
                        }
                        if let _ = value.range(of: "=") {
                            let prices = value.characters.split { $0 == " " }.map(String.init)
                            let product = Product(nameString: productName, prices: prices, id: id)
                            list += [product]
                            id += 1
                            break
                        }
                    }
                }
            }
            print(list.count)
        } catch let error as NSError {
           print("Error: \(error)")
        }
    }

func getNumberOfPagesFor(_ urlString: String, rows: Int) -> Int {
    guard let url = URL(string: urlString) else {
        print("Error: \(urlString) doesn't seem to be a valid URL")
        return -1
    }
    do {
        let html = try String(contentsOf: url)
        if let doc = Kanna.HTML(html: html, encoding: String.Encoding.utf8) {
            var pagesNumber: Int?
            for elem in doc.xpath("//div[@class='pagination']") {
                let dataBind = elem["data-bind"]! // search for the number of all elements to disply
                pagesNumber = findNumberOfPagesIn(dataBind)
                if pagesNumber != nil {
                    break
                }
            }
            return pagesNumber!
        }
    } catch let error as NSError {
        print("Error: \(error)")
    }
    return -1
}

func findNumberOfPagesIn(_ dataBind: String) -> Int? {
    var pages = String("")
    var index = dataBind.range(of: "pagesCount: ")?.upperBound
    var next = dataBind[index!]
    while (next >= "0" && next <= "9") {
        let str = String(next)
        pages! += str
        //if index != nil {
            index = dataBind.index(index!, offsetBy: 1)//index.index(index?, offsetBy: 1)
            next = dataBind[index!]
        //}
    }
    print("pages: ", Int(pages!))

    return Int(pages!)
}

}
