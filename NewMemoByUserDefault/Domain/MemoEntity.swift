//
//  MemoEntity.swift
//  NewMemoByUserDefault
//
//  Created by Soo J on 2022/10/24.
//

import Foundation

struct Memo: Codable {
    var title: String
    var content: String
    var lastUpdateTime: Double
    var id: Int
}

