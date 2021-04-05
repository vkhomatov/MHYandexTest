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
    
    public let networkService = NetworkService()
    public var firstTime: Bool = true
    public var spinner = SpinnerView()
    public var myQuotes = [Quote]()
    public var allQuotes = [Quote]()
    public var searchQuotes = [Quote]()
    public var searchText = String()
    public var isLoading: Bool = false
    public var search: Bool = false
    public var spinnerWork: Bool = false
    public var labelsDidShow: Bool = false
    public var searchLabels = SearchLabels()
    private var counter: Int = 0
    public var stateName: StocksHeaderView.State = .stocks
    public var stocksPriceColor: UIColor = .black
    public var favouritesPriceColor: UIColor = .black
    public var firstRun: Bool = true

    
    
    public func loadQuoteCollections(start: Int = 1, completion: @escaping (String?) -> ()) {
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
    
    public func loadQuotes(symbol: String, completion: @escaping (String?) -> ()) {
        networkService.getQuotes(symbol: symbol)  { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(data):
                self.searchQuotes = data
                    self.counter = 0
                    self.getLogoURLs(quotes: self.searchQuotes, count: self.searchQuotes.count) { completion(nil) }
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
    
    
    public func reloadQuotes(oldQuotes: [Quote], completion: @escaping (String?) -> ()) {

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
        
        for i in 0..<count {
        networkService.getQuotes(symbol: tickers[i] ?? symbols)  { result in
            switch result {
            case let .success(data):                
                for newnum in 0..<data.count {
                    for oldnum in apicount*i..<apicount*i+data.count {
                        if data[newnum].symbol == oldQuotes[oldnum].symbol {
                            guard let realm = try? Realm(configuration: Realm.Configuration(deleteRealmIfMigrationNeeded: true)) else { fatalError() }
                            try? realm.write {
                                oldQuotes[oldnum].regularMarketOpen = data[newnum].regularMarketOpen
                                oldQuotes[oldnum].regularMarketPreviousClose = data[newnum].regularMarketPreviousClose
                                realm.add(oldQuotes[oldnum], update: .modified)
                            }
                        }
                    }
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
        
    }
    
    private func loadCompanyInfo(quote: Quote, completion: @escaping (String?) -> ()) {
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
    
    private func getLogoURLs(quotes: [Quote], count: Int, completion: @escaping () -> ()) {
        for num in quotes.count-count..<quotes.count {
            self.loadCompanyInfo(quote: quotes[num]) { message in
                self.counter += 1
                if self.counter == count {
                    completion()
                }
            }
        }
    }
    
}

