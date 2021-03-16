//
//  ListViewController.swift
//  memoMapβ
//
//  Created by 白石晃大 on 2021/03/11.
//

import UIKit
import RealmSwift

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    var lists: [Pin]?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = ViewController()
        self.lists = vc.getAllPins()
        self.tableView.delegate = self
        self.view.backgroundColor = .white
        self.tableView.backgroundColor = .white
        
        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lists?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CustomCellTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCellTableViewCell
        cell.cellLabel.text = self.lists?[indexPath.row].title
        cell.cellLabel.textColor = .black
        cell.backgroundColor = .white
        
        let category = self.lists?[indexPath.row].category
        if category == "グルメ" {
            cell.cellImageView.image = UIImage(named: "gurume")
        } else if category == "施設" {
            cell.cellImageView.image = UIImage(named: "facility")
        } else if category == "その他" {
            cell.cellImageView.image = UIImage(named: "other")
        } else {
            cell.cellImageView.image = UIImage(named: "blank")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = self.storyboard?.instantiateViewController(identifier: "detail") as! DetailViewController
        detailVC.detailInfo = self.lists![indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    @IBAction func returnButton(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
