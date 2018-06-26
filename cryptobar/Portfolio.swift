//
//  Portfolio.swift
//  cryptobar
//
//  Created by Артур Комаров on 25.06.2018.
//  Copyright © 2018 Артур Комаров. All rights reserved.
//

import Foundation

typealias Portfolio = [String: PortfolioMember]
//    func total() {
//        return 0;
//    }

struct PortfolioMember {
    let currency: String
    var price: Double
    var change: Double
    var volume: Double
}
