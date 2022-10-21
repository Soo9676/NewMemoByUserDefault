//
//  Repository.swift
//  NewMemoByUserDefault
//
//  Created by Soo J on 2022/10/21.
//

import Foundation


protocol Repository {
    
    associatedtype T
    
    func addMemo(keyList: [Date]) -> T
    func readAllMemos() -> [T]?
    func getMemo(objectWith key: Date) -> T
    func updateMemo(objectWith key: Date)
    func delete(objectWith key: Date)
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
    
 typealias T = Memo ///////////
    
    func addMemo(keyList: [Date]) -> Memo {
        
    }
    
    func readAllMemos() -> [Memo]? {
        
    }
    
    func getMemo(objectWith key: Date) -> Memo {
        
    }
    
    func updateMemo(objectWith key: Date) {
        
    }
    
    func delete(objectWith key: Date) {
        
    }
    
}

