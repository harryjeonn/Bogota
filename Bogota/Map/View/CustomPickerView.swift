//
//  PickerView.swift
//  bogota
//
//  Created by 전현성 on 2022/03/02.
//

import UIKit

protocol CustomPickerViewDelegate {
    func doneButtonClicked()
}

class CustomPickerView: UIView {
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var doneButton: UIButton!
    
    var delegate: CustomPickerViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadView()
    }
    
    private func loadView() {
        let view = Bundle.main.loadNibNamed("CustomPickerView", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        view.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.9)
        setupUI()
        addSubview(view)
    }
    
    private func setupUI() {
        pickerView.backgroundColor = .white
        
        doneButton.setTitle("완료", for: .normal)
        doneButton.tintColor = .blueColor
    }
    
    @IBAction func doneButtonClicked(_ sender: Any) {
        delegate?.doneButtonClicked()
    }
}
