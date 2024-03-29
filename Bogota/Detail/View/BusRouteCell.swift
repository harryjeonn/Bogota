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
    @IBOutlet weak var lineViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var busImageView: UIImageView!
    @IBOutlet weak var busImageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var busNumberView: UIView!
    @IBOutlet weak var busNumberLabel: UILabel!
    
    @IBOutlet weak var downImageStackView: UIStackView!
    @IBOutlet weak var downImageView: UIImageView!
    @IBOutlet weak var roundLabel: UILabel!
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var stationIdLabel: UILabel!
    @IBOutlet weak var firstArrMsgLabel: UILabel!
    @IBOutlet weak var secondArrMsgLabel: UILabel!
    @IBOutlet weak var shareModeView: UIView!
    
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
        stationLabel.numberOfLines = 0
        
        stationLabel.font = .systemFont(ofSize: 17)
        stationIdLabel.font = .systemFont(ofSize: 14)
        firstArrMsgLabel.font = .systemFont(ofSize: 14)
        secondArrMsgLabel.font = .systemFont(ofSize: 14)
        roundLabel.font = .systemFont(ofSize: 14)
        busNumberLabel.adjustsFontSizeToFitWidth = true
        
        stationLabel.textColor = .black
        stationIdLabel.textColor = .gray
        firstArrMsgLabel.textColor = .red
        secondArrMsgLabel.textColor = .red
        roundLabel.textColor = .lightGray
        busNumberLabel.textColor = .gray
        
        busNumberLabel.textAlignment = .center
        busNumberLabel.numberOfLines = 2
        
        downImageStackView.backgroundColor = .white
        downImageStackView.layer.borderColor = UIColor.lightGray.cgColor
        
        downImageView.backgroundColor = .clear
        
        roundLabel.text = "회차"
        
        busImageView.tintColor = .blueColor
        busImageView.backgroundColor = .white
        
        busNumberView.backgroundColor = .white
        busNumberView.layer.shadowRadius = 2
        busNumberView.layer.shadowOpacity = 0.5
        busNumberView.layer.shadowColor = UIColor.gray.cgColor
        busNumberView.layer.shadowOffset = CGSize(width: 0, height: 0)
        busNumberView.layer.cornerRadius = 5
        
        shareModeView.backgroundColor = .white.withAlphaComponent(0.7)
        
        self.selectionStyle = .none
    }
}
