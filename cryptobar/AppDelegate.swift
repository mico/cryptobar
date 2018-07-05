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

extension String {
    var html2Attributed: NSAttributedString? {
        do {
            guard let data = data(using: String.Encoding.utf8) else {
                return nil
            }
            return try NSAttributedString(data: data,
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
        } catch {
            print("error: ", error)
            return nil
        }
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var window: NSWindow!
    
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
    let url = URL(string: "https://www.cryptocompare.com/portfolio/")
    fileprivate let queue = DispatchQueue(label: "requests.queue", qos: .utility)
    fileprivate let mainQueue = DispatchQueue.main
    private let cryptoCompareService = CryptoCompareService()
    private var updateInterval: TimeInterval = 15
    var prefs = Preferences()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusItem.button {
            //button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
            button.action = #selector(printQuote(_:))
            //button.title = "B$6629.92"
            updateTitle(button)
            Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true, block: { _ in
                self.updateTitle(button)
            })


//            button.attributedTitle = NSAttributedString.boundingRect(NSAttributedString)
        }
//        constructMenu()
    }
    

    func updateTitle(_ button: NSStatusBarButton) {
        searchRequest() { portfolio, error  in
            if portfolio == nil {
                button.title = "Update cookie!"
            } else {
                button.title = String(format: "%.0f", portfolio!.reduce(0) { $0 + ($1.value.volume * $1.value.price) }.rounded() )
            }
            self.constructMenu(portfolio!)
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

    func constructMenu(_ portfolio: Portfolio) {
        let menu = NSMenu()
        
        for member in portfolio {
            let attributes = [
                NSAttributedStringKey.foregroundColor : (member.value.change > 0 ? NSColor.green : NSColor.red)
            ]
            let titlea: String = "\(member.value.currency) \(String(format: "%.4f %.1f%% %.0f", member.value.price, member.value.change, member.value.price * member.value.volume))"
            let title: NSAttributedString = NSAttributedString(string: titlea, attributes: attributes)
            let item: NSMenuItem = NSMenuItem(title: titlea, action: #selector(AppDelegate.printQuote(_:)), keyEquivalent: "")
            item.attributedTitle = title
            menu.addItem(item)
        }
//        menu.addItem(NSMenuItem.separator())
//        menu.addItem(NSMenuItem(title: "Quit Quotes", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
//
        statusItem.menu = menu
    }
    
    fileprivate func make(session: URLSession = URLSession.shared, request: URLRequest, closure: @escaping (_ json: Portfolio?, _ error: Error?)->()) {
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
            
            let decoder = JSONDecoder()
            let members = try decoder.decode(ResponseData.self, from: result.data(using: .utf8)!)
            var portfolio: Portfolio = [:]
            var currencies: Set<String> = []
            if members.Data.count == 0 {
                closure(nil, nil)
            } else {
                for member in members.Data.first!.Members {
                    if portfolio[member.Coin!.Symbol!] != nil {
                        portfolio[member.Coin!.Symbol!]!.volume += member.Amount!
                    } else {
                        portfolio[member.Coin!.Symbol!] = PortfolioMember(currency: member.Coin!.Symbol!, price: 0, change: 1, volume: member.Amount!)
                    }
                    currencies.insert(member.Coin!.Symbol!)
                }
                self.cryptoCompareService.getExchangeRate(for: Array(currencies)) { exchangeRates, error in
                    guard let exchangeRates = exchangeRates else {
                        print("Failed to fetch current exchange rate for currency pair '\("ETH")': \(error!)")
                        return
                    }
                    for exchangeRate in exchangeRates {
                        portfolio[exchangeRate.key]?.price = exchangeRate.value.price
                        portfolio[exchangeRate.key]?.change = exchangeRate.value.change
                    }
                    dump(portfolio)
                    closure(portfolio, nil)
                    print("ok")
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
    
    func searchRequest(closure: @escaping (_ json: Portfolio?, _ error: Error?)->()) {
        let url = URL(string: "https://www.cryptocompare.com/portfolio/")
        var request = URLRequest(url: url!)
        request.setValue(prefs.cookieValue, forHTTPHeaderField: "Cookie")
        make(request: request) { exchangeRates, error in
            closure(exchangeRates, error)
        }
    }
}

