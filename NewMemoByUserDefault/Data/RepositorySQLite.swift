//
//  RepositorySQLite.swift
//  NewMemoByUserDefault
//
//  Created by Soo J on 2022/11/01.
//

import Foundation
import SQLite3

class SqliteRepository: RepositoryProtocol {
    
    var db: OpaquePointer? //SQLite 연결 정보를 담을 객체
    var statement: OpaquePointer? //컴파일된 SQL을 담을 객체
    
    //앱 내 문서 디렉토리 경로에서 SQLite DB 파일을 찾음
    let fileManager = FileManager()
    let docPathURL = try! fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    let dbPath = docPathURL.appendingPathComponent("memo.db")?.path
    
    let docPathURL = try 
    
    //1. 함수 네이밍
    //2. 컬럼명 프리픽스 삭제
    //3. 키대신 넘버, 등등 다른 타입으로
    //4. 키 타입 굳이 스트링? AI 쓰는게 편함 (앱단애서 키 생성하지 않도록)-메모 한정
    //5. 컬럼명 되도록 단수 (DTO, VO 모델 만들떄도)
    //6. 컬럼명 상세하게 register"TIME"
    //7. 띄어쓰기 되도록 _로
    //8. 시각 기록 굳이 스트링일 필요 없
    //9. 단수+List 로 형식 이름 추천, 복수는 X
    //10. 굳이 관사 있을필요
    //11. 클래스 안 함수명에 굳이 클래스명이랑 겹치는 내용 쓸 필요 X
    //12. objectwith -> 유저디폴트 맞춤
    //13. state binding -> 쿼리문 조합해서 넘겨주는
    //14. readAll: [Memo]를 반환 하므로 그냥 전체 다 받아오면 됨
    
    func createMemoTable() {
        let sql = "CREATE IF NOT EXISTS memo (key TEXT NOT NULL PRIMARY KEY, title TEXT, contents TEXT, lastupdate INTEGER NOT NULL)"
        sqlite3_open(dbPath, &db)
        sqlite3_prepare(db, sql, -1, &statement, nil)
        sqlite3_step(statement)
        sqlite3_finalize(statement)
        sqlite3_close(db)
    }
    
    
    //insert, get(select), update, delete
    func createMemo(title: String, contents: String, lastUpdateTime: String, uuid: String) -> Memo {
        let sql = "INSERT INTO memo (key, title, contents, lastupdate) VALUES ('\(uuid)', '\(title)', '\(contents)', '\(lastUpdateTime)'"
    }
    
    func readAllMemos() -> [Memo] {
        let sql = "SELECT memo_key, memo_title, memo_lastupdate FROM memo"
    }
    
    func readAMemo(objectWith key: String) -> Memo {
        let sql = "SELECT memo_key, memo_title, memo_contents FROM memo"
    }
    
    func updateMemo(memo: Memo, completion: @escaping () -> Void) {
//        let key = memo.uuid
        let sql = "UPDATE memo SET memo_title = \(memo.title), memo_contents = \(memo.contents), memo_lastupdate = \(memo.lastUpdateTime) WHERE memo_key = '\(memo.uuid)'"
    }
    
    func delete(objectWith key: String) {
        let sql = "DELETE FROM memo WHERE memo_key = \(key)"
    }
    
    
    
}
