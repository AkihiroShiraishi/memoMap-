//
//  ViewController.swift
//  memoMapβ
//
//  Created by 白石晃大 on 2021/02/23.
//

import UIKit
import MapKit

class ViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchInputText.delegate = self
        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var searchInputText: UITextField!
    @IBOutlet weak var dispMap: MKMapView!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if let searchKey = textField.text {
            print(searchKey)
            
            let geocoder = CLGeocoder()
            
            geocoder.geocodeAddressString(searchKey, completionHandler: {
                (placemarks, error) in
                
                if let unwrapPlacemarks = placemarks {
                    if let firstPlacemark = unwrapPlacemarks.first {
                        if let location =  firstPlacemark.location {
                            let targetCoordinate = location.coordinate
                            
                            print(targetCoordinate)
                            
                            let pin = MKPointAnnotation()
                            
                            pin.coordinate = targetCoordinate
                            
                            pin.title = searchKey
                            
                            self.dispMap.addAnnotation(pin)
                            
                            self.dispMap.region = MKCoordinateRegion(center: targetCoordinate, latitudinalMeters: 500.0, longitudinalMeters: 500.0)
                        }
                    }
                }
            })
        }
        return true
    }
}

