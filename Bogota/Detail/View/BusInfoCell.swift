//
//  BusInfoCell.swift
//  bogota
//
//  Created by 전현성 on 2022/01/27.
//

import UIKit

class BusInfoCell: UITableViewCell {
    @IBOutlet weak var routeTypeLabel: UILabel!
    @IBOutlet weak var routeNameLabel: UILabel!
    @IBOutlet weak var firstArrMsgLabel: UILabel!
    @IBOutlet weak var secondArrMsgLabel: UILabel!
    
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
        firstArrMsgLabel.textAlignment = .right
        firstArrMsgLabel.textColor = .red
        firstArrMsgLabel.font = .systemFont(ofSize: 14)
        
        secondArrMsgLabel.textAlignment = .right
        secondArrMsgLabel.textColor = .red
        secondArrMsgLabel.font = .systemFont(ofSize: 14)
        
        routeTypeLabel.clipsToBounds = true
        routeTypeLabel.textColor = .white
        routeTypeLabel.layer.cornerRadius = 5
        routeTypeLabel.textAlignment = .center
        routeTypeLabel.font = .systemFont(ofSize: 15)
    }
    
}

