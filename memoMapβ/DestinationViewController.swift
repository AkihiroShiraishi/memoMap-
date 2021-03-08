//
//  DestinationViewController.swift
//  memoMapβ
//
//  Created by 白石晃大 on 2021/03/05.
//


import UIKit
import MapKit
import FloatingPanel
 
class DestinationViewController: UIViewController{
    
    var toCordinate: CLLocationCoordinate2D
    var toTitle: String?
    var fpc: FloatingPanelController
    var dispMap: MKMapView
    
    init(toCordinate: CLLocationCoordinate2D, title: String, fpc: FloatingPanelController, dispMap:MKMapView) {
        self.toCordinate = toCordinate
        self.toTitle = title
        self.fpc = fpc
        self.dispMap = dispMap
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
 
        self.view.backgroundColor = UIColor(displayP3Red: 0.827, green: 0.827, blue: 0.827, alpha: 1.0)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        
        // 目的地項目
        let destination: UILabel = UILabel(frame: CGRect(x: 50, y: 175 / 6, width: self.view.frame.size.width / 2 - 50, height: 30))
        destination.text = "目的地"
        destination.textColor = .black
        destination.font = UIFont.boldSystemFont(ofSize: 25)
        destination.textAlignment = .left
        self.view.addSubview(destination)
        
        // 目的地追加
        let title: UILabel = UILabel(frame: CGRect(x: 50, y: 175 / 2, width: self.view.frame.size.width / 2, height: 175 / 2))
        title.text = self.toTitle
        title.textColor = .black
        title.font = UIFont.systemFont(ofSize: 20)
        title.textAlignment = .left
        title.center.y = title.frame.origin.y
        self.view.addSubview(title)
        
        // ボタン追加
        // ナビゲーションボタン
        let button: UIButton = UIButton(frame: CGRect(x:title.frame.size.width + 30, y: 175 / 6, width:title.frame.size.width - 60 , height: 50))
        button.backgroundColor = UIColor(displayP3Red: 0.478, green: 0.501, blue: 0.564, alpha: 1.0)
        button.layer.cornerRadius = 3.0
        button.setTitle("ここに行く", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(startNavigation), for: .touchUpInside)
        self.view.addSubview(button)
        
        // キャンセルボタン
        let cancelButton: UIButton = UIButton(frame: CGRect(x:title.frame.size.width + 30, y: 175 / 2, width:title.frame.size.width - 60 , height: 50))
        cancelButton.backgroundColor = UIColor(displayP3Red: 0.776, green: 0.447, blue: 0.505, alpha: 1.0)
        cancelButton.layer.cornerRadius = 3.0
        cancelButton.setTitle("キャンセル", for: .normal)
        cancelButton.setTitleColor(.black, for: .normal)
        cancelButton.addTarget(self, action: #selector(tappedCancel), for: .touchUpInside)
        self.view.addSubview(cancelButton)
        
    }
    
    @objc func startNavigation() {
        let placemark = MKPlacemark(coordinate: self.toCordinate, addressDictionary: nil)
        let mapitem = MKMapItem(placemark: placemark)
        mapitem.name = self.toTitle

        mapitem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking,
            MKLaunchOptionsMapTypeKey: MKMapType.standard.rawValue
        ])
    }
    
    @objc func tappedCancel() {
        self.fpc.removePanelFromParent(animated: true, completion: nil)
        self.dispMap.removeOverlays(self.dispMap.overlays)
    }
}
