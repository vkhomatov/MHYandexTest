//
//  StockTableViewCell.swift
//  YandexTest
//
//  Created by Vitaly Khomatov on 24.03.2021.
//

import UIKit

class StockTableViewCell: UITableViewCell {
    
    var logoImageView = UIImageView(frame: .zero)
    var symbolLabel = UILabel(frame: .zero)
    var companyLabel = UILabel(frame: .zero)
    var priceLabel = UILabel(frame: .zero)
    var dayPriceChangeLabel = UILabel(frame: .zero)
    var starButton = UIButton(frame: .zero)
    var cellHeight : CGFloat = 0
    let bigFontSize: CGFloat = 15
    let smallFontSize: CGFloat = 9
    let labelHeigth: CGFloat = 22
    var starOnImage = UIImage()
    var starOffImage = UIImage()
    var starButtonCallback: ((_ state: Bool) -> Void)?

    var starButtonStatus: Bool = false {
        didSet {
            if starButtonStatus == true {
                starButton.setImage(starOnImage, for: .normal)
            } else {
                starButton.setImage(starOffImage, for: .normal)
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configureSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutViews()
        contentView.layer.cornerRadius = 10
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.backgroundColor = .white
        starButtonStatus = false
        logoImageView.image = nil//UIImage(named: "picture")
    }
    
    
    private func configureSubviews() {
        
        if let image = UIImage(named: "starOff") {
            starOffImage = image
        }
        if let image = UIImage(named: "starOn") {
            starOnImage = image
        }
        
        logoImageView.contentMode = .scaleAspectFill
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.layer.cornerRadius = 10
        logoImageView.backgroundColor = .white
        logoImageView.clipsToBounds = true
        logoImageView.backgroundColor = .white
        logoImageView.image = UIImage(named: "picture")
        contentView.addSubview(logoImageView)
        
        symbolLabel.textAlignment = .left
        symbolLabel.font = .systemFont(ofSize: bigFontSize, weight: .bold)
        symbolLabel.textColor = UIColor.black
        symbolLabel.numberOfLines = 1
        symbolLabel.translatesAutoresizingMaskIntoConstraints = false
        symbolLabel.lineBreakMode = .byTruncatingTail
        contentView.addSubview(symbolLabel)
        
        starButton.contentMode = .scaleAspectFill
        starButton.translatesAutoresizingMaskIntoConstraints = false
        starButton.clipsToBounds = true
        if starButtonStatus {
            starButton.setImage(starOnImage, for: .normal)
        } else {
            starButton.setImage(starOffImage, for: .normal)
        }
        starButton.imageView?.contentMode = .scaleAspectFit
        starButton.imageEdgeInsets = UIEdgeInsets(top: 7.0, left: 5.0, bottom: 7.0, right: 9.0)
        starButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        contentView.addSubview(starButton)
        
        companyLabel.font = .systemFont(ofSize: smallFontSize, weight: .regular)
        companyLabel.textColor = UIColor.black
        companyLabel.textAlignment = .left
        companyLabel.numberOfLines = 1
        companyLabel.translatesAutoresizingMaskIntoConstraints = false
        companyLabel.lineBreakMode = .byTruncatingTail
        contentView.addSubview(companyLabel)
        
        priceLabel.textAlignment = .right
        priceLabel.font = .systemFont(ofSize: bigFontSize, weight: .bold)
        priceLabel.textColor = UIColor.black
        priceLabel.numberOfLines = 1
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(priceLabel)
        
        dayPriceChangeLabel.font = .systemFont(ofSize: smallFontSize, weight: .regular)
        dayPriceChangeLabel.textColor = UIColor.black
        dayPriceChangeLabel.textAlignment = .right
        dayPriceChangeLabel.numberOfLines = 1
        dayPriceChangeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dayPriceChangeLabel)

    }
    
    func layoutViews() {
        logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4.0).isActive = true
        logoImageView.widthAnchor.constraint(equalToConstant: contentView.frame.height - 8).isActive = true
        logoImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 4.0).isActive = true
        logoImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4.0).isActive = true
        
        symbolLabel.topAnchor.constraint(equalTo: logoImageView.topAnchor, constant: 3.0).isActive = true
        symbolLabel.heightAnchor.constraint(equalToConstant: labelHeigth).isActive = true
        symbolLabel.leftAnchor.constraint(equalTo: logoImageView.rightAnchor, constant: 10.0).isActive = true
        
        companyLabel.heightAnchor.constraint(equalToConstant: labelHeigth).isActive = true
        companyLabel.leftAnchor.constraint(equalTo: logoImageView.rightAnchor, constant: 10.0).isActive = true
        companyLabel.widthAnchor.constraint(equalToConstant: self.frame.width/2-20).isActive = true
        companyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3.0).isActive = true
        
        priceLabel.topAnchor.constraint(equalTo: symbolLabel.topAnchor).isActive = true
        priceLabel.heightAnchor.constraint(equalToConstant: labelHeigth).isActive = true
        priceLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10.0).isActive = true
        
        dayPriceChangeLabel.heightAnchor.constraint(equalToConstant: labelHeigth).isActive = true
        dayPriceChangeLabel.bottomAnchor.constraint(equalTo: companyLabel.bottomAnchor).isActive = true
        dayPriceChangeLabel.rightAnchor.constraint(equalTo: priceLabel.rightAnchor).isActive = true
        
        starButton.centerYAnchor.constraint(equalTo: symbolLabel.centerYAnchor).isActive = true
        starButton.heightAnchor.constraint(equalToConstant: bigFontSize*2).isActive = true
        starButton.widthAnchor.constraint(equalToConstant: bigFontSize*2).isActive = true
        starButton.leftAnchor.constraint(equalTo: symbolLabel.rightAnchor, constant: 2.0).isActive = true
    }
    
    
    @objc private func buttonPressed(_ sender: UIButton) {
        starButtonStatus.toggle()
        
        if let callback = self.starButtonCallback {
            callback(starButtonStatus)
        }
    }
   
}
