//
//  SubscriptionInfoViewController.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 9/16/17.
//  Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.
//

import UIKit

class SubscriptionInfoViewController: UIViewController {

    @IBOutlet weak var serviceLabel: UILabel!

    @IBOutlet weak var lengthLabel: UILabel!

    @IBOutlet weak var priceLabel: UILabel!

    @IBOutlet weak var descriptionTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        getProductInfo()
        setUpUI()
    }

    func setUpUI() {
        descriptionTextView.text = NSLocalizedString("Text_Subscription_Terms", comment: "")
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
    }

    override func viewDidLayoutSubviews() {
        descriptionTextView.setContentOffset(CGPoint.zero, animated: false)
    }

    func getProductInfo() {
        SubscriptionManager.shared.getProductForId(productId: "Vhista_Full", { (product) in
            if product != nil {

                self.serviceLabel.text = NSLocalizedString("Service", comment: "") + ": " + product!.localizedTitle
                self.lengthLabel.text = NSLocalizedString("Monthly", comment: "")
                self.priceLabel.text = NSLocalizedString("Price", comment: "") + ": " + product!.localizedPrice!

            } else {
            }
        })
    }

    @IBAction func dismissView(_ sender: Any) {
        VhistaSpeechManager.shared.blockAllSpeech = false
        self.dismiss(animated: false, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
