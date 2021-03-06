//
//  ExchangeRates.swift
//  cryptobar
//
//  Created by Артур Комаров on 25.06.2018.
//  Copyright © 2018 Артур Комаров. All rights reserved.
//

import Foundation

typealias ExchangeRates = [String: ExchangeRate]
struct ExchangeRate {
    var price: Double
    var change: Double
}
