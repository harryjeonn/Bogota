//
//  BusRouteCell.swift
//  bogota
//
//  Created by 전현성 on 2022/01/28.
//

import UIKit

class BusRouteCell: UITableViewCell {
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var lineViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var lineViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var busImageView: UIImageView!
    @IBOutlet weak var downImageView: UIImageView!
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var stationIdLabel: UILabel!
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
        stationLabel.font = .systemFont(ofSize: 17)
        stationIdLabel.font = .systemFont(ofSize: 14)
        firstArrMsgLabel.font = .systemFont(ofSize: 14)
        secondArrMsgLabel.font = .systemFont(ofSize: 14)
        
        stationLabel.textColor = .black
        stationIdLabel.textColor = .gray
        firstArrMsgLabel.textColor = .red
        secondArrMsgLabel.textColor = .red
        
        firstArrMsgLabel.textAlignment = .right
        secondArrMsgLabel.textAlignment = .right
        
        downImageView.layer.cornerRadius = downImageView.frame.width / 2
        
        busImageView.isHidden = true
        
        self.selectionStyle = .none
    }
}
