//
//  HomeStationCell.swift
//  bogota
//
//  Created by 전현성 on 2022/01/24.
//

import UIKit

class HomeStationCell: UITableViewCell {
    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        subTitleLabel.textColor = .gray
        subTitleLabel.font = .systemFont(ofSize: 14)
    }
    
}
