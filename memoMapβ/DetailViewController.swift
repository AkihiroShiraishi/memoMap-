//
//  DetailViewController.swift
//  memoMapβ
//
//  Created by 白石晃大 on 2021/03/11.
//

import UIKit
import RealmSwift

class DetailViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    

    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var contentText: UITextView!
    
    var detailInfo: Pin?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleText.delegate = self
        contentText.delegate = self
        
        
        initLayout()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        titleText.backgroundColor = .white
        titleText.textColor = .black
        titleText.layer.borderColor = UIColor.black.cgColor
        titleText.layer.borderWidth = 1
        contentText.backgroundColor = .white
        contentText.textColor = .black
        contentText.layer.borderColor = UIColor.black.cgColor
        contentText.layer.borderWidth = 1
        contentText.frame.size = CGSize(width: 293, height: 150)
        titleText.text = detailInfo?.title
        contentText.text = detailInfo?.content
        
        
        if detailInfo?.category == "グルメ" {
            categoryImage.image = UIImage(named: "gurume64")
            categoryImage.backgroundColor = UIColor.init(displayP3Red: 1.0, green: 0.772, blue: 0.505, alpha: 1.0)
        } else if detailInfo?.category == "施設" {
            categoryImage.image = UIImage(named: "facility64")
            categoryImage.backgroundColor = UIColor.init(displayP3Red: 0.364, green: 0.690, blue: 0.886, alpha: 1.0)
        } else if detailInfo?.category == "その他" {
            categoryImage.image = UIImage(named: "other64")
            categoryImage.backgroundColor = UIColor.init(displayP3Red: 0.364, green: 0.690, blue: 0.886, alpha: 1.0)
        } else {
            categoryImage.image = UIImage(named: "blank")
            categoryImage.backgroundColor = UIColor.init(displayP3Red: 0.364, green: 0.690, blue: 0.886, alpha: 1.0)
        }
    }
    
    
    func initLayout() {
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        titleText.text = textField.text
        return true
    }
    
    //入力画面ないしkeyboardの外を押したら、キーボードを閉じる処理
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.contentText.isFirstResponder) {
            self.contentText.resignFirstResponder()
        }
    }

    @IBAction func tappedDelete(_ sender: Any) {
        let realm = try! Realm()
        do{
          try realm.write{
            realm.delete(detailInfo!)
          }
        }catch {
          print("Error \(error)")
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func tappedDone(_ sender: Any) {
        let realm = try! Realm()

        try! realm.write {
            detailInfo?.setValue(titleText.text, forKey: "title")
            detailInfo?.setValue(contentText.text, forKey: "content")
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
    //編集終了後のtextデータを、別のファイルへ送信したい時はこの中に書く。
//    func textViewDidChange(_ textView: UITextView) {
//        contentText.text = textView.text
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
