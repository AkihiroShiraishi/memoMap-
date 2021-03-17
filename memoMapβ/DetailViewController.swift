//
//  DetailViewController.swift
//  memoMapβ
//
//  Created by 白石晃大 on 2021/03/11.
//

import UIKit
import RealmSwift

class DetailViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
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
        selectImageName = categoryData[row]
        if categoryData[row] == "グルメ" {
            categoryText.text = "グルメ"
            categoryImage.image = UIImage(named: "gurume")
            categoryImage.backgroundColor = UIColor.init(displayP3Red: 1.0, green: 0.388, blue: 0.278, alpha: 1.0)
        } else if categoryData[row] == "施設" {
            categoryText.text = "施設"
            categoryImage.image = UIImage(named: "facility")
            categoryImage.backgroundColor = UIColor.init(displayP3Red: 0, green: 0.794, blue: 1.0, alpha: 1.0)
        } else if categoryData[row] == "その他" {
            categoryText.text = "その他"
            categoryImage.image = UIImage(named: "other")
            categoryImage.backgroundColor = UIColor.init(displayP3Red: 0.690, green: 0.768, blue: 0.870, alpha: 1.0)
        } else {
            categoryText.text = "Category Space"
            categoryImage.image = UIImage(named: "blank")
            categoryImage.backgroundColor = UIColor.init(displayP3Red: 0.662, green: 0.662, blue: 0.662, alpha: 1.0)
        }
    }

    
    

    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryText: UITextField!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var contentText: UITextView!
    
    var detailInfo: Pin?
    
    var pickerView: UIPickerView = UIPickerView()
    var toolBar: UIToolbar?
    var selectImageName: String?
    var categoryData = ["","グルメ", "施設", "その他"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleText.delegate = self
        contentText.delegate = self
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(displayP3Red: 0.972, green: 0.972, blue: 1.0, alpha: 1.0)
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
        
        categoryText.backgroundColor = UIColor(displayP3Red: 0.972, green: 0.972, blue: 1.0, alpha: 1.0)
        categoryText.layer.borderColor = UIColor(displayP3Red: 0.972, green: 0.972, blue: 1.0, alpha: 1.0).cgColor
        categoryText.textAlignment = .center
        categoryText.textColor = .black
        categoryText.font = UIFont.boldSystemFont(ofSize: 25)
        
        self.selectImageName = detailInfo?.category
        if detailInfo?.category == "グルメ" {
            categoryText.text = "グルメ"
            categoryImage.image = UIImage(named: "gurume")
            categoryImage.backgroundColor = UIColor.init(displayP3Red: 1.0, green: 0.388, blue: 0.278, alpha: 1.0)
        } else if detailInfo?.category == "施設" {
            categoryText.text = "施設"
            categoryImage.image = UIImage(named: "facility")
            categoryImage.backgroundColor = UIColor.init(displayP3Red: 0, green: 0.794, blue: 1.0, alpha: 1.0)
        } else if detailInfo?.category == "その他" {
            categoryText.text = "その他"
            categoryImage.image = UIImage(named: "other")
            categoryImage.backgroundColor = UIColor.init(displayP3Red: 0.690, green: 0.768, blue: 0.870, alpha: 1.0)
        } else {
            categoryText.text = "Category Space"
            categoryImage.image = UIImage(named: "blank")
            categoryImage.backgroundColor = UIColor.init(displayP3Red: 0.662, green: 0.662, blue: 0.662, alpha: 1.0)
        }
        
        // カテゴリーテキスト設定
        settingCategory()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        titleText.text = textField.text
        
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        contentText.text = textView.text
        return true
    }
    
    //入力画面ないしkeyboardの外を押したら、キーボードを閉じる処理
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.contentText.isFirstResponder) {
            self.contentText.resignFirstResponder()
            toolBar?.removeFromSuperview()
            pickerView.removeFromSuperview()
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
            detailInfo?.setValue(selectImageName, forKey: "category")
            detailInfo?.setValue(titleText.text, forKey: "title")
            detailInfo?.setValue(contentText.text, forKey: "content")
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func tappedCategoryButton(_ sender: Any) {
        
    }
    func settingCategory() {
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor.white
        pickerView.setValue(UIColor.black, forKey: "textColor")
        pickerView.autoresizingMask = .flexibleWidth
        pickerView.contentMode = .center
        pickerView.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        
        categoryText.inputView = pickerView
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action:#selector(onDoneButtonTapped))
        toolbar.setItems([doneButtonItem], animated: true)
        categoryText.inputAccessoryView = toolbar
    }
    @objc func onDoneButtonTapped() {
        categoryText.endEditing(true)
    }
    
}
