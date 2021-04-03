//
//  StocksModel.swift
//  YandexTest
//
//  Created by Vitaly Khomatov on 26.03.2021.
//

import Foundation
import UIKit
import RealmSwift

class StocksModel {
    
    let networkService = NetworkService()
    
    var firstTime: Bool = true
    var spinner = SpinnerView()
    
    var myQuotes = [Quote]()
    var allQuotes = [Quote]() // didSet проверка на вхождение объетов со звездами
    var searchQuotes = [Quote]() // didSet проверка на вхождение объектов со звездами
    
    
    
    var searchText = String()
    var mySearchLabels: [String] = [] {
        didSet {
            writeLabels(my: true)
        }
    }
    var popularSearchLabels: [String] = [] {
        didSet {
            if popularSearchLabels.count != 0 {
                writeLabels(my: false)
            }
        }
    }
    
    var isLoading: Bool = false
    var search: Bool = false
    var spinnerWork: Bool = false
    var stocksIndexPath: IndexPath?
    var favouriteIndexPath: IndexPath?
    var labelsDidShow: Bool = false
    var searchLabels = SearchLabels()
    private var counter: Int = 0
    
    
    
    func loadQuoteCollections(start: Int = 1, completion: @escaping (String?) -> ()) {
        networkService.getQuoteCollections(start: start)  { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(data):
                self.allQuotes.append(contentsOf: data)
                
               // DispatchQueue.main.async() {
                    self.counter = 0
                    self.getLogoURLs(quotes: self.allQuotes, count: 25) {
                        try? RealmService.saveTickers(tickers: self.allQuotes)
                        completion(nil)
                    }
               // }
                completion(nil)
            case .failure(let error):
                let errorText = error.localizedDescription.split(separator: ":").last
                completion(errorText?.description)
                #if DEBUG
                print(error.localizedDescription)
                #endif
            }
        }
    }
    
    func loadQuotes(symbol: String, completion: @escaping (String?) -> ()) {
        networkService.getQuotes(symbol: symbol)  { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(data):
                self.searchQuotes = data
              //  DispatchQueue.main.async() {
                    self.counter = 0
                    self.getLogoURLs(quotes: self.searchQuotes, count: self.searchQuotes.count) {
                        completion(nil)
                    }
              //  }
                completion(nil)
            case .failure(let error):
                let errorText = error.localizedDescription.split(separator: ":").last
                completion(errorText?.description)
                #if DEBUG
                print(error.localizedDescription)
                #endif
            }
        }
    }
    
    
    func loadCompanyInfo(quote: Quote, completion: @escaping (String?) -> ()) {
        networkService.getCompanyInfo(symbol: quote.symbol)  { result in
            switch result {
            case let .success(data):
                guard let realm = try? Realm(configuration: Realm.Configuration(deleteRealmIfMigrationNeeded: true)) else { fatalError() }
                try? realm.write {
                    quote.companyWebsite = data.companyWebsite
                    realm.add(quote, update: .modified)
                }
                completion(nil)
            case .failure(let error):
                let errorText = error.localizedDescription.split(separator: ":").last
                completion(errorText?.description)
                #if DEBUG
                print(error.localizedDescription)
                #endif
            }
        }
    }
    
    func getLogoURLs(quotes: [Quote], count: Int, completion: @escaping () -> ()) {
        for num in quotes.count-count..<quotes.count {
            self.loadCompanyInfo(quote: quotes[num]) { message in
//                if let error = message {
//                    print("\(quotes[num].symbol) - ошибка загрузки информации о компании ",(error))
//                } else {
//                    print("\(quotes[num].symbol) - инфо о компании загружено")
//                }
                self.counter += 1
                if self.counter == count {
                    completion()
                }
            }
        }
    }
    
    func writeLabels(my: Bool) {
        guard let realm = try? Realm(configuration: Realm.Configuration(deleteRealmIfMigrationNeeded: true)) else { fatalError() }
        try? realm.write {
            if my {
                searchLabels.yoursSymbols = mySearchLabels
            } else {
                searchLabels.popularSymbols = popularSearchLabels
            }
            realm.add(searchLabels, update: .modified)
        }
    }
    
    
//    func writeFavourites(index: Int, status: Bool) {
//        guard let realm = try? Realm(configuration: Realm.Configuration(deleteRealmIfMigrationNeeded: true)) else { fatalError() }
//        try? realm.write {
//            if status {
//                if !labelsAndFavourites.favourites.contains(allQuotes[index].symbol) {
//                    labelsAndFavourites.favourites.append(allQuotes[index].symbol)
//                }
//            } else {
//                labelsAndFavourites.favourites = labelsAndFavourites.favourites.filter { $0 != allQuotes[index].symbol }
//            }
//            realm.add(labelsAndFavourites, update: .modified)
//
//        }
//    }
    
    
//    func setFavorites(quotes: [Quote]) {
//        if let labelsAndFavourites = try? RealmService.getLabelsAndFavorites(LabelsAndFavourites.self) {
//            self.labelsAndFavourites = labelsAndFavourites
//            for quote in quotes {
//                for label in labelsAndFavourites.favourites {
//                    if quote.symbol == label {
//                        quote.starStatus = true
//                    }
//                }
//            }
//        }
//    }
    
}

