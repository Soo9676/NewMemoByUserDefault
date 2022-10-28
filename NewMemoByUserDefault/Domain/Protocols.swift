//
//  Protocols.swift
//  NewMemoByUserDefault
//
//  Created by Soo J on 2022/10/24.
//

import Foundation

enum MemoError: String, LocalizedError {
    case unableToCreate = "Unable to create memo"
    case unableToGet = "Unable to get memo"
    case unableToUpdate = "Unable to update memo"
    case unableToDelete = "Unable to delete memo"
    
    var errorDescription: String? {
        rawValue
    }
}

protocol CreateMemoUseCaseProtocol {
    func execute(_ memo: MemoRequestModel) async -> Result<Bool, MemoError>
}

protocol GetAllMemosUseCaseProtocol {
    func execute() async -> Result<[MemoResponseModel], MemoError>
}

protocol GetMemoUseCaseProtocol {
    func execute() async -> Result<MemoResponseModel, MemoError>
}

protocol DeleteMemoUseCaseProtocol {
    func execute(_ id: String) async -> Result<Bool, MemoError>
}

protocol UpdateMemoUseCaseProtocol {
    func execute(id: String, memo: MemoRequestModel) async -> Result<Bool, MemoError>
}

