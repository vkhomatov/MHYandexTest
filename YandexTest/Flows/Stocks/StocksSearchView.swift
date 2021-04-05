//
//  SearchView.swift
//  YandexTest
//
//  Created by Vitaly Khomatov on 24.03.2021.
//

import UIKit

class StocksSearchView: UIView {
    
    private var popularLabel = UILabel(frame: .zero)
    private var yoursLabel = UILabel(frame: .zero)
    
    private var popularScrollView = UIScrollView(frame: .zero)
    private var yoursScrollView = UIScrollView(frame: .zero)
    
    private var popularLabels = [UILabel]()
    private var yoursLabels = [UILabel]()
    
        
    private var popularTopStackView = UIStackView()
    private var popularBottomStackView = UIStackView()
    
    private var yoursTopStackView = UIStackView()
    private var yoursBottomStackView = UIStackView()


    public var labelCallback: ((_ selectedLabelText: String) -> Void)?
    
    private var top: Bool = true
    
    
    public var newLabel: String = "" {
        didSet {
            addSearchLabel(label: newLabel)
        }
    }
    
    public var popularStrings: [String] = [] {
        didSet {
            setPopularLabels()
            setInteractiveElements(labels: popularLabels)
            setupStackView(topStackView: popularTopStackView, bottomStackView: popularBottomStackView, labels: popularLabels, scrollView: popularScrollView)
           // layoutStackViews(topStackView: popularTopStackView, bottomStackView: popularBottomStackView, scrollView: popularScrollView)
            
            setupScrollView(scrollView: popularScrollView, topStackView: popularTopStackView, bottomStackView: popularBottomStackView)
          //  layoutScrollView(scrollView: popularScrollView, capLabel: popularLabel)
        }
    }
    
    public var yoursStrings: [String] = [] {
        didSet {
            setYoursLabels()
            setInteractiveElements(labels: yoursLabels)
            
            setupStackView(topStackView: yoursTopStackView, bottomStackView: yoursBottomStackView, labels: yoursLabels, scrollView: yoursScrollView)
           // layoutStackViews(topStackView: yoursTopStackView, bottomStackView: yoursBottomStackView, scrollView: yoursScrollView)

            setupScrollView(scrollView: yoursScrollView, topStackView: yoursTopStackView, bottomStackView: yoursBottomStackView)
          //  layoutScrollView(scrollView: yoursScrollView, capLabel: yoursLabel)
        }
    }
    
    
    private func setupStackView(topStackView: UIStackView, bottomStackView: UIStackView, labels: [UILabel], scrollView: UIScrollView) {
        
        topStackView.distribution = .equalSpacing
        topStackView.alignment = .lastBaseline
        topStackView.axis = .horizontal
        topStackView.spacing = 10
        topStackView.translatesAutoresizingMaskIntoConstraints = false
        
        bottomStackView.distribution = .equalSpacing
        bottomStackView.alignment = .lastBaseline
        bottomStackView.axis = .horizontal
        bottomStackView.spacing = 10
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        
        for num in 0..<labels.count/2 {
            topStackView.addArrangedSubview(labels[num])
        }
        
        for num in labels.count/2..<labels.count {
            bottomStackView.addArrangedSubview(labels[num])
        }

        topStackView.sizeToFit()
        bottomStackView.sizeToFit()

        scrollView.addSubview(topStackView)
        scrollView.addSubview(bottomStackView)
    }
    
    
    private func addSearchLabel(label: String) {
        let label = createNewLabel(text: label)
        yoursLabels.append(label)
        layoutSearchLabel(label: label)

        if top {
            yoursTopStackView.addArrangedSubview(label)
        } else {
            yoursBottomStackView.addArrangedSubview(label)
        }

        yoursScrollView.contentSize = CGSize(width: getStackViewWidth(topStackView: yoursTopStackView, bottomStackView: yoursBottomStackView), height: 0)

        top.toggle()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.addSubview(popularScrollView)
        self.addSubview(yoursScrollView)
        setupTitleLabel(label: popularLabel, text: "Popular requests")
        setupTitleLabel(label: yoursLabel, text: "You’ve searched for this")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutCaptionLabels()
        
        layoutStackViews(topStackView: yoursTopStackView, bottomStackView: yoursBottomStackView, scrollView: yoursScrollView)
        layoutScrollView(scrollView: yoursScrollView, capLabel: yoursLabel)
        
        layoutStackViews(topStackView: popularTopStackView, bottomStackView: popularBottomStackView, scrollView: popularScrollView)
        layoutScrollView(scrollView: popularScrollView, capLabel: popularLabel)
    }
    
