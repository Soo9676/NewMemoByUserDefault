//
//  PageCell.swift
//  NewMemoByUserDefault
//
//  Created by Soo J on 2022/11/07.
//

import Foundation
import UIKit

class PageCell: UICollectionViewCell {
    
    var pageButtonPressed: (PageCell) -> Void = { (sender) in }
    var selectedPage: Int = 1{
        didSet {
           pageButtonPressed(self)
        }
    }
    
    
    
    @IBOutlet weak var pageButton: UIButton!
    
    @IBAction func selectPage(_ sender: UIButton) {
        guard let pageText = sender.titleLabel?.text else { return }
        guard let num = Int(pageText) else { return }
        selectedPage = num
    }
}
