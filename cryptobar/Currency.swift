//
//  Currency.swift
//  cryptobar
//
//  Created by Артур Комаров on 23.06.2018.
//  Copyright © 2018 Артур Комаров. All rights reserved.
//

import Foundation

enum CurrencyType: String {
    case Fiat
    case Crypto
}

protocol Currency {
    var code: String { get }
    var name: String { get }
    var price: Double { get }
    var symbol: String { get }
    var decimalDigits: Int { get }
    var type: CurrencyType { get }
    
    func isEqual(to: Currency) -> Bool
}

extension Currency {
    func isEqual(to: Currency) -> Bool {
        return self.code == to.code
    }
}
