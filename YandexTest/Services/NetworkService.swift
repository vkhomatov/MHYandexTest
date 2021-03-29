//
//  NetworkService.swift
//  YandexTest
//
//  Created by Vitaly Khomatov on 25.03.2021.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class NetworkService {
    
    var urlConstructor: URLComponents = {
        var constructor = URLComponents()
        constructor.scheme = "https"
        constructor.host = "mboum.com"
        return constructor
    }()
    
    static let session: Alamofire.Session = {
        let config = URLSessionConfiguration.default
        let apiKey: String = "8HAQWR4mufnT5kx4vGRudn9vxjnNAiJwW1RbwgXkybiwx7c6NDIEQY4s8Ygc"
        let finnService: String = "X-Mboum-Secret"
        config.timeoutIntervalForRequest = 20
        config.headers = HTTPHeaders([finnService : apiKey])
        config.timeoutIntervalForResource = 100
        let session = Alamofire.Session(configuration: config)
        return session
    }()
    
    func getQuoteCollections(start: Int = 1, completion: ((Swift.Result<[Quote], Error>) -> Void)? = nil) {
        urlConstructor.path = "/api/v1/co/collections"
        
        let params: Parameters = [
            "list" : "day_gainers",
            "start" : start]

        guard let url = urlConstructor.url else { return }

        NetworkService.session.request(url, method: .get, parameters: params).responseJSON { response in
            switch response.result {
            case let .success(data):
                let json = JSON(data)
                let quotesJSONs = json["quotes"].arrayValue
                let quotes = quotesJSONs.map { Quote(from: $0) }
                completion?(.success(quotes))
            case let .failure(error):
                completion?(.failure(error))
                #if DEBUG
                print(#function + " - Data load error: \(error)")
                #endif
            }
        }
    }
    
    func getQuotes(symbol: String, completion: ((Swift.Result<[Quote], Error>) -> Void)? = nil) {
        
        urlConstructor.path = "/api/v1/qu/quote"
        
        let params: Parameters = [
            "symbol" : symbol]
        
        guard let url = urlConstructor.url else { return }
        
        NetworkService.session.request(url, method: .get, parameters: params).responseJSON { response in
            
            switch response.result {
            case let .success(data):
                let json = JSON(data)
                let quotesJSONs = json.arrayValue
                let quotes = quotesJSONs.map { Quote(from: $0) }
                completion?(.success(quotes))
            case let .failure(error):
                completion?(.failure(error))
                #if DEBUG
                print(#function + " - Data load error: \(error)")
                #endif
            }
        }
    }
    
    
    func getCompanyInfo(symbol: String, completion: ((Swift.Result<Quote, Error>) -> Void)? = nil) {
        
        urlConstructor.path = "/api/v1/qu/quote/profile"
        
        let params: Parameters = [
            "symbol" : symbol]
        
        guard let url = urlConstructor.url else { return }
        
        
        NetworkService.session.request(url, method: .get, parameters: params).responseJSON { response in
            
            switch response.result {
            case let .success(data):
                let json = JSON(data)
                let quote = Quote(from: json)
                completion?(.success(quote))
            case let .failure(error):
                completion?(.failure(error))
                #if DEBUG
                print(#function + " - Data load error: \(error)")
                #endif
            }
        }
    }
    
    func getMostWatchedLabels(completion: ((Swift.Result<[LabelsAndFavourites], Error>) -> Void)? = nil) {
        
        urlConstructor.path = "/api/v1/tr/trending"
        
        guard let url = urlConstructor.url else { return }
        
        NetworkService.session.request(url, method: .get, parameters: nil).responseJSON { response in
            
            switch response.result {
            case let .success(data):
                let json = JSON(data)
                let mostJSONs = json.arrayValue
                let most = mostJSONs.map { LabelsAndFavourites(from: $0) }
                completion?(.success(most))
            case let .failure(error):
                completion?(.failure(error))
                #if DEBUG
                print(#function + " - Data load error: \(error)")
                #endif
            }
        }
    }
    
}
