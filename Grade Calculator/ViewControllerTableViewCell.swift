//
//  ViewControllerTableViewCell.swift
//  ListWithPopupApp
//
//  Created by Jonathan Hovich on 7/18/18.
//  Copyright © 2018 Jonathan Hovich. All rights reserved.
//

import UIKit

class ViewControllerTableViewCell: UITableViewCell {
    // outlets
    @IBOutlet weak var gradeName: UILabel!
    @IBOutlet weak var gradeWeight: UILabel!
    @IBOutlet weak var gradeValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
