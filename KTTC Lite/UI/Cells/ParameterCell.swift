//
//  ParameterCell.swift
//  WoT Manager
//
//  Created by Ярослав Стрельников on 19.10.2021.
//

import UIKit

class ParameterCell: UICollectionViewCell {
    @IBOutlet weak var parameterLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        drawBorder(0, width: 0.4, color: .systemBorder)
        parameterLabel.textColor = .label
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        drawBorder(0, width: 0.4, color: .systemBorder)
    }
}
