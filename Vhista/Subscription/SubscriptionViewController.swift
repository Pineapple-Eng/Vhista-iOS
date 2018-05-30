//
//  SubscriptionViewController.swift
//  Vhista
//
//  Created by David Cruz on 3/5/18.
//  Copyright © 2018 juandavidcruz. All rights reserved.
//

import UIKit
import StoreKit

class SubscriptionViewController: UIViewController {
    
    @IBOutlet weak var serviceLabel: UILabel!
    
    @IBOutlet weak var subscriptionDescTextView: UITextView!
    
    @IBOutlet weak var lengthLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var buyButton: UIButton!
    
    @IBOutlet weak var restoreButton: UIButton!
    
//    @IBOutlet weak var loadingPurchaseView: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        SubscriptionManager.shared.parent = self
        setUpUI()
        getSubscriptionInfo()
    }
    
    override func viewDidLayoutSubviews() {
        //TextView Scrolling Fix
        subscriptionDescTextView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    func setUpUI() {
        
        subscriptionDescTextView.text = NSLocalizedString("Text_Subscription_Terms", comment: "")
        
    }
    
    func getSubscriptionInfo() {
        SubscriptionManager.shared.getProductForId(productId: "Vhista_Full", { (product) in
            if product != nil {
                self.serviceLabel.text = product!.localizedTitle
                self.lengthLabel.text = NSLocalizedString("Monthly", comment: "")
                self.priceLabel.text = product!.localizedPrice!
            } else {
                self.serviceLabel.text = "Unlimited Deep Image Analysis"
                self.lengthLabel.text = NSLocalizedString("Monthly", comment: "")
                self.priceLabel.text = "3.99USD"
            }
        })
    }
    
    @IBAction func acceptBuy(_ sender: Any) {
        deactivateBuyButtons()
        self.recordAnalyticsViewController(analyticsEventName: AnalyticsConstants().BuyButtonSubscription, parameters: [
            "language": global_language as NSObject
            ])
        SubscriptionManager.shared.purchaseSKProductWithID(productId: "Vhista_Full")
        
    }
    
    @IBAction func restoreSubscription(_ sender: Any) {
        deactivateBuyButtons()
        self.recordAnalyticsViewController(analyticsEventName: AnalyticsConstants().RestoreButtonSubscription, parameters: [
            "language": global_language as NSObject
            ])
        SubscriptionManager.shared.restoreSubscriptions()
    }
    
    @IBAction func cancelSubscription(_ sender: Any) {
        deactivateBuyButtons()
        self.recordAnalyticsViewController(analyticsEventName: AnalyticsConstants().CancelButtonSubscription, parameters: [
            "language": global_language as NSObject
            ])
        self.didEndPurchaseProcess()
    }
    
    
    func activateBuyButtons() {
//        loadingPurchaseView.isHidden = true
        buyButton.isEnabled = true
        buyButton.isAccessibilityElement = true
        restoreButton.isEnabled = true
        restoreButton.isAccessibilityElement = true
    }
    
    func deactivateBuyButtons() {
//        loadingPurchaseView.isHidden = false
        buyButton.isEnabled = false
        buyButton.isAccessibilityElement = false
        restoreButton.isEnabled = false
        restoreButton.isAccessibilityElement = false
    }
    
    func didEndPurchaseProcess() {
        activateBuyButtons()
        self.navigationController?.popViewController(animated: true)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
