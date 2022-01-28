//
//  EmptyView.swift
//  bogota
//
//  Created by 전현성 on 2022/01/28.
//

import UIKit

class EmptyView: UIView {
    @IBOutlet weak var emptyLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadView()
    }
    
    private func loadView() {
        let view = Bundle.main.loadNibNamed("EmptyView", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        view.backgroundColor = .clear
        
        emptyLabel.font = .systemFont(ofSize: 15)
        emptyLabel.textColor = .gray
        
        addSubview(view)
    }

}
