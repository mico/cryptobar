//
//  Preferences.swift
//  cryptobar
//
//  Created by Артур Комаров on 26.06.2018.
//  Copyright © 2018 Артур Комаров. All rights reserved.
//

import Foundation

struct Preferences {
    var cookieValue: String {
        get {
            let cookieValue = UserDefaults.standard.string(forKey: "cookieValue")
            if cookieValue == nil {
                return ""
            }
            return cookieValue!
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "cookieValue")
        }
    }
}
