//
//  StocksHeaderView.swift
//  YandexTest
//
//  Created by Vitaly Khomatov on 24.03.2021.
//

import UIKit

class StocksHeaderView: UIView {
    
    var stockFontSize: CGFloat = 28
    var favouriteFontSize: CGFloat = 16
    var stockFontColor: UIColor = .black
    var favouriteFontColor: UIColor = .lightGray
    
    var stocksButton = UIButton(frame: .zero)
    var favouriteButton = UIButton(frame: .zero)
    var state: State = .stocks {
        didSet {
            setupViews(state: state)
            layoutViews(state: state)
        }
    }
    var buttonCallback: ((_ state: State) -> Void)?
    var stackView = UIStackView()
    var stackLabel = UILabel(frame: .zero)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews(state: state)
        stocksButton.isUserInteractionEnabled = false

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutViews(state: state)
    }
    
    private func setupViews(state: State) {
        
        if state != .search {
        stocksButton.titleLabel?.textAlignment = .left
        stocksButton.titleLabel?.font = .systemFont(ofSize: stockFontSize, weight: .bold)
        stocksButton.setTitle("Stocks", for: .normal)
        stocksButton.setTitleColor(stockFontColor, for: .normal)
        stocksButton.translatesAutoresizingMaskIntoConstraints = false
        stocksButton.sizeToFit()
        stocksButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        
        favouriteButton.titleLabel?.textAlignment = .left
        favouriteButton.titleLabel?.font = .systemFont(ofSize: favouriteFontSize, weight: .bold)
        favouriteButton.setTitle("Favourite", for: .normal)
        favouriteButton.setTitleColor(favouriteFontColor, for: .normal)
        favouriteButton.translatesAutoresizingMaskIntoConstraints = false
        favouriteButton.sizeToFit()
        favouriteButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        
        stackView.distribution = .equalSpacing
        stackView.alignment = .lastBaseline
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.sizeToFit()
        stackView.addArrangedSubview(stocksButton)
        stackView.addArrangedSubview(favouriteButton)
        stackLabel.removeFromSuperview()

        self.addSubview(stackView)
            
        } else {
            stackLabel.textAlignment = .left
            stackLabel.font = .systemFont(ofSize: favouriteFontSize+4, weight: .bold)
            stackLabel.textColor = UIColor.black
            stackLabel.numberOfLines = 1
            stackLabel.translatesAutoresizingMaskIntoConstraints = false
            stackLabel.text = "Stocks"
            stackLabel.sizeToFit()
            stackView.removeFromSuperview()
            self.addSubview(stackLabel)
        }
    }
    
    private func layoutViews(state: State) {
        if state != .search {
        stackView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12.0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10.0).isActive = true
        } else {
            stackLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12.0).isActive = true
            stackLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        }
        
    }
    
    @objc private func buttonPressed(_ sender: UIButton) {
        
        switch sender.titleLabel?.text {
        
        case "Favourite" :
            favouriteFontSize = 32
            favouriteFontColor = .black
            stockFontSize = 18
            stockFontColor = .lightGray
            state = .favourite
            favouriteButton.isUserInteractionEnabled = false
            stocksButton.isUserInteractionEnabled = true

        default:
            stockFontSize = 32
            stockFontColor = .black
            favouriteFontSize = 18
            favouriteFontColor = .lightGray
            state = .stocks
            favouriteButton.isUserInteractionEnabled = true
            stocksButton.isUserInteractionEnabled = false
        }
        
        if let callback = self.buttonCallback {
            callback(state)
        }
        self.setupViews(state: state)
    }
    
    
    enum State: String {
        case stocks = "Stocks", favourite = "Favourite", search
    }
    
    
}
