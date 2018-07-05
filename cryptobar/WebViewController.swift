//
//  WebViewController.swift
//  cryptobar
//
//  Created by Артур Комаров on 27.06.2018.
//  Copyright © 2018 Артур Комаров. All rights reserved.
//

import Cocoa
import WebKit

class WebViewController: NSViewController {

    @IBOutlet weak var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
//        let url = Bundle.init(url: <#T##URL#>)
//        let requesturl = NSURL(string: "main.html")
        view.window?.makeKeyAndOrderFront(self)
        let url = URL(string: "https://www.cryptocompare.com/portfolio/")
        let request = URLRequest(url: url!)
        self.webView.load(request)

        // Do view setup here.
    }
    
}
