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
    
    var repository = UserDefaultsRepository()
    var key: String?
    var defaults = UserDefaults.standard
    var memoData: Memo?
    
//    viewDidLoad 단계에서 받은 key로 수정/생성화면 구분해서 셋업
    override func viewDidLoad() {
        setup(key: key)
    }
    
    func setup(key: String?) {
        
        if let key = key {
            //key로 userdefaults 값 조회해서 decode후 상세화면에 뿌려주기
            memoData = repository.readAMemo(objectWith: key)
            print("memoData: \(String(describing: memoData))")
            
            self.title = "메모 수정하기"
            titleTextField.text = memoData?.title
            contentsTextView.text = memoData?.contents
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
        let uuid = UUID().uuidString

        if let title = titleTextField.text,
           let contents = contentsTextView.text {
            //키없으면 새로 생성, 키 있으면 해당 키로 userdefaults에 덮어 씌우기
            if let key = key {
                memoData = try! repository.createMemo(title: title, contents: contents, lastUpdateTime: currentTime, uuid: key)
            } else {
                memoData = try! repository.createMemo(title: title, contents: contents, lastUpdateTime: currentTime, uuid: uuid)
            }
        }
        guard let memoData = memoData else { return }
//        if let key = key
        repository.updateMemo(memo: memoData){
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func recordCurrentTime() -> String {
        return String(Date.now.timeIntervalSince1970)
    }

    //다른 곳을 터치하면 키보드 내리기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
