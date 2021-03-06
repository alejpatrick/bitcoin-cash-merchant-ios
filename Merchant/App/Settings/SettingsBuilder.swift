//
//  SettingsBuilder.swift
//  Merchant
//
//  Created by Jean-Baptiste Dominguez on 2019/03/26.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit
import BDCKit

class SettingsBuilder: BDCBuilder {
    
    func provide() -> UIViewController {
        let viewController = SettingsViewController()
        
        let getCurrenciesInteractor = GetCurrenciesInteractor()
        let editUserInteractor = EditUserInteractor()
        let router = SettingsRouter(viewController)
        
        let presenter = SettingsPresenter()
        presenter.getCurrenciesInteractor = getCurrenciesInteractor
        presenter.editUserInteractor = editUserInteractor
        presenter.viewDelegate = viewController
        presenter.router = router
        
        viewController.presenter = presenter
        
        return viewController
    }
}
