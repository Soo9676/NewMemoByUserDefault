//
//  MainViewModel.swift
//  NewMemoByUserDefault
//
//  Created by Soo J on 2022/10/24.
//

import Foundation

struct MemoResponseModel: Equatable, Hashable {
    var uuid: String
    var title: String
    var contents: String
    var lastUpdateTime: String
    
    init(){
        uuid = UUID().uuidString
        title = ""
        contents = ""
        lastUpdateTime = ""
    }
    
    init(uuid: String, title: String, contents: String, lastUpdateTime: String){
        self.uuid = uuid
        self.title = title
        self.contents = contents
        self.lastUpdateTime = lastUpdateTime
    }
}

struct MemoRequestModel: Equatable {
    var uuid: String
    var title: String
    var contents: String
    var lastUpdateTime: String
    
    init(){
        title = ""
        contents = ""
        lastUpdateTime = ""
        uuid = ""
    }
    
    init(uuid: String, title: String, contents: String, lastUpdateTime: String){
        self.uuid = uuid
        self.title = title
        self.contents = contents
        self.lastUpdateTime = lastUpdateTime
    }
}
