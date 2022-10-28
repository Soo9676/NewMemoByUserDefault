//
//  MemoDataSourceProtocol.swift
//  NewMemoByUserDefault
//
//  Created by Soo J on 2022/10/28.
//

import Foundation

protocol MemoDataSourceProtoocl {
    func getAll() async -> Result<[MemoResponseModel], MemoError>
    func getOne(_ id: String) async -> Result<MemoResponseModel?, MemoError>
    func create(_ memoRequestModel: MemoRequestModel) async -> Result<Bool, MemoError>
    func update(id: String, data: MemoRequestModel) async -> Result<Bool, MemoError>
    func delete(_ id: String) async -> Result<Bool, MemoError>
}

