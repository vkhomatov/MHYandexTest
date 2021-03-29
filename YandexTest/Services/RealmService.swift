//
//  RealmService.swift
//  YandexTest
//
//  Created by Vitaly Khomatov on 28.03.2021.
//

import Foundation
import RealmSwift

class RealmService {
    
    static let deleteIfMigration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
    
    static func getTickers(_ type: Quote.Type,
                    configuration: Realm.Configuration = deleteIfMigration,
                    update: Realm.UpdatePolicy = .modified)
    throws -> [Quote] {
        let realm = try Realm(configuration: configuration)
        #if DEBUG
      //  print("Realm \(String(describing: configuration.fileURL?.description))" )
        #endif
        return realm.objects(type).map { $0 }//.sorted { $0.symbol < $1.symbol }
    }

    
    static func saveTickers(tickers: [Quote],
                     configuration: Realm.Configuration = deleteIfMigration,
                     update: Realm.UpdatePolicy = .modified)
    throws {
        let realm = try Realm(configuration: configuration)
        #if DEBUG
      //  print("Realm \(String(describing: configuration.fileURL?.description))" )
        #endif
        try realm.write {
            realm.add(tickers, update: update)
        }
    }
    
//    static func getTicker(_ type: Quote.Type, key: String,
//                    configuration: Realm.Configuration = deleteIfMigration,
//                    update: Realm.UpdatePolicy = .modified)
//    throws -> Quote? {
//        let realm = try Realm(configuration: configuration)
//        #if DEBUG
//        print("Realm \(String(describing: configuration.fileURL?.description))" )
//        #endif
//        return realm.object(ofType: type, forPrimaryKey: key)
//    }
    
//    static func saveTicker(ticker: Quote,
//                     configuration: Realm.Configuration = deleteIfMigration,
//                     update: Realm.UpdatePolicy = .modified)
//    throws {
//        let realm = try Realm(configuration: configuration)
//        #if DEBUG
//        print("Realm \(String(describing: configuration.fileURL?.description))" )
//        #endif
//        try realm.write {
//            //item.segment = segment
//            realm.add(ticker.self, update: update)
//        }
//    }
    
    static func getLabelsAndFavorites(_ type: LabelsAndFavourites.Type,
                    configuration: Realm.Configuration = deleteIfMigration,
                    update: Realm.UpdatePolicy = .modified)
    throws -> LabelsAndFavourites? {
        let realm = try Realm(configuration: configuration)
        #if DEBUG
        print("Realm \(String(describing: configuration.fileURL?.description))" )
        #endif
        if let labelsAndFavorites = realm.object(ofType: type, forPrimaryKey: "LabelsAndFavourites") {
        return labelsAndFavorites//.sorted { $0.symbol < $1.symbol }
        } else {
            return nil
        }
    }
    
    
}
