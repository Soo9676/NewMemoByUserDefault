//
//  Repository.swift
//  NewMemoByUserDefault
//
//  Created by Soo J on 2022/10/21.
//

import Foundation

//MARK: Repository protocol
protocol RepositoryProtocol {
    
    associatedtype T
    
    func createMemo(title: String, contents: String, lastUpdateTime: String, uuid: String) -> T
    func readAllMemos() -> [T]
    func readAMemo(objectWith key: String) -> T
    func updateMemo(memo: Memo)
    func delete(objectWith key: String)
    
}

protocol ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable
    func getObject<Object>(jsonString: String, forKey: String) throws -> Object where Object: Decodable
}

enum ObjectSavableError: String, LocalizedError {
    case unableToEncode = "Unable to encode object into data"
    case noValue = "No data object found for the given key"
    case unableToDecode = "Unable to decode object into given type"
    
    var errorDescription: String? {
        rawValue
    }
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
    
 typealias T = Memo
    
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
        var memo: Memo = Memo(title: "", contents: "", lastUpdateTime: "", uuid: "")
        if let memoToGet = defaults.object(forKey: key) as? Memo {
            memo = memoToGet
        }
        return memo
    }
    
    func updateMemo(memo: Memo) {
        
        let key = memo.uuid
        if var keyList = defaults.object(forKey: "keyList") as? [String] {
            if keyList.contains(key) {
                defaults.set(memo, forKey: key)
            } else {
                keyList.append(key)
                defaults.set(keyList, forKey: "keyList")
                defaults.set(memo, forKey: key)
            }
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

