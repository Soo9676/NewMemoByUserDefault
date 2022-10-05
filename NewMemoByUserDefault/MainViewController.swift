//
//  MainViewController.swift
//  NewMemoByUserDefault
//
//  Created by Soo J on 2022/10/04.
//

import UIKit

struct Memo: Codable {
    var title: String
    var contents: String
    var lastUpdateTime: String
}

class MainViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    var keyList: [String] = []
    
    @IBOutlet weak var memoTableView: UITableView!
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    
    
    override func viewWillAppear(_ animated: Bool) {
        memoTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let keyList = defaults.value(forKey: "memoKeyList") as? [String] {
            self.keyList = keyList
        }
        
    }
    
    @IBAction func addBarButttonTapped(_ sender: Any) {
        performSegue(withIdentifier: "MoveToDetail", sender: nil)
    }
    
    func convertMemotoJSONString(memoStruct: Memo) -> String {
        do {
            let jsonData = try JSONEncoder().encode(memoStruct)
            let jsonString: String? = String.init(data: jsonData, encoding: .utf8)
            if let jsonString = jsonString {
                return jsonString
            }
        } catch {
            print("Unable to Encode/Decode Note due to \(error)")
        }
        return "return Nothing"
    }

    func convertJSONStringtoMemo(jsonString: String) -> Memo {
        do {
            if let jsonData = jsonString.data(using: .utf8) {
                let memoStruct = try JSONDecoder().decode(Memo.self, from: jsonData)
                return memoStruct
            }
        } catch {
            print("Unable to Encode/Decode Note due to \(error)")
        }
        return Memo.init(title: "null", contents: "null", lastUpdateTime: "null")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MoveToDeatail" {
            let detailVC = segue.destination as! DetailVC
            guard let indexPath = sender as? IndexPath else {return}
//            detailVC.memoDateList = self.memoDateList
            
            detailVC.key = keyList[indexPath.row]
            print("keyDate 전달 완료")
        }
    }

}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoCell", for: indexPath) as? MemoCell else {return UITableViewCell()}
        
        if let jsonString = defaults.string(forKey: keyList[indexPath.row]) {
            let memoStruct: Memo = convertJSONStringtoMemo(jsonString: jsonString)
            cell.memoData = memoStruct
        }
        cell.key = keyList[indexPath.row]

        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    
}

