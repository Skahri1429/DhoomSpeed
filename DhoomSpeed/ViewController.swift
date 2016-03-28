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
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, AVAudioPlayerDelegate, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager?

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
    
    func createLocationManager(startImmediately startImmediately: Bool) {
        locationManager = CLLocationManager()
        if let manager = locationManager {
            print("Successfully created the location manager")
            manager.delegate = self
            if startImmediately {
                manager.startUpdatingLocation()
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("The authorization status of location services is changed to: ")
        
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways:
            print("Authorized Always")
        case .AuthorizedWhenInUse:
            print("Authorized When in Use")
        case .Denied:
            print("Denied")
        case .NotDetermined:
            print("Not Determined")
        case .Restricted:
            print("Restricted")
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("location manager failed with error: \(error)")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let speed = manager.location?.speed {
            //convert from m/s to mph
            let msSpeed = Double(speed)
            let mphSpeed = msSpeed * 2.23694
            //assign currentSpeed to speed
            currentSpeed = mphSpeed
        }
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
    
    func displayAlertWithTitle(title: String, message: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        presentViewController(controller, animated: true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .AuthorizedAlways:
                createLocationManager(startImmediately: true)
            case .AuthorizedWhenInUse:
                createLocationManager(startImmediately: true)
            case .Denied:
                displayAlertWithTitle("Location not determined", message: "Location services are disabled for this app")
            case .NotDetermined:
                createLocationManager(startImmediately: false)
                if let manager = self.locationManager {
                    manager.requestWhenInUseAuthorization()
                }
            case .Restricted:
                displayAlertWithTitle("Location restricted", message: "Location services are not allowed for this app")
            }
        } else {
            let controller = UIAlertController(title: "Location services disabled", message: "Please enable location services", preferredStyle: .Alert)
            controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            
            let openAction = UIAlertAction(title: "Settings", style: .Default) { (action) in
                if let url = NSURL(string: "prefs:root=LOCATION_SERVICES") {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            controller.addAction(openAction)
        }
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

