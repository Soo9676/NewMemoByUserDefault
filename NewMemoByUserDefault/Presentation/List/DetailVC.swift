//
//  DetailVC.swift
//  NewMemoByUserDefault
//
//  Created by Soo J on 2022/10/05.
//

import Foundation
import UIKit

class DetailVC: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var updateButton: UIButton!
    
    var repository = MemoRepository()
    var id: Int?
    var memoData: Memo?
    
//    viewDidLoad 단계에서 받은 key로 수정/생성화면 구분해서 셋업
    override func viewDidLoad() {
        setup(id: id)
    }
    
    func setup(id: Int?) {
        
        if let id = id {
            //id로 memoTable 값 조회해서 decode후 상세화면에 뿌려주기
            memoData = repository.getRecord(recordtWith: id)
            
            self.title = "메모 수정하기"
            titleTextField.text = memoData?.title
            contentsTextView.text = memoData?.content
            updateButton.setTitle("update", for: .normal)
            
        } else {
            
            self.title = "메모 생성하기"
            titleTextField.placeholder = "새로운 메모를 입력하세요"
            contentsTextView.text = ""
            updateButton.setTitle("cerate", for: .normal)
            
        }
    }

//    업데이트 버튼 누르면 현재 화면값과 key로 조회한 데이터값 비교해 수정/생성하기
    @IBAction func tapUpdateButton(_ sender: Any) {
        var jsonString: String?
        let currentTime = recordCurrentTime()
        

        if let title = titleTextField.text,
           let content = contentsTextView.text {
            var memo = Memo(title: title, content: content, lastUpdateTime: currentTime, id: 0)
            //id없으면 insert, id 있으면 해당 id로 update (내용 동일한지 확인 없음)
            if let id = id {
                memo.id = id
                repository.update(memo: memo) {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                repository.insert(memo: memo) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    func recordCurrentTime() -> Double {
        return Date.now.timeIntervalSince1970
    }

    //다른 곳을 터치하면 키보드 내리기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