    private func setPopularLabels() {
        for num in 0..<popularStrings.count {
            let label = createNewLabel(text: popularStrings[num])
            popularLabels.append(label)
            layoutSearchLabel(label: label)
        }
    }
    
    private func setYoursLabels() {
        for num in 0..<yoursStrings.count {
            let label = createNewLabel(text: yoursStrings[num])
            yoursLabels.append(label)
            layoutSearchLabel(label: label)
        }
    }
    
    private func setupScrollView(scrollView: UIScrollView, topStackView: UIStackView, bottomStackView: UIStackView) {
        scrollView.contentSize = CGSize(width: getStackViewWidth(topStackView: topStackView, bottomStackView: bottomStackView, coeff: 30), height: 0)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = true
        scrollView.clipsToBounds = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func getStackViewWidth(topStackView: UIStackView, bottomStackView: UIStackView, coeff: CGFloat = 0) -> CGFloat {

        var topStackViewWidth: CGFloat = 0
        var bottomStackViewWidth: CGFloat = 0
        topStackView.arrangedSubviews.forEach {
            topStackViewWidth += $0.frame.width + 10 + coeff
        }
        bottomStackView.arrangedSubviews.forEach {
            bottomStackViewWidth += $0.frame.width + 10 + coeff
        }
        return topStackViewWidth > bottomStackViewWidth ? topStackViewWidth + 10 : bottomStackViewWidth + 10
    }
    
    private func createNewLabel(text: String) -> UILabel {
        let searchLabel = UILabel(frame: .zero)
        searchLabel.textAlignment = .center
        searchLabel.font = .systemFont(ofSize: 12, weight: .regular)
        searchLabel.textColor = UIColor.black
        searchLabel.numberOfLines = 1
        searchLabel.clipsToBounds = true
        searchLabel.translatesAutoresizingMaskIntoConstraints = false
        searchLabel.text = text
        searchLabel.backgroundColor = .systemGray6
        searchLabel.layer.cornerRadius = 15
        searchLabel.sizeToFit()
        return searchLabel
    }
    
    private func setupTitleLabel(label: UILabel, text: String) {
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor.black
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.sizeToFit()
        self.addSubview(label)
    }
    
    private func layoutSearchLabel(label: UILabel) {
        label.heightAnchor.constraint(equalToConstant: 35).isActive = true
        label.widthAnchor.constraint(equalToConstant: label.frame.width+30).isActive = true
    }
   
    private func layoutCaptionLabels() {
        popularLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20.0).isActive = true
        popularLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
        popularLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10.0).isActive = true
        
        yoursLabel.topAnchor.constraint(equalTo: popularScrollView.bottomAnchor, constant: 30.0).isActive = true
        yoursLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
        yoursLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10.0).isActive = true
    }
    
    private func layoutScrollView(scrollView: UIScrollView, capLabel: UILabel) {
        scrollView.topAnchor.constraint(equalTo: capLabel.bottomAnchor, constant: 5.0).isActive = true
        scrollView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        scrollView.leftAnchor.constraint(equalTo: capLabel.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    
    private func layoutStackViews(topStackView: UIStackView, bottomStackView: UIStackView, scrollView: UIScrollView) {
        topStackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 5.0).isActive = true
        topStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 5.0).isActive = true
        
        bottomStackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 5.0).isActive = true
        bottomStackView.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: 5.0).isActive = true
    }
    
    private func setInteractiveElements(labels: [UILabel]) {
        labels.forEach {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.labelPressed(sender:)))
            $0.isUserInteractionEnabled = true
            $0.addGestureRecognizer(tap)
        }
    }
    
    @objc private func labelPressed(sender: UIGestureRecognizer) {
        if let searchLabelText = (sender.view as? UILabel)?.text {
            if let callback = self.labelCallback {
                callback(searchLabelText)
            }
        }
    }
    
}
