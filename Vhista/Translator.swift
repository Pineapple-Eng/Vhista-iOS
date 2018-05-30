//
//  Translator.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 3/2/17.
//  Copyright © 2017 Juan David Cruz. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func translateString(pString: String, targetLanguage: String,  _ completition: @escaping (_ success: String?) -> ()) {
        
        let translationURI: String = "https://translation.googleapis.com/language/translate/v2"
        
        let toTranslateString:String = pString
        
        manager.get(translationURI, parameters: ["key":"AIzaSyBnIbEbBeYuN6Zk4XeFE3gN3NtHf-Hznhk", "source":"en", "target":targetLanguage, "q":toTranslateString], progress: { (progress) in
            
        }, success: { (task: URLSessionDataTask, response) in
            
            let dictionaryResponse: NSDictionary = response! as! NSDictionary
            let dictionaryData: NSDictionary = dictionaryResponse.object(forKey: "data")! as! NSDictionary
            let arrayTranslations: NSArray = dictionaryData.object(forKey: "translations")! as! NSArray
            
            if arrayTranslations.count > 0 {
                let arraySingleTranslation: NSDictionary = arrayTranslations.object(at: 0) as! NSDictionary
                let resultString: String = arraySingleTranslation.object(forKey: "translatedText") as! String
                completition(resultString)
            } else {
                completition(nil)
                
            }
            
        }) { (task: URLSessionDataTask?, error: Error) in
            
            print("Error Task: \(task)  -- Error Response: \(error) ")
            completition(nil)
        }
        
        
    }
}
