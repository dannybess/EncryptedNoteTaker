//
//  NoteTakerViewController.swift
//  NoteTaker
//
//  Created by Daniel Bessonov on 19/12/2016.
//  Copyright © 2016 Daniel Bessonov. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class NoteTakerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var notesArray: [Note] = []
    var licenseKeys : [License] = []
    
    var audioPlayer = AVAudioPlayer()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 57
        
        tableView.delegate = self
        tableView.dataSource = self
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
    
    // activate license key
    @IBAction func activateClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Activate Key", message: "Please enter your name!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainerLicense.viewContext
            let request = NSFetchRequest<License>(entityName: "License")
            self.licenseKeys = try! context.fetch(request)
            let rehashedKey = self.sha256(string: alert.textFields![0].text! + "secretKey")! as NSData
            if(self.linearSearch(array: self.licenseKeys, value: rehashedKey)) {
                print("got em")
                emojiEnabled = true
                let alert = UIAlertController(title: "Success", message: "You can now save emojis!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertController(title: "Error", message: "Oops! Looks like you haven't registered a license key yet!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }))
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Please Enter Your Full Name"
        }
        self.present(alert, animated: true, completion: nil)
    }
    //82756
    func linearSearch(array : [License], value : NSData) -> Bool {
        for key in array {
            if(key.key!.isEqual(value)) {
                return true
            }
        }
        return false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<Note>(entityName: "Note")
        self.notesArray = try! context.fetch(request)
        self.tableView.allowsSelection = false
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sound = notesArray[indexPath.row]
        let cell = UITableViewCell()
        do {
            let originalData = try RNCryptor.decrypt(data: sound.name, withPassword: "Secret password")
            var convertedString = (String(data: originalData, encoding: String.Encoding.utf8))!.mutableCopy() as! NSMutableString
            CFStringTransform(convertedString, nil, "Any-Hex/Java" as NSString, true)
            if(String(convertedString) == String(data: originalData, encoding: String.Encoding.utf8)) {
                cell.textLabel!.text = String(data: originalData, encoding: String.Encoding.utf8)!
            }
            else {
                cell.textLabel!.text = String(convertedString)
            }
        }
        catch {
            print(error)
        }
        let font = UIFont(name: "Avenir-Book", size: 16)
        let color = UIColor(red:0.00, green:0.00, blue:0.00, alpha:0.4)
        cell.textLabel?.font = font
        cell.textLabel?.textColor = color
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
        case .delete:
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            context.delete(notesArray[indexPath.row] as NSManagedObject)
            notesArray.remove(at: indexPath.row)
            do {
                try context.save()
            } catch let error as NSError {
                
            }
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        default:
            return
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
