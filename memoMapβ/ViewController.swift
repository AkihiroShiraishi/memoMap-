//
//  ViewController.swift
//  memoMapβ
//
//  Created by 白石晃大 on 2021/02/23.
//

import UIKit
import MapKit

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var searchInputText: UITextField!
    @IBOutlet weak var dispMap: MKMapView!
    var locationManager: CLLocationManager!
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchInputText.delegate = self
        
        // locationManager生成
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        if(CLLocationManager.locationServicesEnabled() != true){
//            //　位置情報サービスがOFFの場合
//            alertMessage(message: "位置情報サービスがONになっていないため、現在地情報取得が利用できません。「設定」⇒「プライバシー」⇒「位置情報サービス」")
//        }
    }

    //メッセージ出力メソッド
    func alertMessage(title:String, message:String) {
        let aleartController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title:"OK", style: .default, handler:nil)
        aleartController.addAction(defaultAction)

        present(aleartController, animated:true, completion:nil)

    }

    // 現在地情報取得許諾変更された際に通知
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            break
        case .notDetermined, .denied, .restricted:
            if(CLLocationManager.locationServicesEnabled() == true){
                self.displayDialogOfLocationAuth()
            } else {
                //　位置情報サービスがOFFの場合
                alertMessage(title:"注意", message: "位置情報サービスがONになっていないため、現在地情報取得が利用できません。「設定」⇒「プライバシー」⇒「位置情報サービス」")
            }
            break
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        let latitude = location?.coordinate.latitude
        let longitude = location?.coordinate.longitude
        // 位置情報を格納する
        self.latitude = latitude!
        self.longitude = longitude!
    }

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
                } else {
                    // 検索した場所が見つからなかった場合
                    self.alertMessage(title:"", message: "\(searchKey)に各当する場所は見つかりませんでした。")
                }
            })
        }
        return true
    }

    func displayDialogOfLocationAuth() {
        let dialog = UIAlertController(title: "現在地情報の取得が許可されていません。", message: "", preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
              return
            }
            if UIApplication.shared.canOpenURL(settingsUrl)  {
              if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Open \(success)")
                })
              }
              else  {
                UIApplication.shared.openURL(settingsUrl)
              }
            }
        }))
        dialog.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        // 生成したダイアログを実際に表示します
        self.present(dialog, animated: true, completion: nil)
    }

    @IBAction func currentLocation(_ sender: Any) {
        if (CLLocationManager.locationServicesEnabled() != true) {
            alertMessage(title:"注意", message: "位置情報サービスがONになっていないため、現在地情報取得が利用できません。「設定」⇒「プライバシー」⇒「位置情報サービス」")
        }

        if locationManager.authorizationStatus == .notDetermined || locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
            self.displayDialogOfLocationAuth()
        } else {
            let location = CLLocationCoordinate2DMake(self.latitude, self.longitude)
            let pin = MKPointAnnotation()

            pin.coordinate = location

            pin.title = "現在地"

            self.dispMap.addAnnotation(pin)

            self.dispMap.region = MKCoordinateRegion(center: location, latitudinalMeters: 500.0, longitudinalMeters: 500.0)
        }
    }
}

