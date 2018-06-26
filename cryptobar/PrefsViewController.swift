//
//  PrefsViewController.swift
//  cryptobar
//
//  Created by Артур Комаров on 26.06.2018.
//  Copyright © 2018 Артур Комаров. All rights reserved.
//

import Cocoa

class PrefsViewController: NSViewController {
    var prefs = Preferences()
    
    @IBOutlet weak var cookieValue: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        cookieValue.stringValue = prefs.cookieValue
        // Do view setup here.
    }
    @IBAction func okButton(_ sender: Any) {
        saveNewPrefs()
        view.window?.close()
    }

    func saveNewPrefs() {
        prefs.cookieValue = cookieValue.stringValue
        NotificationCenter.default.post(name: Notification.Name(rawValue: "PrefsChanged"),
                                        object: nil)
    }
    
}
