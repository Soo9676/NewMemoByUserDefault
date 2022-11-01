//
//  MainViewController.swift
//  NewMemoByUserDefault
//
//  Created by Soo J on 2022/10/04.
//

import UIKit

class MainViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    let repository = UserDefaultsRepository()
    var keyList: [String] = []
    
    @IBOutlet weak var memoTableView: UITableView!
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    
    
    override func viewWillAppear(_ animated: Bool) {
        let keyList = repository.readKeyList(listNamed: "keyList")
        self.keyList = keyList
        memoTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let keyList = repository.readKeyList(listNamed: "keyList")
        self.keyList = keyList
        memoTableView.reloadData()
    }
    
    @IBAction func addBarButttonTapped(_ sender: Any) {
        performSegue(withIdentifier: "MoveToDetail", sender: nil)
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MoveToDetail" {
            let detailVC = segue.destination as! DetailVC
            guard let indexPath = sender as? IndexPath else {return}
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
        var key = keyList[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoCell", for: indexPath) as? MemoCell else {return UITableViewCell()}

        cell.memoData = repository.readAMemo(objectWith: key)
        cell.key = key
        cell.updateButtonPressed = { [weak self] (senderCall) in
            //뷰컨트롤러에 있는 세그웨이 실행
            self?.performSegue(withIdentifier: "MoveToDetail", sender: indexPath)
        }
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let dateToEdit = keyList[indexPath.row]
        if editingStyle == .delete {
            keyList.remove(at: indexPath.row)
            memoTableView.deleteRows(at: [indexPath], with: .fade)
            repository.delete(objectWith: dateToEdit)
            memoTableView.reloadData()
        }
    }
}


