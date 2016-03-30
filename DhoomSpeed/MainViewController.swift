//
//  ViewController.swift
//  DhoomSpeed
//
//  Created by Pankaj Khillon on 3/27/16.
//  Copyright © 2016 Sarthak Khillon. All rights reserved.
//

// get permission for location

import UIKit
import AVFoundation

class MainViewController: UIViewController, UITextFieldDelegate, AVAudioPlayerDelegate {
    
    var listening = true
    var audioPlayer: AVAudioPlayer?
    var triggerSpeed = 80.0
    var currentSpeed = 0.0
    
    @IBOutlet weak var speedTextField: UITextField!
    @IBOutlet weak var currentSpeedLabel: UILabel!
    @IBOutlet weak var triggerSpeedLabel: UILabel!
    
    @IBAction func enableListening(sender: AnyObject) { listening = true }
    
    @IBAction func playAudio(sender: AnyObject) { dhoomMachale() }
    
    @IBAction func disableListening(sender: AnyObject) { listening = false }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        print("Finished playing the song")
    }
    
    func dhoomMachale() -> Void {
        let dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(dispatchQueue, {[weak self] in
            let mainBundle = NSBundle.mainBundle()
            let filePath = mainBundle.pathForResource("Dhoom Theme", ofType: "mp3")
            
            if let path = filePath {
                let fileData = NSData(contentsOfFile: path)
                
                do {
                    self!.audioPlayer = try AVAudioPlayer(data: fileData!)
                } catch {
                    print("ERROR: could not assign audioPlayer")
                }
                
                if let player = self!.audioPlayer {
                    player.delegate = self
                    if player.prepareToPlay() && player.play() {
                        print("SUCCESSFULLY PLAYING")
                    } else {
                        print("ERROR: Failed to play")
                    }
                } else {
                    print("ERROR: Failed to instantiate AVAudioPlayer with file data")
                }
            }
            })
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let text = textField.text {
            if text != "" {
                triggerSpeed = Double(text)!
            } else {
                triggerSpeed = 80.0
            }
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speedTextField.text = "80"
        
        if currentSpeed > 0 {
            currentSpeedLabel.text = "\(currentSpeed)"
            if listening && currentSpeed > triggerSpeed { dhoomMachale() }
        } else {
            print("Location not yet received")
        }
        
    }
}