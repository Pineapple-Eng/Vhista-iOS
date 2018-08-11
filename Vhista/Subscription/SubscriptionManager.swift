//
//  SubscriptionManager.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 9/14/17.
//  Copyright © 2017 juandavidcruz. All rights reserved.
//

import Foundation
import SwiftyStoreKit
import StoreKit

class SubscriptionManager: NSObject {
    
    var parent: SubscriptionViewController!
    
    // MARK: - Initialization Method
    override init() {
        super.init()
    }
    
    static let shared: SubscriptionManager = {
        let instance = SubscriptionManager()
        return instance
    }()
    
    func checkDeepSubscription() -> Bool {
        let defaults = UserDefaults.standard
        let numberOfPictures = defaults.integer(forKey: "PicturesTaken")
        if numberOfPictures <= 2 {
            defaults.set(numberOfPictures + 1, forKey: "PicturesTaken")
            print("🔢 Number of pictures taken: " + String(numberOfPictures + 1))
            return true
        } else {
            if isUserSubscribedToFullAccess() {
                return true
            } else {
                return false
            }
        }
    }
    
    func completeTransactions() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                if purchase.transaction.transactionState == .purchased || purchase.transaction.transactionState == .restored {
                    let defaults = UserDefaults.standard
                    defaults.set(true, forKey: "IsSubscribed")
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    print("Purchased: \(purchase)")
                    if self.parent != nil {
                        self.parent.didEndPurchaseProcess()
                    }
                }
            }
        }
    }
    
    func isUserSubscribedToFullAccess() -> Bool {
        let defaults = UserDefaults.standard
        let isSubscribed = defaults.bool(forKey: "IsSubscribed")
        print("SUBCRIBED: \(isSubscribed)")
        return isSubscribed
    }
    
    func getProductForId(productId:String,_ completition: @escaping (_ success: SKProduct?) -> ()) {
        SwiftyStoreKit.retrieveProductsInfo([productId]) { result in
            if let product = result.retrievedProducts.first {
                completition(product)
            } else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
                self.parent.didEndPurchaseProcess()
                completition(nil)
            } else {
                print("Error: \(String(describing: result.error))")
                self.parent.didEndPurchaseProcess()
                completition(nil)
            }
        }
    }
    
    func purchaseSKProductWithID (productId: String) {
        getProductForId(productId: productId) { (product:SKProduct?) in
            if product != nil {
                self.purchaseProduct(product: product!, productId: productId)
            } else {
                self.parent.didEndPurchaseProcess()
            }
        }
    }
    
    func purchaseProduct (product: SKProduct, productId: String) {
        SwiftyStoreKit.purchaseProduct(product) { (result: PurchaseResult) in
            if case .success(let purchase) = result {
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                self.verifySubscription(productId: productId)
            } else {
                // purchase error
                self.parent.didEndPurchaseProcess()
            }
        }
    }
    
    func verifySubscription(productId: String) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: AppleReceiptValidatorSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            
            if case .success(let receipt) = result {
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable,
                    productId: productId,
                    inReceipt: receipt)
                let defaults = UserDefaults.standard
                switch purchaseResult {
                case .purchased(let expiryDate, let receiptItems):
                    print("Product is valid until \(expiryDate) with receipt items: \(receiptItems)")
                    VhistaSpeechManager.shared.blockAllSpeech = false
                    defaults.set(true, forKey: "IsSubscribed")
                    self.parent.didEndPurchaseProcess()
                case .expired(let expiryDate, let receiptItems):
                    print("Product is expired since \(expiryDate) with receipt items: \(receiptItems)")
                    defaults.set(false, forKey: "IsSubscribed")
                    let alert = UIAlertController(title: NSLocalizedString("Title_Product_Expired", comment: ""), message: NSLocalizedString("Message_Product_Expired", comment: ""), preferredStyle: .alert)
                    
                    let actionClose = UIAlertAction(title: NSLocalizedString("Close_Action", comment: ""), style: .cancel, handler: { (alertAction) in
                        self.parent.didEndPurchaseProcess()
                    })
                    
                    alert.addAction(actionClose)
                    
                    self.parent.present(alert, animated: true, completion: nil)
                    self.parent.didEndPurchaseProcess()
                case .notPurchased:
                    print("This product has never been purchased")
                    defaults.set(false, forKey: "IsSubscribed")
                    let alert = UIAlertController(title: NSLocalizedString("Title_Never_Purchased", comment: ""), message: NSLocalizedString("Message_Never_Purchased", comment: ""), preferredStyle: .alert)
                    
                    let actionClose = UIAlertAction(title: NSLocalizedString("Close_Action", comment: ""), style: .cancel, handler: { (alertAction) in
                        self.parent.didEndPurchaseProcess()
                    })
                    
                    alert.addAction(actionClose)
                    
                    self.parent.present(alert, animated: true, completion: nil)
                    self.parent.didEndPurchaseProcess()
                }
                
            } else {
                // receipt verification error
                self.verifyTestSubscription(productId: productId)
            }
        }
    }
    
    func verifyTestSubscription(productId: String) {
        let appleValidator = AppleReceiptValidator(service: .sandbox, sharedSecret: AppleReceiptValidatorSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            
            if case .success(let receipt) = result {
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable,
                    productId: productId,
                    inReceipt: receipt)
                let defaults = UserDefaults.standard
                switch purchaseResult {
                case .purchased(let expiryDate, let receiptItems):
                    print("Product is valid until \(expiryDate) with receipt items: \(receiptItems)")
                    VhistaSpeechManager.shared.blockAllSpeech = false
                    defaults.set(true, forKey: "IsSubscribed")
                    self.parent.didEndPurchaseProcess()
                case .expired(let expiryDate, let receiptItems):
                    print("Product is expired since \(expiryDate) with receipt items: \(receiptItems)")
                    defaults.set(false, forKey: "IsSubscribed")
                    let alert = UIAlertController(title: NSLocalizedString("Title_Product_Expired", comment: ""), message: NSLocalizedString("Message_Product_Expired", comment: ""), preferredStyle: .alert)
                    
                    let actionClose = UIAlertAction(title: NSLocalizedString("Close_Action", comment: ""), style: .cancel, handler: { (alertAction) in
                        self.parent.didEndPurchaseProcess()
                    })
                    
                    alert.addAction(actionClose)
                    
                    self.parent.present(alert, animated: true, completion: nil)
                    self.parent.didEndPurchaseProcess()
                case .notPurchased:
                    print("This product has never been purchased")
                    defaults.set(false, forKey: "IsSubscribed")
                    let alert = UIAlertController(title: NSLocalizedString("Title_Never_Purchased", comment: ""), message: NSLocalizedString("Message_Never_Purchased", comment: ""), preferredStyle: .alert)
                    
                    let actionClose = UIAlertAction(title: NSLocalizedString("Close_Action", comment: ""), style: .cancel, handler: { (alertAction) in
                        self.parent.didEndPurchaseProcess()
                    })
                    
                    alert.addAction(actionClose)
                    
                    self.parent.present(alert, animated: true, completion: nil)
                    self.parent.didEndPurchaseProcess()
                }
                
            } else {
                // receipt verification error
                self.parent.didEndPurchaseProcess()
            }
        }
    }
    
    func restoreSubscriptions() {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
                
                let alert = UIAlertController(title: NSLocalizedString("Title_Restore_Failed", comment: ""), message: NSLocalizedString("Message_Restore_Failed", comment: ""), preferredStyle: .alert)
                
                let actionClose = UIAlertAction(title: NSLocalizedString("Close_Action", comment: ""), style: .cancel, handler: { (alertAction) in
                    self.parent.didEndPurchaseProcess()
                })
                
                alert.addAction(actionClose)
                
                self.parent.present(alert, animated: true, completion: nil)
                
            }
            else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
                self.verifySubscription(productId: "Vhista_Full")
            }
            else {
                print("Nothing to Restore")
                
                let alert = UIAlertController(title: NSLocalizedString("Title_Nothing_To_Restore", comment: ""), message: NSLocalizedString("Message_Nothing_To_Restore", comment: ""), preferredStyle: .alert)
                
                let actionClose = UIAlertAction(title: NSLocalizedString("Close_Action", comment: ""), style: .cancel, handler: { (alertAction) in
                    self.parent.didEndPurchaseProcess()
                })
                
                alert.addAction(actionClose)
                
                self.parent.present(alert, animated: true, completion: nil)
                
                
            }
        }
    }
}

