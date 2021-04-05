//
//  SpinnerView.swift
//  YandexTest
//
//  Created by Vitaly Khomatov on 25.03.2021.
//

import UIKit

class SpinnerView: UIView {
    
    lazy var messageLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.text = "Loading"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .light)
        label.textColor = .white
        label.sizeToFit()
        return label
    }()
    
    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.color = .white
        return spinner
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupSubviews()
        layout()
    }
    
    private func layout() {
        messageLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        spinner.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -7).isActive = true
        spinner.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        messageLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    private func setupSubviews() {
        spinner.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .red
        self.layer.opacity = 0.75
        self.layer.cornerRadius = 6.0
        self.addSubview(spinner)
        self.addSubview(messageLabel)
    }
    
    public func start() {
        spinner.startAnimating()
    }
    
    public func stop() {
        spinner.stopAnimating()
    }
}
