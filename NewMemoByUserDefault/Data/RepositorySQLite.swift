//
//  RepositorySQLite.swift
//  NewMemoByUserDefault
//
//  Created by Soo J on 2022/11/01.
//

import Foundation
import SQLite3



class MemoRepository: MemoRepositoryProtocol {
    
    init() {
        let dbPath = self.getDBPath()
        self.createTable(dbPath: dbPath)
    }
    
    var db: OpaquePointer? //SQLite 연결 정보를 담을 객체
//    var numberOfMemoInPage: Int = 4// 한페이지당 보여줄 데이터 개수

    func getDBPath() -> String {
        let fileManager = FileManager()
        let docPathURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbPath = docPathURL.appendingPathComponent("memo").path
        
        //dbPath 경로에 파일이 없다면 앱 번들에 만들어 둔 파일을 가져와 복사한다.
        if fileManager.fileExists(atPath: dbPath) == false {
            let dbSource = Bundle.main.path(forResource: "memo", ofType: "sqlite")
            try! fileManager.copyItem(atPath: dbSource!, toPath: dbPath)
        }
        return dbPath
    }
    
    func createTable(dbPath: String) {
        //DB가 연결되었다면
        guard sqlite3_open(dbPath, &db) == SQLITE_OK else {
            print("\nDatabase Connect Fail")
            return
        }
        
        //데이터베이스 연결 해제
//        defer {//defer: 지연블록 - 항상 함수의 종료(return 구문 실행) 직전에 실행
//            print("Close Database Connection")
//            sqlite3_close(db) //DB연결을 해제
//        }
      
        var statement: OpaquePointer? //컴파일된 SQL을 담을 객체
        let sql = "CREATE TABLE IF NOT EXISTS memo (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, content TEXT NOT NULL, last_update_time REAL NOT NULL)"
        //SQL 컴파일이 잘 끝났다면
        guard sqlite3_prepare(db, sql, -1, &statement, nil) == SQLITE_OK else {            print("\nPrepare Statement Fail")
            
            return
        }
        
        //statement 변수 해제
        defer {
            print("Finalize Statement")
            //컴파일된 SQL객체를 해제
            sqlite3_finalize(statement)
        }
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("\ntable created successfullly!!")
        }
    }
    
    func openDatabase() -> OpaquePointer? {
//        var db: OpaquePointer?
        let dbPath = self.getDBPath()
        
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            print("successfully opened connection to database at \(dbPath)")
            return db
        } else {
            print("Unable to open db")
            return nil
        }
    }
    
