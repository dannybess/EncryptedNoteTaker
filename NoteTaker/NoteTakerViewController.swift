//
//  NoteTakerViewController.swift
//  NoteTaker
//
//  Created by Shane Doyle on 19/12/2016.
//  Copyright © 2016 Shane Doyle. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class NoteTakerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var notesArray: [Note] = []
    
    var audioPlayer = AVAudioPlayer()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 57
        
        tableView.delegate = self
        tableView.dataSource = self
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
            cell.textLabel!.text = String(data: originalData, encoding: String.Encoding.utf8)!
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
