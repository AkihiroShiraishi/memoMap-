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
    
    // カテゴリー
    @objc dynamic var category = ""

}

class ViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate, MKMapViewDelegate, FloatingPanelControllerDelegate {

    @IBOutlet var longTap: UILongPressGestureRecognizer!
    @IBOutlet weak var searchInputText: UITextField!
    @IBOutlet weak var dispMap: MKMapView!
    var registorTextField: UITextField?
    var locationManager: CLLocationManager!
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var toCordinate: CLLocationCoordinate2D?
    var toTitle: String = ""
    var isUserLocation: Bool = false
    var fpc:FloatingPanelController!
    var registorAlert: UIAlertController!
    var pickerView = UIPickerView()
    var categoryData = ["","グルメ", "施設", "その他"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registorAlert = UIAlertController()
        
        searchInputText.delegate = self
        
        // locationManager生成
        locationManager = CLLocationManager()
        locationManager.delegate = self
        dispMap.delegate = self
        pickerView.delegate = self
        pickerView.dataSource = self
        view.addGestureRecognizer(longTap)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadView()
        viewDidLoad()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryData[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        registorAlert.textFields?[0].text = categoryData[row]
    }

    
    @IBAction func tappedListButton(_ sender: Any) {
        let listVC = self.storyboard?.instantiateViewController(identifier: "list") as! ListViewController
        self.navigationController?.pushViewController(listVC, animated: true)
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        // 保存されたピンを表示
        let annotations = getAnnotations()
           annotations.forEach { annotation in
                mapView.addAnnotation(annotation)
           }
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
        registorAlert = UIAlertController(title: "登録", message: "以下を入力し、目的地を登録してください。", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: {[weak registorAlert] (action) -> Void in
            guard let textFields = registorAlert?.textFields else {
                return
            }

            guard !textFields.isEmpty else {
                return
            }
            if textFields[1].text != "" {
                self.addPin(category:textFields[0].text!,title: textFields[1].text!, coordinate: coodinate)
                self.savePin(category:textFields[0].text!,title: textFields[1].text!, content: textFields[2].text ?? "", latitude: String(coodinate.latitude) ,longitude: String(coodinate.longitude))
            } else {
                self.alertMessage(title:"", message: "目的地を入力してください。")
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        registorAlert.addTextField(configurationHandler: {(text:UITextField!) -> Void in
            text.placeholder = "カテゴリー"
            text.tag  = 1
            text.inputView = self.pickerView
            let toolbar = UIToolbar()
            toolbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
            let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ViewController.donePicker))
            toolbar.setItems([doneButtonItem], animated: true)
            text.inputAccessoryView = toolbar
        })
        // textfiled2の追加
        registorAlert.addTextField(configurationHandler: {(text:UITextField!) -> Void in
            text.placeholder = "目的地"
            text.tag  = 2
        })
        // textfiled3の追加
        registorAlert.addTextField(configurationHandler: {(text:UITextField!) -> Void in
            text.placeholder = "内容"
            text.tag  = 3
        })

        registorAlert.addAction(ok)
        registorAlert.addAction(cancel)

        present(registorAlert, animated: true, completion: nil)

    }
    
    @objc func donePicker() {
        let textField = registorAlert.textFields?[0]
        textField?.endEditing(true)
    }

    
    func addPin(category: String, title: String, coordinate: CLLocationCoordinate2D) {
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
        pin.pinTintColor = UIColor(displayP3Red: 1.0, green: 0.388, blue: 0.278, alpha: 1.0)

        //経路ボタンをアノテーションビューに追加する。
        let button = UIButton()
        button.frame = CGRect(x: 0,y: 0,width: 40,height: 30)
        button.setImage(UIImage(named: "goTo"), for: .normal)
        button.layer.cornerRadius = 0.5
        button.backgroundColor = UIColor.clear
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
    func savePin(category: String, title: String, content: String, latitude: String, longitude: String) {
        let pin = Pin()
        pin.category = category
        pin.title = title
        pin.content = content
        pin.latitude = latitude
        pin.longitude = longitude

        let realm = try! Realm()
        try! realm.write {
            realm.add(pin)
        }
    }
    
    // ピンの取得
    func getAllPins() -> [Pin] {
       let realm = try! Realm()
       var results: [Pin] = []
       for pin in realm.objects(Pin.self) {
           results.append(pin)
       }
       return results
    }
    
    // 座標の取得
    func getAnnotations() -> [MKPointAnnotation]  {
        let pins = getAllPins()
        var results:[MKPointAnnotation] = []

        pins.forEach { pin in
            let annotation = MKPointAnnotation()
            let centerCoordinate = CLLocationCoordinate2D(latitude: (pin.latitude as NSString).doubleValue, longitude:(pin.longitude as NSString).doubleValue)
            annotation.coordinate = centerCoordinate
            annotation.title = pin.title

            results.append(annotation)
        }
        return results
    }
}


// MARK: - FloatingPanel
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
