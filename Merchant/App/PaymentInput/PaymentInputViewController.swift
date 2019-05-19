//
//  PaymentInputViewController.swift
//  Merchant
//
//  Created by Jean-Baptiste Dominguez on 2019/04/22.
//  Copyright © 2018 Bitcoin.com. All rights reserved.
//

import UIKit
import BDCKit

class PaymentInputViewController: PinViewController {
    
    var amountLabel: BDCLabel = {
        let label = BDCLabel.build(.header)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var currencyLabel: BDCLabel = {
        let label = BDCLabel.build(.header)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var amountView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var alertStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    var blurView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: nil)
        blurView.effect = UIBlurEffect(style: .extraLight)
        blurView.alpha = 0.8
        return blurView
    }()
    
    var presenter: PaymentInputPresenter?
    
    var amountStr: String = "0"
   
    private let notificationCenter: NotificationCenter = NotificationCenter.default
    
    @objc private func currencyDidChange(_ notification: Notification) {
        DispatchQueue.main.async {
            self.onCleanAmount()
            self.presenter?.didSetAmount("0")
            self.currencyLabel.text = UserManager.shared.selectedCurrency.ticker
        }
    }
    
    override func viewDidLoad() {
        self.hasValid = true
        notificationCenter.addObserver(self, selector: #selector(currencyDidChange),
                                       name: .currencyChanged, object: nil)
        super.viewDidLoad()
        
        currencyLabel.text = UserManager.shared.selectedCurrency.ticker
        currencyLabel.font = currencyLabel.font.withSize(18)
        let stackTextViews = UIStackView(arrangedSubviews: [amountLabel, currencyLabel])
        stackTextViews.axis = .vertical
        stackTextViews.alignment = .center
        stackTextViews.spacing = 16
        stackTextViews.translatesAutoresizingMaskIntoConstraints = false
        
        amountView.addSubview(stackTextViews)
        amountLabel.centerXAnchor.constraint(equalTo: amountView.centerXAnchor).isActive =  true
        amountLabel.centerYAnchor.constraint(equalTo: amountView.centerYAnchor).isActive =  true
        currencyLabel.centerXAnchor.constraint(equalTo: amountView.centerXAnchor).isActive =  true
        currencyLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 16).isActive =  true

        let stackView = UIStackView(arrangedSubviews: [amountView, pinCollectionView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        
        view.addSubview(stackView)
        
        stackView.fillSuperView()
        
        pinDelegate = self
        
        let titleLabel = BDCLabel.build(.title)
        titleLabel.text = Constants.Strings.receivingAddressNotAvailable
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        let messageLabel = BDCLabel.build(.subtitle)
        messageLabel.text = Constants.Strings.receivingAddressNotAvailableDetails
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        
        let settingsButton = BDCButton.build(.type3)
        settingsButton.setTitle(Constants.Strings.settings, for: .normal)
        settingsButton.addTarget(self, action: #selector(didPushSettings), for: .touchUpInside)
        
        alertStackView.addArrangedSubview(titleLabel)
        alertStackView.addArrangedSubview(messageLabel)
        alertStackView.addArrangedSubview(settingsButton)
        
        presenter?.viewDidLoad()
    }
    
    func showAlertSettings() {
        blurView.removeFromSuperview()
        view.addSubview(blurView)
        blurView.fillSuperView()
        
        alertStackView.removeFromSuperview()
        view.addSubview(alertStackView)
        alertStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        alertStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func hideAlertSettings() {
        blurView.removeFromSuperview()
        alertStackView.removeFromSuperview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presenter?.viewWillAppear()
    }
    
    @objc func didPushSettings() {
        presenter?.didPushSettings()
    }
    
    func onCleanAmount() {
        amountStr = "0"
    }
    
    func onSetAmount(_ amount: String) {
        amountLabel.text = amount
    }
    
    func onSetComma(_ hasComma: Bool) {
        self.hasComma = hasComma
        commaButton?.setTitle(hasComma ? "." : "", for: .normal)
    }
 
}

extension PaymentInputViewController: PinViewControllerDelegate {
    
    func onPushValid() {
        presenter?.didPushValid(amountStr)
    }
    
    
    func onPushPin(_ pin: String) {
        if amountStr.count > 12 {
            return
        }
        
        switch pin {
        case ".":
            if amountStr.contains(pin) {
                return
            }
            amountStr.append(pin)
            presenter?.didSetAmount(amountStr)
        case "del":
            if amountStr.count > 1 {
                amountStr.removeLast()
            } else {
                amountStr = "0"
            }
            presenter?.didSetAmount(amountStr)
        case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
            let range = amountStr.range(of: ".")
            if let r = range {
                let decimals = amountStr[r.upperBound..<amountStr.endIndex]
                if decimals.count >= 2 {
                    return // already has 2 decimals
                }
            }
            if amountStr.count < 1 || amountStr == "0" {
                amountStr = pin
            } else {
                amountStr.append(pin)
            }
            presenter?.didSetAmount(amountStr)
        default: break
        }
    }
}

extension PaymentInputViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CirclePresentAnimationController(originFrame: amountLabel.frame)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let navVC = dismissed as? UINavigationController
            , let toVC = navVC.viewControllers.first as? PaymentRequestViewController else {
            return nil
        }
        return CircleDismissAnimationController(originFrame: amountLabel.frame, interactionController: toVC.interactionController)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let animator = animator as? CircleDismissAnimationController,
            let interactionController = animator.interactionController,
            interactionController.interactionInProgress
            else {
                return nil
        }
        return interactionController
    }
}
