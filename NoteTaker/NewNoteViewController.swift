//
//  NewNoteViewController.swift
//  NoteTaker
//
//  Created by Shane Doyle on 07/01/2017.
//  Copyright © 2017 Shane Doyle. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class NewNoteViewController: UIViewController {
    
    
    @IBOutlet weak var noteTitle: UITextField!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var peakLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var peakImageView: UIImageView!
    
    @IBOutlet weak var averageImageView: UIImageView!
    
    
    var audioURL : String = ""
    var audioRecorder : AVAudioRecorder!
    var timerInterval : TimeInterval = 0.5
    var audioPlayer : AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: noteTitle.frame.height - 1, width: noteTitle.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor.white.cgColor
        noteTitle.borderStyle = UITextBorderStyle.none
        noteTitle.layer.addSublayer(bottomLine)        
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        
        if (noteTitle.text != "") {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
            let data : NSData = noteTitle.text!.data(using: String.Encoding.nonLossyASCII) as! NSData
            let password = "Secret password"
            let cipherText = RNCryptor.encrypt(data: data as Data, withPassword: password)
            print("Hellowordl")
            note.name = cipherText as Data
            //note.url = audioURL
        
            do {
                try context.save()
            } catch let saveError as NSError {
                print("Save error: \(saveError.localizedDescription)")
            }
            
        }
        
        self.dismiss(animated: true, completion: nil)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
