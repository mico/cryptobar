//
//  CryptoCompareService.swift
//  cryptobar
//
//  Created by Артур Комаров on 23.06.2018.
//  Copyright © 2018 Артур Комаров. All rights reserved.
//

import Foundation

typealias JSON = [String: Any]

extension URL {
    init(baseURL: String, path: String?, params: JSON?) {
        var components = URLComponents(string: "\(baseURL)\(path ?? "")")!
        var queryItems = [URLQueryItem]()
        
        if let params = params {
            for (key, value) in params {
                let queryItem = URLQueryItem(name: key, value: String(describing: value))
                queryItems.append(queryItem)
            }
        }
        
        components.queryItems = queryItems
        self = components.url!
    }
}

enum CryptoCompareAPIError: Error {
    case invalidData
    case invalidJSON
}

struct CryptoCompareService {
    
    // MARK: - Public Properties
    
    // MARK: - Private Properties
//    private let request: URLRequest
    
    // MARK: - Initialization
    init() {
    }
    
    // MARK: - Public Methods
    func getExchangeRate(for currencies: [String], completion: @escaping ([String: ExchangeRate]?, Error?) -> Void) {
        var exchangeRates: ExchangeRates = [:]

        let params = [
            "fsyms": currencies.joined(separator: ","),
            "tsyms": "USD",
            ]

        let url = URL(baseURL: "https://min-api.cryptocompare.com/data", path: "/pricemultifull", params: params)
        let request = URLRequest(url: url)

        let session: URLSession = URLSession.shared

        let task = session.dataTask(with: request) { data, response, error in
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data!, options: [])
                
                // jd!["RAW"]!["EOS"]!["USD"]!["PRICE"]! as? Double
                guard let jsonDictionary = jsonObject as? [AnyHashable: [AnyHashable: [AnyHashable: [AnyHashable: Any]]]] else {
                    completion(nil, CryptoCompareAPIError.invalidJSON)
                    return
                }
                
                for currency in currencies {
                    exchangeRates[currency] = ExchangeRate(price: (jsonDictionary["RAW"]![currency]!["USD"]!["PRICE"] as? Double)!,
                                                           change: (jsonDictionary["RAW"]![currency]!["USD"]!["CHANGEPCT24HOUR"] as? Double)!)
                }
                
                completion(exchangeRates, nil)
            } catch {
                completion(nil, CryptoCompareAPIError.invalidData)
            }
        }
        task.resume()
    }
    
}
