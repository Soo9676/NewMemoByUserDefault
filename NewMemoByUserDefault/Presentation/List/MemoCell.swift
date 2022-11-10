//
//  MemoCell.swift
//  NewMemoByUserDefault
//
//  Created by Soo J on 2022/10/05.
//

import UIKit

class MemoCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var updateButton: UIButton!
    
    var id: Int = 0
    var repository = MemoRepository()
    var memoData: Memo?{
        didSet{
            configurationUIwithData() 
        }
    }
    
    var updateButtonPressed: (MemoCell) -> Void = { (sender) in }
    
    var title: String?
    var contents: String?
    var lastUpdateTime: Double?
    
//    테이블뷰 dataSource에서 넘겨받은 Memo 타입의 객체 값을 UI에 뿌려주기
    func configurationUIwithData() {
        
        title = memoData?.title
        contents = memoData?.content
        lastUpdateTime = memoData?.lastUpdateTime
        
        timeLabel.text = "\(lastUpdateTime ?? 0)"
        titleLabel.text = title
    }
//    업데이트 버튼 누르면 클로저를 통해 세그웨이로 detailVC로 이동
    @IBAction func tapUpdateButton(_ sender: Any) {
        //뷰컨트롤러에서 전달받은 클로저를 실행 (self = cell을 전달)
        updateButtonPressed(self)
    }
}
