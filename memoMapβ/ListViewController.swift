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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = self.lists?[indexPath.row].title
        cell.textLabel?.textColor = .black
        cell.backgroundColor = .white
        cell.isHighlighted = false
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
