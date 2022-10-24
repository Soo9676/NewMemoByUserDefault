//
//  MemoEntity.swift
//  NewMemoByUserDefault
//
//  Created by Soo J on 2022/10/24.
//

import Foundation

struct Memo: Codable {
    var title: String
    var contents: String
    var lastUpdateTime: String
    var uuid: String
}