//    1. 함수 네이밍
//    2. 컬럼명 프리픽스 삭제
//    3. 키대신 넘버, 등등 다른 타입으로
//    4. 키 타입 굳이 스트링? AI 쓰는게 편함 (앱단애서 키 생성하지 않도록)-메모 한정
//    5. 컬럼명 되도록 단수 (DTO, VO 모델 만들떄도)
//    6. 컬럼명 상세하게 register"TIME"
//    7. 띄어쓰기 되도록 _로
//    8. 시각 기록 굳이 스트링일 필요 없
//    9. 단수+List 로 형식 이름 추천, 복수는 X
//    10. 굳이 관사 있을필요
//    11. 클래스 안 함수명에 굳이 클래스명이랑 겹치는 내용 쓸 필요 X
//    12. objectwith -> 유저디폴트 맞춤
//    13. state binding -> 쿼리문 조합해서 넘겨주는?? https://www.kodeco.com/6620276-sqlite-with-swift-tutorial-getting-started#toc-anchor-006
//    14. readAll: [Memo]를 반환 하므로 그냥 전체 다 받아오면 됨
    
    //insert, get(select), update, delete
    func insert(memo: Memo, completion: @escaping () -> Void) {
        var insertStatement: OpaquePointer?
        let insertStatementString = "INSERT INTO memo (id, title, content, last_update_time) VALUES (?,?,?,?)"

        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            
            let title: String = memo.title
            let content: String = memo.content
            let lastUpdateTime: Double = memo.lastUpdateTime
            
            //값 바인딩
            sqlite3_bind_text(insertStatement, 2, title.cString(using: .utf8), -1, nil)
            sqlite3_bind_text(insertStatement, 3, content.cString(using: .utf8), -1, nil)
            sqlite3_bind_double(insertStatement, 4, lastUpdateTime)
            
            //쿼리 실행하기 위해 스텝 밟기
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("\nSuccesfully inserted row")
                completion()
            } else {
                print("\nCould not insert row")
            }
        } else {
            print("\nINSERT statement is not prepared")
        }
        sqlite3_finalize(insertStatement)
    }
    
    func getRecordList() -> [Memo] {
        var memoArray: [Memo] = []
//        let db = openDatabase()
        //prepare statement
        var queryStatement: OpaquePointer?
        let queryStatementString = "SELECT * FROM memo;"
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            //execute statement
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                //read value of title column
                let id = sqlite3_column_int(queryStatement, 0)
                let queryResultColLastUpdateTime = sqlite3_column_double(queryStatement, 3)
                guard let queryResultColTitle = sqlite3_column_text(queryStatement, 1),
                      let queryResultColContent = sqlite3_column_text(queryStatement, 2) else {
                    print("\nQuery result is nil")
                    return memoArray
                }
                //read values of title
                let title = String(cString: queryResultColTitle)
                let content = String(cString: queryResultColContent)
                let lastUpdateTime = queryResultColLastUpdateTime
                let memo: Memo = Memo(title: title, content: content, lastUpdateTime: lastUpdateTime, id: Int(id))
                memoArray.append(memo)
            }
        }
        return memoArray
    }
    
    func getRecord(recordtWith id: Int) -> Memo? {
//        let db = openDatabase()
        var  queryStatement: OpaquePointer?
        let queryStatementString = "SELECT id, title, content, last_update_time FROM memo WHERE id = ?;"
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(queryStatement, 1, Int32(id))
            //execute statement
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                //read value of title column
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let queryResultColLastUpdateTime = sqlite3_column_double(queryStatement, 3)
                guard let queryResultColTitle = sqlite3_column_text(queryStatement, 1),
                      let queryResultColContent = sqlite3_column_text(queryStatement, 2) else {
                    print("\nQuery result is nil")
                    return nil
                }
                //read values of title
                let title = String(cString: queryResultColTitle)
                let content = String(cString: queryResultColContent)
                let lastUpdateTime = queryResultColLastUpdateTime
                sqlite3_finalize(queryStatement)
                return Memo(title: title, content: content, lastUpdateTime: lastUpdateTime, id: id)
            } else {
                print("\nQuery returned no results")
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("\nQuery is not prepared \(errorMessage)")
        }
        sqlite3_finalize(queryStatement)
        return nil
    }
    
    func getCountOf(columnNamed name: String) -> Int {
        var  queryStatement: OpaquePointer?
        let queryStatementString = "SELECT COUNT(?) FROM memo;"
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(queryStatement, 1, name.cString(using: .utf8), -1, nil)
            //execute statement
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                //get count of specific column
                let queryResultColCount = sqlite3_column_int(queryStatement, 0)
                let count = Int(queryResultColCount)
                sqlite3_finalize(queryStatement)
                return count
            }
        }
        return 0
    }

    func update(memo: Memo, completion: @escaping () -> Void) {
//        let db = openDatabase()
        var updateStatement: OpaquePointer?
        let updateStatementString = "UPDATE memo SET title = ?, content = ?, last_update_time = ? WHERE id = ?;"
        
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(updateStatement, 4, Int32(memo.id))
            sqlite3_bind_text(updateStatement, 1, memo.title.cString(using: .utf8), -1, nil)
            sqlite3_bind_text(updateStatement, 2, memo.content.cString(using: .utf8), -1, nil)
            sqlite3_bind_double(updateStatement, 3, memo.lastUpdateTime)
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                completion()
                print("\nSuccessfully updated row.")
            } else {
                print("\nCould not update row.")
            }
        } else {
            print("\nUPDATE statement is not prepared")
        }
        sqlite3_finalize(updateStatement)
    }
    
    func delete(recordWith id: Int) {
//        let db = openDatabase()
        var deleteStatement: OpaquePointer?
        let deleteStatementString = "DELETE FROM memo WHERE id = ?"
        
        sqlite3_bind_int(deleteStatement, 1, Int32(id))
        
        if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("\nSuccessfully deleted row.")
            } else {
                print("\nCould not delete row.")
            }
        } else {
            print("\nDELETE statement could not be prepared")
        }
        sqlite3_finalize(deleteStatement)
    }
    
    //페이지 컨트롤에 띄울 전체 리스트 리스트 반환
    func getTotalPageList(numberOfMemoInPage: Int) -> [Int] {
        let totalNumberOfMemo = getCountOf(columnNamed: "id")
        var totalPageList: [Int] = []
        if totalNumberOfMemo <= numberOfMemoInPage {
            return [1]
        } else {
            let quotient: Int = totalNumberOfMemo/numberOfMemoInPage //몫
            let remainder: Int = totalNumberOfMemo%numberOfMemoInPage //나머지
            if remainder == 0 {
                totalPageList.append(contentsOf: 1...quotient)
            } else {
                totalPageList.append(contentsOf: 1...(quotient + 1))
            }
            print("Memorepository.getToatalPageList의 콘텐츠 내용 \(totalPageList)")
            return totalPageList
        }
    }
    
    //페이지 컨트롤에 띄울 최대길이 5인 리스트 반환
    func getPageListToShow(selectedPage: Int, numberOfMemoInPage: Int) -> [Int] {
        let totalPage = getTotalPageList(numberOfMemoInPage: numberOfMemoInPage)
        var pageListToShow: [Int] = []
        if totalPage.count > 5 {
            if selectedPage <= 3 {
                return [1,2,3,4,5]
            } else if  selectedPage >= (totalPage.count - 2) {
                pageListToShow.append(contentsOf: (totalPage.count - 4)...totalPage.count)
                return pageListToShow
            } else {
                pageListToShow.append(contentsOf: (selectedPage - 2)...(selectedPage + 2))
                return pageListToShow
            }
        } else {
            return totalPage
        }
    }
    
    //선택된 페이지에 띄울 메모내용 선택 (쿼리에 LIMIT 사용)
    func getRecordListInPage(selectedPage: Int, numberOfMemoInPage: Int) -> [Memo] {
        var queryStatement: OpaquePointer?
        let queryStatementString: String = "SELECT id, title, content, last_update_time FROM memo LIMIT ? OFFSET ?;"
        var memoArray: [Memo] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(queryStatement, 1, Int32(numberOfMemoInPage))
            sqlite3_bind_int(queryStatement, 2, Int32((numberOfMemoInPage*(selectedPage - 1))))
            //execute statement
            //read value of title column
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(queryStatement, 0)
                let queryResultColLastUpdateTime = sqlite3_column_double(queryStatement, 3)
                guard let queryResultColTitle = sqlite3_column_text(queryStatement, 1),
                      let queryResultColContent = sqlite3_column_text(queryStatement, 2) else {
                    print("\nQuery result is nil")
                    return memoArray
                }
                //read values of title
                let title = String(cString: queryResultColTitle)
                let content = String(cString: queryResultColContent)
                let lastUpdateTime = queryResultColLastUpdateTime
                let memo: Memo = Memo(title: title, content: content, lastUpdateTime: lastUpdateTime, id: Int(id))
                memoArray.append(memo)
            }
        }
        return memoArray
    }
}
