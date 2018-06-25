//
//  CurrencyPair.swift
//  cryptobar
//
//  Created by Артур Комаров on 23.06.2018.
//  Copyright © 2018 Артур Комаров. All rights reserved.
//

import Foundation

struct CurrencyPair: Hashable {
    
    // MARK: - Public Properties
    let base: Currency
    let quote: Currency
    
    var name: String {
        return base.code + quote.code
    }
    
    // MARK: - Initialization
    init(base: Currency, quote: Currency) {
        self.base = base
        self.quote = quote
    }
    
    // MARK: - Hashable Protocol
    var hashValue: Int {
        return name.hashValue
    }
    
    static func ==(lhs: CurrencyPair, rhs: CurrencyPair) -> Bool {
        return lhs.base.isEqual(to: rhs.base) && lhs.quote.isEqual(to: rhs.quote)
    }
    
}
