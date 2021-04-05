//
//  SearchLabels.swift
//  YandexTest
//
//  Created by Vitaly Khomatov on 28.03.2021.
//

import Foundation
import SwiftyJSON
import RealmSwift
import UIKit

class SearchLabels: Object {

    @objc dynamic var id: String = "SearchLabels"

    @objc dynamic var dataDate =  Date()

    var _popularSymbols = List<String>()
    
    var popularSymbols: [String] {
        get {
            return _popularSymbols.map { $0 }
        }
        set {
            _popularSymbols.removeAll()
            _popularSymbols.append(objectsIn: newValue.map { $0 })
        }
    }
    
    var _yoursSymbols = List<String>()
    
    var yoursSymbols: [String] {
        get {
            return _yoursSymbols.map { $0 }
        }
        set {
            _yoursSymbols.removeAll()
            _yoursSymbols.append(objectsIn: newValue.map { $0 })
        }
    }
    
    override static func ignoredProperties() -> [String] {
        return ["popularSymbols", "yoursSymbols"]
    }
    
    convenience init(from json: JSON) {
        self.init()
        let symbolsJSONs = json["quotes"].arrayValue
        self.popularSymbols = symbolsJSONs.map { String(from: $0) } }
    
    override static func primaryKey() -> String? {
        return "id"
    }

    public func getFullDateString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        return dateFormatter.string(from: date)
    }
}

extension String {
    init(from json: JSON) {
        self.init()
        self = json.stringValue
    }
}
