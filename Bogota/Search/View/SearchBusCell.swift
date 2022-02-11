//
//  SearchResultCell.swift
//  bogota
//
//  Created by 전현성 on 2022/02/11.
//

import UIKit

class SearchBusCell: UITableViewCell {
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
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
        typeLabel.clipsToBounds = true
        typeLabel.textColor = .white
        typeLabel.layer.cornerRadius = 5
        typeLabel.textAlignment = .center
        typeLabel.font = .systemFont(ofSize: 15)
    }
}
