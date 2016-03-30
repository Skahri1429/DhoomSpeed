//
//  LocationViewController.swift
//  DhoomSpeed
//
//  Created by Pankaj Khillon on 3/30/16.
//  Copyright © 2016 Sarthak Khillon. All rights reserved.
//

import UIKit
import CoreLocation

class LocationViewController: UIViewController, CLLocationManagerDelegate {
    var currentSpeed = 0.0
    let manager = CLLocationManager()

    func createLocationManager(startImmediately startImmediately: Bool) {
        print("Successfully created the location manager")
        manager.delegate = self
        if startImmediately {
            manager.startUpdatingLocation()
        }
        
    }
    
    func displayAlertWithTitle(title: String, message: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        presentViewController(controller, animated: true, completion: nil)
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


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
                manager.requestWhenInUseAuthorization()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "main" {
            if let destVC = segue.destinationViewController as? MainViewController {
                destVC.currentSpeed = self.currentSpeed
            }
        }
    }


}
