//
//  UserDefault+Extension.swift
//  NewMemoByUserDefault
//
//  Created by Soo J on 2022/10/27.
//

import Foundation

extension UserDefaults: ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object : Encodable {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            let jsonString: String? = String.init(data: data, encoding: .utf8)
            if let jsonString = jsonString {
                
            }
        } catch {
            print(error)
        }
        throw ObjectSavableError.unableToEncode
    }

    func getObject<T>(jsonString: String, forKey: String) throws -> T where T : Decodable {
        let decoder = JSONDecoder()
        do {
            if let jsonData = jsonString.data(using: .utf8) {
                let memoObject = try decoder.decode(T.self, from: jsonData)
                return memoObject
            }
        } catch {
            print("\(ObjectSavableError.unableToDecode)")
        }

        throw ObjectSavableError.unableToDecode
    }
}
