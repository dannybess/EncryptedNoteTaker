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
    
    required init?(coder aDecoder: NSCoder) {
        let baseString : String = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as String
        self.audioURL = NSUUID().uuidString + ".m4a"
        let pathComponents = [baseString, self.audioURL]
        let audioNSURL = NSURL.fileURL(withPathComponents: pathComponents)!
        let session = AVAudioSession.sharedInstance()
        
        let recordSettings : [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 2 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
        
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            self.audioRecorder = try AVAudioRecorder(url: audioNSURL, settings: recordSettings)
        } catch let initError as NSError {
            print("Init error: \(initError.localizedDescription)")
        }
        
        self.audioRecorder.isMeteringEnabled = true
        self.audioRecorder.prepareToRecord()
        
        super.init(coder: aDecoder)
    }
    
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
    
    @IBAction func record(_ sender: Any) {
        
        let mic = UIImage(named: "micbtnwhite.png") as UIImage!
        recordButton.setImage(mic, for: .normal)
        
        if (audioRecorder.isRecording) {
            let mic = UIImage(named: "micpinkbtn.png") as UIImage!
            recordButton.setImage(mic, for: .normal)
            
            audioRecorder.stop()
        } else {
            let session = AVAudioSession.sharedInstance()
            
            do {
                try session.setActive(true)
                audioRecorder.record()
            } catch let recordError as NSError {
                print("Record error: \(recordError.localizedDescription)")
            }
            
        }
    }
    
    @IBAction func touchDownRecord(_ sender: Any) {
        
        audioPlayer = getAudioPlayerFile(file: "beep1", type: "mp3")
        audioPlayer.play()
        
        let timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(self.updateAudioMeter), userInfo: nil, repeats: true)
        
        timer.fire()
    }
    
    func updateAudioMeter(timer: Timer) {
        if audioRecorder.isRecording {
            
            let dFormat = "%02d"
            let min:Int = Int(audioRecorder.currentTime / 60)
            let sec:Int = Int(audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
            let timeString = "\(String(format: dFormat, min)):\(String(format: dFormat, sec))"
            timeLabel.text = timeString
            audioRecorder.updateMeters()
            
            let averageAudio = audioRecorder.averagePower(forChannel: 0) * -1
            let peakAudio = audioRecorder.peakPower(forChannel: 0) * -1
            let progressViewAverage = Int(averageAudio)
            let progressViewPeak = Int(peakAudio)
            
            progressLabel.text = "\(progressViewAverage)%"
            peakLabel.text = "\(progressViewPeak)%"
            
            averageRadial(average: progressViewAverage, peak: progressViewPeak)
            
        } else {
            averageImageView.image = UIImage(named: "peak/peak0suffix.png")
            peakImageView.image = UIImage(named: "peak/peak0suffix.png")
            progressLabel.text = "0%"
            peakLabel.text = "0%"
            crossfadeTransition()
        }
    }
    
    func averageRadial(average: Int, peak: Int) {
        
        switch average {
        case average:
            averageImageView.image = UIImage(named: "average/average\(String(average))suffix.png")
            crossfadeTransition()
        default:
            averageImageView.image = UIImage(named: "peak/peak0suffix.png")
            crossfadeTransition()
        }
        
        switch peak {
        case peak:
            peakImageView.image = UIImage(named: "peak/peak\(String(average))suffix.png")
            crossfadeTransition()
        default:
            peakImageView.image = UIImage(named: "peak/peak0suffix.png")
            crossfadeTransition()
        }
        
    }
    
    func crossfadeTransition() {
        let transition = CATransition()
        transition.type = kCATransitionFade
        transition.duration = 0.2
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        view.layer.add(transition, forKey: nil)
    }
    
    
    func getAudioPlayerFile(file: String, type: String) -> AVAudioPlayer {
        let path = Bundle.main.path(forResource: file as String, ofType: type as String)
        let url = NSURL.fileURL(withPath: path!)
        var audioPlayer:AVAudioPlayer?
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: url)
        } catch let audioPlayerError as NSError {
            print("Failed to initialise audio player error: \(audioPlayerError.localizedDescription)")
        }
        
        return audioPlayer!
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
