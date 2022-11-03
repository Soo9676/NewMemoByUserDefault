//
//  MainViewController.swift
//  NewMemoByUserDefault
//
//  Created by Soo J on 2022/10/04.
//

import UIKit

class MainViewController: UIViewController {
    
    let repository = MemoRepository()
    var idList: [Int] = []
    var memoList: [Memo] = []
    
    @IBOutlet weak var memoTableView: UITableView!
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    
    
    override func viewWillAppear(_ animated: Bool) {
        memoList = repository.getRecordList()
        let idList = memoList.map({ (memo: Memo) -> Int in
            return memo.id
        })
        self.idList = idList
        memoTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memoList = repository.getRecordList()
        let idList = memoList.map({ (memo: Memo) -> Int in
            return memo.id
        })
        self.idList = idList
        memoTableView.reloadData()
    }
    
    @IBAction func addBarButttonTapped(_ sender: Any) {
        performSegue(withIdentifier: "MoveToDetail", sender: nil)
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MoveToDetail" {
            let detailVC = segue.destination as! DetailVC
            guard let indexPath = sender as? IndexPath else {return}
            detailVC.id = idList[indexPath.row]
            print("id 전달 완료")
        }
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return idList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var id = idList[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoCell", for: indexPath) as? MemoCell else {return UITableViewCell()}

        cell.memoData = repository.getRecord(recordtWith: id)
        cell.id = id
        cell.updateButtonPressed = { [weak self] (senderCall) in
            //뷰컨트롤러에 있는 세그웨이 실행
            self?.performSegue(withIdentifier: "MoveToDetail", sender: indexPath)
        }
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let dateToEdit = idList[indexPath.row]
        if editingStyle == .delete {
            idList.remove(at: indexPath.row)
            memoTableView.deleteRows(at: [indexPath], with: .fade)
            repository.delete(recordWith: dateToEdit)
            memoTableView.reloadData()
        }
    }
}


