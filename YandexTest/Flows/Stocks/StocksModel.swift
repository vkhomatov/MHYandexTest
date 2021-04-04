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
    //var myNewQuotes = [Quote]()
    var allQuotes = [Quote]() // didSet проверка на вхождение объетов со звездами
    var searchQuotes = [Quote]() // didSet проверка на вхождение объектов со звездами
    
    
    
    var searchText = String()
    
//    var mySearchLabels: [String] = [] {
//        didSet {
//            writeLabels(my: true)
//        }
//    }
//    var popularSearchLabels: [String] = [] {
//        didSet {
//            if popularSearchLabels.count != 0 {
//                writeLabels(my: false)
//            }
//        }
//    }
    
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
                
                    self.counter = 0
                    self.getLogoURLs(quotes: self.allQuotes, count: 25) {
                        try? RealmService.saveTickers(tickers: self.allQuotes)
                        completion(nil)
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
    
    func loadQuotes(symbol: String, completion: @escaping (String?) -> ()) {
        networkService.getQuotes(symbol: symbol)  { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(data):
                    self.searchQuotes = data
                    self.counter = 0
                    self.getLogoURLs(quotes: self.searchQuotes, count: self.searchQuotes.count) {
                        completion(nil)
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
    
    
    func reloadFavoriteTickers(oldQuotes: [Quote], completion: @escaping (String?) -> ()) {
        
       // var symbol = String()
        
      //  oldQuotes.forEach { symbol += ($0.symbol + ",") }
        
       // print("Строка обновления тикеров: \(symbol)")
        

        let apicount = 40
        let count = oldQuotes.count % apicount == 0 ? oldQuotes.count/apicount : oldQuotes.count/apicount + 1
        
        var tickers = [Int: String]()
        var symbols = String()
        
        for i in 0..<count {
            symbols.removeAll()
            for num in apicount*i..<apicount*(i+1) {
                symbols += oldQuotes[num].symbol + ","
                if num == oldQuotes.count-1 { break }
            }
            tickers.updateValue(symbols, forKey: i)
        }
        
       // print(tickers)
        
   
        for i in 0..<count {
            print("Обновление тикеров: \(String(describing: tickers[i]))")
        networkService.getQuotes(symbol: tickers[i] ?? symbols)  { /*[weak self]*/ result in
          //  guard let self = self else { return }
            switch result {
            case let .success(data):
                print("DATA = \(data)")
                
                for newnum in 0..<data.count {
                    for oldnum in apicount*i..<apicount*i+data.count {
                        if data[newnum].symbol == oldQuotes[oldnum].symbol {
                            
                            guard let realm = try? Realm(configuration: Realm.Configuration(deleteRealmIfMigrationNeeded: true)) else { fatalError() }
                            try? realm.write {
                                print("Старые данные: \(oldQuotes[oldnum].regularMarketOpen)")
                                print("Старые данные: \(oldQuotes[oldnum].regularMarketPreviousClose)")

                                oldQuotes[oldnum].regularMarketOpen = data[newnum].regularMarketOpen
                                oldQuotes[oldnum].regularMarketPreviousClose = data[newnum].regularMarketPreviousClose
                                realm.add(oldQuotes[oldnum], update: .modified)
                                
                                print("Новые данные: \(data[newnum].regularMarketOpen)")
                                print("Новые данные: \(data[newnum].regularMarketPreviousClose)")
                                
                            }
                        }
                    }
                }
                 
               /* data.forEach { quote in
                    oldQuotes.forEach { oquote in
                        if oquote.symbol == quote.symbol {
                            guard let realm = try? Realm(configuration: Realm.Configuration(deleteRealmIfMigrationNeeded: true)) else { fatalError() }
                            try? realm.write {
                                print("Старые данные: \(oquote.regularMarketOpen)")
                                print("Старые данные: \(oquote.regularMarketPreviousClose)")

                                oquote.regularMarketOpen = quote.regularMarketOpen
                                oquote.regularMarketPreviousClose = quote.regularMarketPreviousClose
                                realm.add(oquote, update: .modified)
                                
                                print("Новые данные: \(quote.regularMarketOpen)")
                                print("Новые данные: \(quote.regularMarketPreviousClose)")
                            }
                        }
                    }
                    
                    
                 /*   if let index = oldQuotes.firstIndex(of: quote) {
                        
                        guard let realm = try? Realm(configuration: Realm.Configuration(deleteRealmIfMigrationNeeded: true)) else { fatalError() }
                        try? realm.write {
                            print("Старые данные: \(oldQuotes[index].regularMarketOpen)")
                            print("Старые данные: \(oldQuotes[index].regularMarketPreviousClose)")

                            oldQuotes[index].regularMarketOpen = quote.regularMarketOpen
                            oldQuotes[index].regularMarketPreviousClose = quote.regularMarketPreviousClose
                            realm.add(quote, update: .modified)
                            
                            print("Новые данные: \(quote.regularMarketOpen)")
                            print("Новые данные: \(quote.regularMarketPreviousClose)")
                        }
                       
                    } */
                } */
                
                
                print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
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
    
//    func writeLabels(my: Bool) {
//        guard let realm = try? Realm(configuration: Realm.Configuration(deleteRealmIfMigrationNeeded: true)) else { fatalError() }
//        try? realm.write {
//            if my {
//                searchLabels.yoursSymbols = mySearchLabels
//            } else {
//                searchLabels.popularSymbols = popularSearchLabels
//            }
//            realm.add(searchLabels, update: .modified)
//        }
//    }
//    
    
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

