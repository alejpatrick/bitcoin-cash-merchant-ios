//
//  UserManager.swift
//  Merchant
//
//  Created by Jean-Baptiste Dominguez on 2019/04/23.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Foundation
import RealmSwift

class UserManager {
    
    // Singleton
    static let shared = UserManager()
    
    var selectedCurrency: StoreCurrency?
    var destination: String?
    var companyName: String?
    
    init() {
        
        let storageProvider = InternalStorageProvider()
        let ticker = storageProvider.getString("selectedCurrencyTicker")
        
        if let _ = ticker {
            let realm = try! Realm()
            selectedCurrency = realm.object(ofType: StoreCurrency.self, forPrimaryKey: ticker)
        }
        
        destination = storageProvider.getString("destination")
        companyName = storageProvider.getString("companyName")
    }
}