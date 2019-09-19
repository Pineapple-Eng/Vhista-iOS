//
//  SubscriptionViewController.swift
//  Vhista
//
//  Created by David Cruz on 3/5/18.
//  Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.
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

    @IBOutlet weak var freeButton: UIButton!

//    @IBOutlet weak var loadingPurchaseView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        SubscriptionManager.shared.parent = self
        setUpUI()
        getSubscriptionInfo()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.presentingViewController is ARKitCameraViewController {
            (self.presentingViewController as? ARKitCameraViewController)?.resumeCurrentSession()
        }
    }

    override func viewDidLayoutSubviews() {
        //TextView Scrolling Fix
        subscriptionDescTextView.setContentOffset(CGPoint.zero, animated: false)
    }

    func setUpUI() {
        self.title = NSLocalizedString("Subscribe_Nav_Title", comment: "")
        freeButton.isHidden = !SubscriptionManager.shared.canRequestFreeImages
        subscriptionDescTextView.text = NSLocalizedString("Text_Subscription_Terms", comment: "")
    }

    func getSubscriptionInfo() {
        SubscriptionManager.shared.getProductForId(productId: "Vhista_Full", { (product) in
            if product != nil {
                self.serviceLabel.text = NSLocalizedString("Service", comment: "") + ": " + product!.localizedTitle
                self.lengthLabel.text = NSLocalizedString("Monthly", comment: "")
                self.priceLabel.text = NSLocalizedString("Price", comment: "") + ": " + product!.localizedPrice!
            } else {
                self.serviceLabel.text = NSLocalizedString("Service", comment: "") + ": " + "Unlimited Deep Image Analysis"
                self.lengthLabel.text = NSLocalizedString("Monthly", comment: "")
                self.priceLabel.text = NSLocalizedString("Price", comment: "") + ": " + "Error Loading Price"
            }
        })
    }

    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func acceptBuy(_ sender: Any) {
        deactivateBuyButtons()
        recordAnalytics(analyticsEventName: AnalyticsConstants.BuyButtonSubscription,
                        parameters: nil)
        SubscriptionManager.shared.purchaseSKProductWithID(productId: "Vhista_Full")

    }

    @IBAction func restoreSubscription(_ sender: Any) {
        deactivateBuyButtons()
        recordAnalytics(analyticsEventName: AnalyticsConstants.RestoreButtonSubscription,
                        parameters: nil)
        SubscriptionManager.shared.restoreSubscriptions()
    }

    @IBAction func getFreeSubscription(_ sender: Any) {
        recordAnalytics(analyticsEventName: AnalyticsConstants.RequestedMoreFreeImages,
                        parameters: nil)
        let defaults = UserDefaults.standard
        let numberOfPictures = defaults.integer(forKey: "PicturesTaken")
        let totalPictures = defaults.integer(forKey: "TotalPicturesTaken")
        if numberOfPictures < 5 {
            showAlertTrialRemaining(5 - numberOfPictures)
            return
        }
        let alertController = UIAlertController(title: NSLocalizedString("Free_Subscription_Confirmation_Title", comment: ""),
                                                message: NSLocalizedString("Free_Subscription_Confirmation_Body", comment: ""),
                                                preferredStyle: .alert)
        let actionClose = UIAlertAction(title: NSLocalizedString("Close_Action", comment: ""),
                                        style: .default) { (_) in
                                            defaults.set(0, forKey: "PicturesTaken")
                                            recordAnalytics(analyticsEventName: AnalyticsConstants.GrantedMoreFreeImages,
                                                            parameters: [
                                                                "totalPictures": "\(totalPictures)"
                                            ])
                                            self.didEndPurchaseProcess(shouldDismiss: true)
        }
        alertController.addAction(actionClose)
        self.present(alertController, animated: true, completion: nil)
    }

    func showAlertTrialRemaining(_ remainingImages: Int) {
        var localizedStringId = "Free_Subscription_Still_On_Trial"
        if remainingImages == 1 {
            localizedStringId = "Free_Subscription_Still_On_Trial_Single"
        }
        let title = NSLocalizedString(localizedStringId, comment: "").replacingOccurrences(of: "#", with: "\(remainingImages)")
        let alertController = UIAlertController(title: title,
                                                message: NSLocalizedString("Free_Subscription_Still_On_Trial_Body", comment: ""),
                                                preferredStyle: .alert)
        let actionClose = UIAlertAction(title: NSLocalizedString("Close_Action", comment: ""),
                                        style: .default, handler: nil)
        alertController.addAction(actionClose)
        self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func cancelSubscription(_ sender: Any) {
        deactivateBuyButtons()
        recordAnalytics(analyticsEventName: AnalyticsConstants.CancelButtonSubscription,
                        parameters: nil)
        self.didEndPurchaseProcess(shouldDismiss: true)
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

    func didEndPurchaseProcess(shouldDismiss: Bool) {
        activateBuyButtons()
        if shouldDismiss {
            self.dismiss(animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
