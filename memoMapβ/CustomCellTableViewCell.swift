//
//  CustomCellTableViewCell.swift
//  memoMapβ
//
//  Created by 白石晃大 on 2021/03/16.
//

import UIKit

class CustomCellTableViewCell: UITableViewCell {


    @IBOutlet weak var cellImageView: UIImageView!
    
    @IBOutlet weak var cellLabel: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
