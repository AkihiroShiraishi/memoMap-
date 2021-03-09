//
//  ViewController.swift
//  memoMapβ
//
//  Created by 白石晃大 on 2021/02/23.
//

import UIKit
import MapKit
import FloatingPanel
import RealmSwift

class Pin: Object {
    
    // タイトル
    @objc dynamic var title = ""
    
    // 内容
    @objc dynamic var content = ""
   
    // 緯度
    @objc dynamic var latitude = ""

    // 経度
    @objc dynamic var longitude = ""

}

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, MKMapViewDelegate, FloatingPanelControllerDelegate {

    @IBOutlet weak var searchInputText: UITextField!
    @IBOutlet weak var dispMap: MKMapView!
    var locationManager: CLLocationManager!
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var toCordinate: CLLocationCoordinate2D?
    var toTitle: String = ""
    var isUserLocation: Bool = false
    
    var fpc:FloatingPanelController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchInputText.delegate = self
        
        // locationManager生成
        locationManager = CLLocationManager()
        locationManager.delegate = self
        dispMap.delegate = self
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
            self.isUserLocation = true
            let location = CLLocationCoordinate2DMake(self.latitude, self.longitude)
            let pin = MKPointAnnotation()

            pin.coordinate = location

            pin.title = "現在地"

            self.dispMap.addAnnotation(pin)

            self.dispMap.region = MKCoordinateRegion(center: location, latitudinalMeters: 500.0, longitudinalMeters: 500.0)
        }
    }
    
    func registerNewLoccation(coodinate:CLLocationCoordinate2D) {
        let ac = UIAlertController(title: "タイトル", message: "メッセージ", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: {[weak ac] (action) -> Void in
            guard let textFields = ac?.textFields else {
                return
            }

            guard !textFields.isEmpty else {
                return
            }

            self.addPin(title: textFields[0].text ?? "", coordinate: coodinate)
            self.savePin(title: textFields[0].text ?? "", content: textFields[1].text ?? "", latitude: String(coodinate.latitude) ,longitude: String(coodinate.longitude))
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        //textfiled1の追加
        ac.addTextField(configurationHandler: {(text:UITextField!) -> Void in
            text.placeholder = "目的地"
            text.tag  = 1
        })
        //textfiled2の追加
        ac.addTextField(configurationHandler: {(text:UITextField!) -> Void in
            text.placeholder = "内容"
            text.tag  = 2
        })

        ac.addAction(ok)
        ac.addAction(cancel)

        present(ac, animated: true, completion: nil)

    }
    
    func addPin(title: String, coordinate: CLLocationCoordinate2D) {
        let pin = MKPointAnnotation()
        // 座標をピンに設定
        pin.coordinate = coordinate
        // タイトル指定
        pin.title = title
        
        // ピンを追加
        self.dispMap.addAnnotation(pin)
    }
    
    @IBAction func isLongPress(_ sender: UILongPressGestureRecognizer) {
        if(sender.state != UIGestureRecognizer.State.began){
                return
            }

            // ロングタップした位置情報を取得
        let location:CGPoint = sender.location(in: self.dispMap)

            // 取得した位置情報をCLLocationCoordinate2D（座標）に変換
        let coordinate:CLLocationCoordinate2D = self.dispMap.convert(location, toCoordinateFrom: self.dispMap)

        self.registerNewLoccation(coodinate: coordinate)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if self.isUserLocation {
            self.isUserLocation = false
            return nil
        }

        //アノテーションビューを生成する。
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        //吹き出しを表示可能にする。
        pin.canShowCallout = true

        //経路ボタンをアノテーションビューに追加する。
        let button = UIButton()
        button.frame = CGRect(x: 0,y: 0,width: 40,height: 30)
        button.setTitle("経路", for: .normal)
        button.layer.cornerRadius = 0.5
        button.backgroundColor = UIColor.white
        button.setTitleColor(UIColor.black, for:.normal)
        button.addTarget(self, action: #selector(tappedRouteButton(_:toCordinate:)), for: UIControl.Event.touchUpInside)
        pin.rightCalloutAccessoryView = button

        return pin
    }
    

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        return renderer
    }
    
    @objc func tappedRouteButton(_ sender:UIButton, toCordinate:CLLocationCoordinate2D) {
        if self.dispMap.overlays.count != 0 {
            // 経路表示リセット
            self.dispMap.removeOverlays(self.dispMap.overlays)
        }
        if self.toCordinate != nil {
            let fromCoordinate :CLLocationCoordinate2D = CLLocationCoordinate2DMake(self.latitude, self.longitude)
            let toCoordinate   :CLLocationCoordinate2D = self.toCordinate!
            if fromCoordinate.latitude == toCordinate.latitude && fromCoordinate.longitude == toCordinate.longitude {
                // 現在地と目的地の場所が同一だった場合(例外パターン想定)
            }
            let fromPlacemark = MKPlacemark(coordinate:fromCoordinate, addressDictionary:nil)
            let toPlacemark = MKPlacemark(coordinate:toCoordinate, addressDictionary:nil)
            let fromItem = MKMapItem(placemark:fromPlacemark);
            let toItem = MKMapItem(placemark:toPlacemark);
            let request = MKDirections.Request()
                request.source = fromItem
                request.destination = toItem
                request.requestsAlternateRoutes = false; //複数経路
            request.transportType = MKDirectionsTransportType.walking
            let directions = MKDirections(request:request)
            directions.calculate { [unowned self] response, error in
                guard let unwrappedResponse = response else { return }

                for route in unwrappedResponse.routes {
                   self.dispMap.addOverlay(route.polyline)
                   self.dispMap.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                }
            }
            
            // モーダル表示
            self.fpc = FloatingPanelController()
            self.fpc.layout = MyFloatingPanelLayout()
            self.fpc.delegate = self
            
            let destinationVC = DestinationViewController(toCordinate: self.toCordinate!, title: self.toTitle, fpc: self.fpc, dispMap: self.dispMap)
            fpc.set(contentViewController: destinationVC)
            fpc.addPanel(toParent: self)
        } else {
            // 目的地を選択してください
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation{
            self.toCordinate = annotation.coordinate
            self.toTitle = annotation.title!!
        }
    }
    
    // ピンの保存
    func savePin(title: String, content: String, latitude: String, longitude: String) {
        let pin = Pin()
        pin.title = title
        pin.content = content
        pin.latitude = latitude
        pin.longitude = longitude

        let realm = try! Realm()
        try! realm.write {
            realm.add(pin)
        }
    }
}


class MyFloatingPanelLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .tip
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 150.0, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(fractionalInset: 150.0, edge: .bottom, referenceGuide: .safeArea),
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 150.0, edge: .bottom, referenceGuide: .safeArea),
        ]
    }
}
