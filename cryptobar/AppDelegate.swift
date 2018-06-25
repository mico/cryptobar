//
//  AppDelegate.swift
//  cryptobar
//
//  Created by Артур Комаров on 20.06.2018.
//  Copyright © 2018 Артур Комаров. All rights reserved.
//

import Cocoa
import Foundation

struct MembersData: Decodable {
    let Members: [Member]
}

struct ResponseData: Decodable {
    let Data: [MembersData]
}

struct Coin: Decodable {
    let Symbol: String?
}

struct Member: Decodable {
    let Coin: Coin?
    let Amount: Double?
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
    let url = URL(string: "https://www.cryptocompare.com/portfolio/")
    fileprivate let queue = DispatchQueue(label: "requests.queue", qos: .utility)
    fileprivate let mainQueue = DispatchQueue.main
    private let cryptoCompareService = CryptoCompareService()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusItem.button {
            //button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
            button.action = #selector(printQuote(_:))
            button.title = "B$6629.92"
            
//            button.attributedTitle = NSAttributedString.boundingRect(NSAttributedString)
        }
        constructMenu()
        searchRequest(term: "jack johnson") { json, error  in
            print(error ?? "nil")
            print("Update views")
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @objc func printQuote(_ sender: Any?) {
        let quoteText = "Never put off until tomorrow what you can do the day after tomorrow."
        let quoteAuthor = "Mark Twain"
        
        print("\(quoteText) — \(quoteAuthor)")
    }

    func constructMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Print Quote", action: #selector(AppDelegate.printQuote(_:)), keyEquivalent: "P"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Quotes", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    fileprivate func make(session: URLSession = URLSession.shared, request: URLRequest, closure: @escaping (_ json: [String: Any]?, _ error: Error?)->()) {
        let task = session.dataTask(with: request) { data, response, error in
        guard error == nil else {
            return
        }
        guard let data = data else {
            return
        }
        
        do {
            var result: String = String(data: data, encoding: String.Encoding.utf8)!
            result = result.components(separatedBy: "portfolioManager.setPortfolioData(")[1] as String
            result = result.components(separatedBy: ");")[0]
            
//                    print(result)
            let decoder = JSONDecoder()
            let members = try decoder.decode(ResponseData.self, from: result.data(using: .utf8)!)
            dump(members)
            // members.Data.first?.Members[0].Coin?.Symbol
            // members.Data.first?.Members[0].Amount
            //CurrencyPair(base: Blockchain.ETH, quote: Fiat.EUR)
            self.cryptoCompareService.getExchangeRate(for: ["ETH", "EOS"]) { exchangeRate, error in
                guard let exchangeRate = exchangeRate else {
                    print("Failed to fetch current exchange rate for currency pair '\("ETH")': \(error!)")
                    return
                }
                dump(exchangeRate)
                print("ok")
            }
            if let json = try JSONSerialization.jsonObject(with: result.data(using: .utf8)!, options: .mutableContainers) as? [String: Any] {
                self.mainQueue.async {
                    closure(json, nil)
                }
            }
        } catch let error {
            print(error.localizedDescription)
            self.mainQueue.async {
                closure(nil, error)
            }
        }
        }
        
        task.resume()
    }
    
    func searchRequest(term: String, closure: @escaping (_ json: [String: Any]?, _ error: Error?)->()) {
        let url = URL(string: "https://www.cryptocompare.com/portfolio/")
        var request = URLRequest(url: url!)
        request.setValue("__cfduid=d619afd5fe01ae60f6296423f611d4f601521520914; _ga=GA1.2.328201677.1521520916; G_ENABLED_IDPS=google; _gid=GA1.2.1416150890.1528269789; sid=53800E49CD0BD871B4D51F4F82ADD097E5B077020F9EADC0CE13D2B0B1E552AA29B1957F3219713BC4867A6D0DFFF468D3DEBC80C110E0CFA0FE9DFB50AAB3F2DD83C293D4DB66749401A9B88F7265B5B4FA5BCE86041481E59591BB4DAD1D7D9479341752C82839573B216F9BE54EEA41C1B1C0; _gat_UA-63634809-1=1", forHTTPHeaderField: "Cookie")
        make(request: request) { json, error in
            closure(json, error)
        }
    }


}

