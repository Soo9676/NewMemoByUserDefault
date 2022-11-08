//
//  MainViewController.swift
//  NewMemoByUserDefault
//
//  Created by Soo J on 2022/10/04.
//

import UIKit

class MainViewController: UIViewController {
    
    let repository = MemoRepository()
    let numberOfMemoInPage: Int = 4 //페이지당 보여줄 데이터 개수 (디폴트 값 4)
    var memoListInPage: [Memo] = [] //페이지당 보여줄 데이터 리스트
    var pageListToShow: [Int] = [] //전체 페이지 개수 =< numberOfMemoInPage e.g.) [2,3,4,5,6] or [1,2,3]
    var presentPage: Int? //현재 선택된 페이지 수
    var idList: [Int] = [] //전체 데이터 개수
    var memoList: [Memo] = []
    var selectedPageInt: Int = 1
    let sectionInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    
    @IBOutlet weak var memoTableView: UITableView!
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    @IBOutlet weak var viewEmbeddingStack: UIView!
    @IBOutlet weak var moveToLeftPageButton: UIButton!
    @IBOutlet weak var moveToRightPageButton: UIButton!
    @IBOutlet weak var pagesCollection: UICollectionView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        memoList = repository.getRecordList()
        memoListInPage = repository.getRecordListInPage(selectedPage: 1, recordPerPage: numberOfMemoInPage)
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
        pagesCollection.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memoList = repository.getRecordList()
        let idList = memoList.map({ (memo: Memo) -> Int in
            return memo.id
        })
        repository.numberOfMemoInPage = self.numberOfMemoInPage
        self.idList = idList
        setPageControlButtonImg()
        if idList.count <= numberOfMemoInPage {
            viewEmbeddingStack.isHidden = true
        }
        memoTableView.reloadData()
        pagesCollection.reloadData()

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
    @IBAction func moveToLeftPage(_ sender: Any) {
        selectedPageInt -= 1
        if selectedPageInt == 1 {
            moveToLeftPageButton.isEnabled = false
        } else {
            moveToLeftPageButton.isEnabled = true
        }
        pagesCollection.reloadData()
        memoTableView.reloadData()
    }
    
    @IBAction func moveToRightPage(_ sender: Any) {
        selectedPageInt += 1
        if selectedPageInt == repository.getTotalPageList().last {
            moveToRightPageButton.isEnabled = false
        } else {
            moveToRightPageButton.isEnabled = true
        }
        pagesCollection.reloadData()
        memoTableView.reloadData()
    }
    
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repository.getRecordListInPage(selectedPage: selectedPageInt, recordPerPage: numberOfMemoInPage).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = repository.getRecordListInPage(selectedPage: selectedPageInt, recordPerPage: numberOfMemoInPage)[indexPath.row].id
        
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
        pageListToShow = repository.getPageListToShow(selectedPage: selectedPageInt)
        return pageListToShow.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pageCell", for: indexPath) as? PageCell else {
            return UICollectionViewCell()
        }
        pageListToShow = repository.getPageListToShow(selectedPage: selectedPageInt)
        cell.pageButton.setTitle("\(pageListToShow[indexPath.row])", for: .normal)
        return cell
    }
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //collectionView 에서 cell 을 가지고 옴. Optional 주의
        guard let cell =  collectionView.cellForItem(at: indexPath) as? PageCell else {
            return
        }
        // cell 에서 텍스트가 있는지 확인
        guard let buttonText = cell.pageButton.titleLabel?.text else {
            return
        }
        guard let buttonInt = Int(buttonText) else { return }
        
        selectedPageInt = buttonInt
        //화면 다시 그리기
        collectionView.reloadData()
        memoTableView.reloadData()
        
        //선택된 버튼과 아닌 버튼 ui set
        if buttonInt == selectedPageInt {
            cell.pageButton.backgroundColor = .yellow
            cell.pageButton.titleLabel?.textColor = .black
        } else {
            cell.pageButton.backgroundColor = .clear
            cell.pageButton.titleLabel?.textColor = .blue
        }
        cell.pageButton.titleLabel?.textAlignment = .center

//
//        //섞이지 않으면 경고창 띄우기
//        guard !(derivedArray == originalArray) else {
//            let alert = UIAlertController(title: "경고", message: "아직 섞이지 않음\n버튼을 섞어 게임을 시작하시겠습니까?🕹", preferredStyle: .alert)
//            let okAction = UIAlertAction(title: "OK", style: .default, handler: tapStartButton(_:))
//            alert.addAction(okAction)
//            present(alert, animated: false, completion: nil)
//            return
//        }
//
//        //몇번쨰 탭인지 비교
//        if Int(buttonText) == nthTab {
//            //선택한 셀이 마지막 셀이면 성공화면, 틀리면 실패화면, 순서는 맞지만 마지막이 아니라면 nthTab 1 증가시킨 후 통과
//            guard Int(buttonText) == derivedArray.count else {
//                nthTab += 1
//                cell.myButton.backgroundColor = .yellow
//                cell.contentView.isHidden = false
//                return
//            }
//            cell.myButton.backgroundColor = .blue
//            let alert = UIAlertController(title: "성공", message: "순서 맞추기 성공🥳", preferredStyle: .alert)
//            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//            alert.addAction(okAction)
//            present(alert, animated: false, completion: nil)
//        } else {
//            cell.myButton.backgroundColor = .red
//            let alert = UIAlertController(title: "실패", message: "순서 맞추기 실패🥲\n리셋하시겠습니까?", preferredStyle: .alert)
//            let okAction = UIAlertAction(title: "새로", style: .destructive, handler: tapStartButton(_:))
//            let cancelAction = UIAlertAction(title: "이어서", style: .cancel, handler: nil)
//            alert.addAction(okAction)
//            alert.addAction(cancelAction)
//            present(alert, animated: false, completion: nil)
//        }
    }
    
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height = collectionView.frame.height
        let itemsPerRow: CGFloat = CGFloat(pageListToShow.count)
        let widthPadding = sectionInsets.left * (itemsPerRow + 1)
        let itemsPerColumn: CGFloat = 1
        let heightPadding = sectionInsets.top * (itemsPerColumn + 1)
        let cellWidth = (width - widthPadding) / itemsPerRow
        let cellHeight = (height - heightPadding) / itemsPerColumn
        
        return CGSize(width: cellWidth, height: cellHeight)
        
    }
}
