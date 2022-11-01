//
//  Repository.swift
//  NewMemoByUserDefault
//
//  Created by Soo J on 2022/10/21.
//

import Foundation

//MARK: Repository protocol
protocol RepositoryProtocol {
    
    func createMemo(title: String, contents: String, lastUpdateTime: String, uuid: String) -> Memo
    func readAllMemos() -> [Memo]
    func readAMemo(objectWith key: String) -> Memo
//    func readKeyList(listNamed name: String) -> [String]
    func updateMemo(memo: Memo, completion: @escaping () -> Void)
    func delete(objectWith key: String)
    
}

enum ObjectSavableError: String, LocalizedError {
    
    var errorDescription: String? {
        rawValue
    }
    case unableToEncode = "Unable to encode object into data"
    case noValue = "No data object found for the given key"
    case unableToDecode = "Unable to decode object into given type"
}

class MemoManager<T: RepositoryProtocol> {
    var memoRepository: T
    
    init(repository: T) {
        self.memoRepository = repository
    }
    
    func whichMemo() -> String {
        return "\(T.self)"
    }
}

class UserDefaultsRepository: RepositoryProtocol {
        
    var defaults = UserDefaults.standard
    
    func convertMemotoJSONString(memoStruct: Memo) throws -> String {
        do {
            let jsonData = try JSONEncoder().encode(memoStruct)
            let jsonString: String? = String.init(data: jsonData, encoding: .utf8)
            if let jsonString = jsonString {
                return jsonString
            }
        } catch {
            print("Unable to Encode/Decode Note due to \(error)")
        }
        throw ObjectSavableError.unableToEncode
    }
    
    func convertJSONStringtoMemo(jsonString: String) throws -> Memo {
        do {
            if let jsonData = jsonString.data(using: .utf8) {
                let memoStruct = try JSONDecoder().decode(Memo.self, from: jsonData)
                return memoStruct
            }
        } catch {
            print("Unable to Encode/Decode Note due to \(error)")
        }
        throw ObjectSavableError.unableToDecode
    }
    
    func createMemo(title: String, contents: String, lastUpdateTime: String, uuid: String) -> Memo {
        var memo: Memo = Memo(title: title, contents: contents, lastUpdateTime: lastUpdateTime, uuid: uuid)
        if let encodedMemo = try? convertMemotoJSONString(memoStruct: memo) {
            defaults.set(encodedMemo, forKey: memo.uuid)
        }
     return memo
    }
    
    func readAllMemos() -> [Memo] {
        var memos: [Memo] = []
        if let keyList = defaults.object(forKey: "keyList") as? [String] {
            let memoRange = 0...(keyList.count - 1)
            for i in memoRange{
                if let memo = defaults.object(forKey: keyList[i]) as? String {
                    if let decodedMemo: Memo = try? convertJSONStringtoMemo(jsonString: memo) {
                        memos.append(decodedMemo)
                    }
                }
            }
        }
        return memos
    }
    
    func readAMemo(objectWith key: String) -> Memo {
        var memo: Memo = Memo(title: "Unable to decode", contents: "Unable to decode", lastUpdateTime: "Unable to decode", uuid: "Unable to decode")
        if let memoToGet = defaults.object(forKey: key) as? String {
            if let decodedMemo = try? convertJSONStringtoMemo(jsonString: memoToGet) as Memo {
                memo = decodedMemo
                return memo
            }
        }
        return memo
    }
    
    func readKeyList(listNamed name: String) -> [String] {
        let keyList: Array<String> = []
        if let keyList = defaults.stringArray(forKey: name) {
            return keyList
        }
        return keyList
    }
    
    func updateMemo(memo: Memo, completion: @escaping () -> Void) {
        
        let key = memo.uuid
        var keyList = readKeyList(listNamed: "keyList")
        
        if keyList.contains(key) {
            defaults.synchronize()
            completion()
        } else {
            keyList.append(key)
            defaults.set(keyList, forKey: "keyList")
            defaults.synchronize()
            completion()
        }
    }
    
    func delete(objectWith key: String) {
        defaults.removeObject(forKey: key)
        if var keyList = defaults.object(forKey: "keyList") as? [String] {
            if let i = keyList.firstIndex(of: key) {
                keyList.remove(at: i)
                defaults.set(keyList, forKey: "keyList")
                defaults.synchronize()
            }
        }
    }
}

