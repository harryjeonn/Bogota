//
//  CommonPopupView.swift
//  bogota
//
//  Created by 전현성 on 2022/01/26.
//

import UIKit

class CommonPopupView: UIView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadView()
    }
    
    private func loadView() {
        let view = Bundle.main.loadNibNamed("CommonPopupView", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        view.backgroundColor = .clearColor
        setupContentView()
        addGesture()
        addSubview(view)
    }

    private func setupContentView() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10
        
        contentView.layer.shadowRadius = 1
        contentView.layer.shadowOpacity = 0.5
        contentView.layer.shadowColor = UIColor.gray.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        titleLabel.font = .boldSystemFont(ofSize: 20)
        
        descriptionLabel.font = .systemFont(ofSize: 15)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        
        confirmButton.backgroundColor = .blueColor
        confirmButton.tintColor = .white
        confirmButton.layer.cornerRadius = 10
    }
    
    private func addGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(removeView))
        self.addGestureRecognizer(tap)
    }
    
    @objc func removeView() {
        self.removeFromSuperview()
    }
    
    @IBAction func confirmButtonClicked(_ sender: Any) {
        removeView()
    }
}
