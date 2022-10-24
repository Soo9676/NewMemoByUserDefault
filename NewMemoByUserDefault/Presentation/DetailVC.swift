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
    
    var key: String?
    var defaults = UserDefaults.standard
    var memoData: Memo?
    
//    viewDidLoad 단계에서 받은 key로 수정/생성화면 구분해서 셋업
    override func viewDidLoad() {
        setup(key: key)
    }
    
    func setup(key: String?) {
        
        if let key = key {
    //    key로 userdefaults 값 조회해서 decode후 상세화면에 뿌려주기
            if let jsonString: String = defaults.string(forKey: key) {
                let memo = convertJSONStringtoMemo(jsonString: jsonString)
                memoData = memo
                print("memoData: \(memoData)")
                
                self.title = "메모 수정하기"
                titleTextField.text = memoData?.title
                contentsTextView.text = memoData?.contents
                updateButton.setTitle("update", for: .normal)
            }
        } else {
            self.title = "메모 생성하기"
            titleTextField.placeholder = "새로운 메모를 입력하세요"
            contentsTextView.text = ""
            updateButton.setTitle("cerate", for: .normal)
        }
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
        return Memo.init(title: "null", contents: "null", lastUpdateTime: "null", uuid: "null")
    }

//    업데이트 버튼 누르면 현재 화면값과 key로 조회한 데이터값 비교해 수정/생성하기
    @IBAction func tapUpdateButton(_ sender: Any) {
        var jsonString: String?
        let currentTime = recordCurrentTime()
        let uuid = UUID().uuidString
        //현재 화면에 입력된 값 Memo Struct -> json String으로 생성
        if let title = titleTextField.text,
           let contents = contentsTextView.text {
            let newMemo: Memo = Memo.init(title: title, contents: contents, lastUpdateTime: currentTime, uuid: uuid)
            jsonString = convertMemotoJSONString(memoStruct: newMemo)
        }
        //    키없으면 새로 생성, 키 있으면 해당 키로 userdefaults에 덮어 씌우기
        updateMemo(jsonString: jsonString ?? "nil", currentTime: currentTime){
            self.navigationController?.popViewController(animated: true)
        }
        //    userdefualts 동기화
        //    버튼 눌러앞으로 이동 및 메인 테이블뷰 리로드
    }
    
    func recordCurrentTime() -> String {
        return String(Date.now.timeIntervalSince1970)
    }
    
    func updateMemo(jsonString: String, currentTime: String, completion: @escaping () -> Void){
        if let key = key {
            defaults.set(jsonString, forKey: key)
            defaults.synchronize()
            completion()
        } else {
            let keyList = defaults.value(forKey: "memoKeyList") as? [String] ?? []
            let newKeyList = keyList + [currentTime]
            //MARK: 키리스트 여기말고 메인에서 수정 (키만 넘겨줌)
            defaults.set(newKeyList, forKey: "memoKeyList")
            defaults.set(jsonString, forKey: currentTime)
            defaults.synchronize()
            completion()
        }
    }
    
    //다른 곳을 터치하면 키보드 내리기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension DetailVC {
    func inputToMemo() -> Memo {
        let currentTime = recordCurrentTime()
        let uuid = UUID().uuidString
        if let title = titleTextField.text,
           let contents = contentsTextView.text {
            let newMemo: Memo = Memo.init(title: title, contents: contents, lastUpdateTime: currentTime, uuid: uuid)
            return newMemo
        }
        return Memo(title: "no input", contents: "no input", lastUpdateTime: "no input", uuid: "no input")
    }
}

