//
//  ActivateViewController.swift
//  NoteTaker
//
//  Created by Daniel Bessonov on 6/28/17.
//  Copyright © 2017 Shane Doyle. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class RegisterViewController : UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var licenseKeyTextField: UITextField!
    
    let secret = "18asf902"
    
    override func viewDidLoad() {
        
    }
    
    // hash string with sha256
    func sha256(string: String) -> Data? {
        guard let messageData = string.data(using:String.Encoding.utf8) else { return nil; }
        var digestData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_SHA256(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        return digestData
    }
    
    // generate random String with length of N
    func generateRandomKey(length: Int) -> String {
        let letters : NSString = "0123456789"
        let len = UInt32(letters.length)
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
    
    func bytes2String(_ array: [UInt8]) -> String {
        return String(data: Data(bytes: array, count: array.count), encoding: .utf8) ?? ""
    }
    
    func validHashGen(val : String) -> Data {
        var initial = sha256(string: val + secret)! as Data
        var backToString = initial.map { String(format: "%02x", $0) }.joined()
        for i in 0..<4 {
            initial = sha256(string: backToString as String)! as Data
            backToString = initial.map { String(format: "%02x", $0) }.joined()
        }
        return initial as Data
    }
 
    @IBAction func doneClicked(_ sender: Any) {
        if(self.nameTextField.text != "") {
            let hash = validHashGen(val: self.nameTextField.text!)
            let hashString = hash.map { String(format: "%02x", $0) }.joined()
            if(hashString == licenseKeyTextField!.text!) {
                emojiEnabled = true
                let alert = UIAlertController(title: "Success", message: "You are now verified", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
                    self.performSegue(withIdentifier: "goBackToHome", sender: self)
                }))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                print(hashString)
                let alert = UIAlertController(title: "Error", message: "Your license key does not match!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        
    }
}

