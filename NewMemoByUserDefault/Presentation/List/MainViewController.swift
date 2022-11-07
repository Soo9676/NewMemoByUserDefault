//
//  MainViewController.swift
//  NewMemoByUserDefault
//
//  Created by Soo J on 2022/10/04.
//

import UIKit

class MainViewController: UIViewController {
    
    let repository = MemoRepository()
    var numberOfMemoInPage: Int = 4 //페이지당 보여줄 데이터 개수 (디폴트 값 4)
    var memoListInPage: [Memo] = [] //페이지당 보여줄 데이터 리스트
    var pageListToShow: [Int] = [] //전체 페이지 개수 =< numberOfMemoInPage e.g.) [2,3,4,5,6] or [1,2,3]
    var presentPage: Int? //현재 선택된 페이지 수
    var idList: [Int] = [] //전체 데이터 개수
    var memoList: [Memo] = []
    
    @IBOutlet weak var memoTableView: UITableView!
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    @IBOutlet weak var viewEmbeddingStack: UIView!
    @IBOutlet weak var moveToLeftPageButton: UIButton!
    @IBOutlet weak var moveToRightPageButton: UIButton!
    @IBOutlet weak var pagesCollection: UICollectionView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        memoList = repository.getRecordList()
        memoListInPage = repository.getRecordListInPage()
        let idList = memoList.map({ (memo: Memo) -> Int in
            return memo.id
        })
        repository.numberOfMemoInPage = self.numberOfMemoInPage
        self.idList = idList
        //전체 메모 개수가 한페이지(기본값4)이하면 페이지 리스트를 표시하지 않는다
        if idList.count <= numberOfMemoInPage {
            viewEmbeddingStack.isHidden = true
        }
        memoTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memoList = repository.getRecordList()
        let idList = memoList.map({ (memo: Memo) -> Int in
            return memo.id
        })
        self.idList = idList
        setPageControlButtonImg()
        if idList.count <= numberOfMemoInPage {
            viewEmbeddingStack.isHidden = true
        }
        memoTableView.reloadData()
    }
    
    func setPageControlButtonImg() {
        moveToLeftPageButton.setImage(UIImage(systemName: "arrow.left.circle"), for: .normal)
        moveToRightPageButton.setImage(UIImage(systemName: "arrow.right.circle"), for: .normal)
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

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageListToShow = repository.getPageList()
        return pageListToShow.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pageCell", for: indexPath) as? PageCell else {
            return UICollectionViewCell()
        }
        pageListToShow = repository.getPageList()
        cell.pageButton.setTitle("\(pageListToShow[indexPath.row])", for: .normal)
        return cell
    }
    
    
}
