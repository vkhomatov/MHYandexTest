//
//  Quote.swift
//  YandexTest
//
//  Created by Vitaly Khomatov on 26.03.2021.
//

import Foundation
import UIKit
import SwiftyJSON
import RealmSwift

class Quote: Object {
    
    @objc dynamic var symbol: String = ""
    @objc dynamic var shortName: String = ""
    @objc dynamic var longName: String = ""
    @objc dynamic var currency: String = ""
    @objc dynamic var logoStr: String = ""
    @objc dynamic var regularMarketOpen: Double = 0
    @objc dynamic var regularMarketPreviousClose: Double = 0
    @objc dynamic var starStatus: Bool = false

    
    var coeffColor: UIColor = UIColor.systemGreen
    var logoImage = UIImage()

    var companyWebsite: String = "" {
        didSet {
            var parsedStr = String()
            if let str = deletingPrefix(string: companyWebsite, prefix: "https://www.") {
                parsedStr = str
            } else if let str = deletingPrefix(string: companyWebsite, prefix: "http://www.") {
                parsedStr = str
            }
            self.logoStr = "https://logo.clearbit.com/" + parsedStr
        }
    }
    
    convenience init(from json: JSON) {
        self.init()
        self.symbol = json["symbol"].stringValue
        self.shortName = json["shortName"].stringValue
        self.longName = json["longName"].stringValue
        self.currency = json["currency"].stringValue
        self.regularMarketOpen = json["regularMarketOpen"].doubleValue
        self.regularMarketPreviousClose = json["regularMarketPreviousClose"].doubleValue
        self.companyWebsite = json["website"].stringValue
    }
    
    static func == (lhs: Quote, rhs: Quote) -> Bool {
        return lhs.symbol == rhs.symbol && lhs.shortName == rhs.shortName
    }
    
    func getCoeff() -> String {
        var priceStr: String = ""
        var diff : Double = 0
        diff = regularMarketOpen - regularMarketPreviousClose
        let procStr = String(format: "%.02f ", diff*100/regularMarketPreviousClose).trimmingCharacters(in: .init(arrayLiteral: "-"))
        if diff < 0 {
            let diffStr = String(format: "%.02f ", diff).trimmingCharacters(in: .init(arrayLiteral: "-"))
            priceStr = "-" + getSymbolForCurrencyCode(code: currency) + diffStr
        } else {
            priceStr = getSymbolForCurrencyCode(code: currency) + String(format: "%.02f ", diff)
        }
        if diff < 0 { coeffColor = UIColor.systemRed }
        return priceStr + " " + "(" + procStr + "%)"
    }
    
    func getSymbolForCurrencyCode(code: String) -> String
    {
        let locale = NSLocale(localeIdentifier: code)
        if let symbol = locale.displayName(forKey: NSLocale.Key.currencySymbol, value: code) {
            return symbol
        } else {
            return ""
        }
    }
    
    func deletingPrefix(string: String, prefix: String) -> String? {
        guard string.hasPrefix(prefix) else { return nil }
        return String(string.dropFirst(prefix.count))
    }
    
    func getPrice() -> String {
        return  getSymbolForCurrencyCode(code: currency) + String(regularMarketOpen)
    }
    
    func getCompanyName() -> String {
        return longName.count < shortName.count ? longName : shortName
    }
    
    override static func primaryKey() -> String? {
        return "symbol"
    }
}
