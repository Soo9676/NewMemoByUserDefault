//
//  Repository.swift
//  NewMemoByUserDefault
//
//  Created by Soo J on 2022/10/21.
//

import Foundation

//MARK: Repository protocol
protocol Repository {
    
    associatedtype T
    
    func createMemo(title: String, contents: String, lastUpdateTime: String, uuid: String) -> T
    func readAllMemos() -> [T]
    func readAMemo(objectWith key: String) -> T
    func updateMemo(memo: Memo)
    func delete(objectWith key: String)
    
}

class MemoManager<T: Repository> {
    var memoRepository: T
    
    init(repository: T) {
        self.memoRepository = repository
    }
    
    func whichMemo() -> String {
        return "\(T.self)"
    }
}

class UserDefaultsRepository: Repository {
    
 typealias T = Memo
    
    var defaults = UserDefaults.standard
    
    func createMemo(title: String, contents: String, lastUpdateTime: String, uuid: String) -> Memo {
        var memo: Memo = Memo(title: title, contents: contents, lastUpdateTime: lastUpdateTime, uuid: uuid)
     return memo
    }
    
    func readAllMemos() -> [Memo] {
        var memos: [Memo] = []
        if let keyList = defaults.object(forKey: "keyList") as? [String] {
            let memoRange = 0...(keyList.count - 1)
            for i in memoRange{
                if let memo = defaults.object(forKey: keyList[i]) as? Memo {
                    memos.append(memo)
                }
            }
        }
        return memos
    }
    
    func readAMemo(objectWith key: String) -> Memo {
        var memo: Memo = Memo(title: "", contents: "", lastUpdateTime: "", uuid: "")
        if let memoToGet = defaults.object(forKey: key) as? Memo {
            memo = memoToGet
        }
        return memo
    }
    
    func updateMemo(memo: Memo) {
        
        let key = memo.uuid
        defaults.set(memo, forKey: key)
        if var keyList = defaults.object(forKey: "keyList") as? [String] {
//            if keyList.contains()
            
            keyList.append(key)
            defaults.set(keyList, forKey: "keyList")
        }
    }
    
    func delete(objectWith key: String) {
        defaults.removeObject(forKey: key)
        if var keyList = defaults.object(forKey: "keyList") as? [String] {
            if let i = keyList.firstIndex(of: key) {
                keyList.remove(at: i)
                defaults.set(keyList, forKey: "keyList")
            }
        }
    }
}

