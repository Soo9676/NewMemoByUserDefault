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
    var selectedPageInt: Int = 1 {
        didSet {
            memoTableView.reloadData()
            pagesCollection.reloadData()
        }
    }
    var memoCount: Int = 0
    let sectionInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    
    @IBOutlet weak var memoTableView: UITableView!
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    @IBOutlet weak var viewEmbeddingStack: UIView!
    @IBOutlet weak var moveToLeftPageButton: UIButton!
    @IBOutlet weak var moveToRightPageButton: UIButton!
    @IBOutlet weak var pagesCollection: UICollectionView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        memoCount = repository.getCountOf(columnNamed: "id")
        memoListInPage = repository.getRecordListInPage(selectedPage: selectedPageInt, numberOfMemoInPage: numberOfMemoInPage)
        //전체 메모 개수가 한페이지(기본값4)이하면 페이지 리스트를 표시하지 않는다
        if memoCount <= numberOfMemoInPage {
            viewEmbeddingStack.isHidden = true
        }
        memoTableView.reloadData()
        pagesCollection.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memoCount = repository.getCountOf(columnNamed: "id")
        memoListInPage = repository.getRecordListInPage(selectedPage: selectedPageInt, numberOfMemoInPage: numberOfMemoInPage)
        setPageControlButtonImg()
        if memoCount <= numberOfMemoInPage {
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
            detailVC.id = memoListInPage[indexPath.row].id
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
        print("selectedPage: \(selectedPageInt)")
//        pagesCollection.reloadData()
//        memoTableView.reloadData()
    }
    
    @IBAction func moveToRightPage(_ sender: Any) {
        selectedPageInt += 1
        if selectedPageInt == repository.getPageListToShow(selectedPage: selectedPageInt, numberOfMemoInPage: <#T##Int#>) {
            moveToRightPageButton.isEnabled = false
        } else {
            moveToRightPageButton.isEnabled = true
        }
        print("selectedPage: \(selectedPageInt)")
    }
    
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memoListInPage.count //수정 필요
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("\n\(indexPath.row)")
        let id = memoListInPage[indexPath.row].id
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoCell", for: indexPath) as? MemoCell else {return UITableViewCell()}

        cell.memoData = memoListInPage[indexPath.row]
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
        let idOfRowToDelete = memoListInPage[indexPath.row].id
        if editingStyle == .delete {
            memoListInPage.remove(at: indexPath.row)
            memoTableView.deleteRows(at: [indexPath], with: .fade)
            repository.delete(recordWith: idOfRowToDelete)
            memoTableView.reloadData()
        }
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageListToShow = repository.getPageListToShow(selectedPage: selectedPageInt, numberOfMemoInPage: numberOfMemoInPage)
        return pageListToShow.count //수정 필요
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pageCell", for: indexPath) as? PageCell else {
            return UICollectionViewCell()
        }
        pageListToShow = repository.getPageListToShow(selectedPage: selectedPageInt, numberOfMemoInPage: numberOfMemoInPage)
        cell.pageButton.setTitle("\(pageListToShow[indexPath.row])", for: .normal)
        cell.pageButtonPressed = { [weak self] (senderCall) in
            //메인vc의 테이블, 콜렉션 뷰 다시 그리기
            guard let pageNum = self?.pageListToShow[indexPath.row] else { return }
            self?.selectedPageInt = pageNum
            self?.memoTableView.reloadData()
            self?.pagesCollection.reloadData()
        }
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
