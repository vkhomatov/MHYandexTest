//
//  SearchView.swift
//  YandexTest
//
//  Created by Vitaly Khomatov on 24.03.2021.
//

import UIKit

class StocksSearchView: UIView {
    
    var popularLabel = UILabel(frame: .zero)
    var yoursLabel = UILabel(frame: .zero)
    var popularScrollView = UIScrollView(frame: .zero)
    var yoursScrollView = UIScrollView(frame: .zero)
    var popularLabels = [UILabel]()
    var yoursLabels = [UILabel]()
    var labelCallback: ((_ selectedLabelText: String) -> Void)?
    
    var popularStrings: [String] = [] {
        didSet {
            setPopularLabels()
            setupTitleLabel(label: popularLabel, text: "Popular requests")
            setupScrollView(scrollView: popularScrollView, labels: popularLabels)
            setInteractiveElements(labels: popularLabels)
            popularLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20.0).isActive = true
            popularLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
            popularLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10.0).isActive = true
            layoutScrollView(scrollView: popularScrollView, labels: popularLabels, capLabel: popularLabel)
        }
    }
    
    var yoursStrings: [String] = [] //{
//        didSet {
//            setupTitleLabel(label: yoursLabel, text: "You’ve searched for this")
//            setYoursLabels()
//            setupScrollView(scrollView: yoursScrollView, labels: yoursLabels)
//            setInteractiveElements(labels: yoursLabels)
//            yoursLabel.topAnchor.constraint(equalTo: popularScrollView.bottomAnchor, constant: 30.0).isActive = true
//            yoursLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
//            yoursLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10.0).isActive = true
//            layoutScrollView(scrollView: yoursScrollView, labels: yoursLabels, capLabel: yoursLabel)
//        }
    //}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.addSubview(popularScrollView)
        self.addSubview(yoursScrollView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setPopularLabels() {
        for num in 0..<popularStrings.count {
            popularLabels.append(createNewLabel(text: popularStrings[num]))
            popularScrollView.addSubview(popularLabels[num])
        }
    }
    
    func setYoursLabels() {
        for label in yoursScrollView.subviews {
            for recognizer in label.gestureRecognizers ?? [] {
                label.removeGestureRecognizer(recognizer)
            }
            label.removeFromSuperview()
        }
        for num in 0..<yoursStrings.count {
            yoursLabels.append(createNewLabel(text: yoursStrings[num]))
            yoursScrollView.addSubview(yoursLabels[num])
        }
    }
    
    func setupScrollView(scrollView: UIScrollView, labels: [UILabel]) {
        
        var scrollWidth: CGFloat = 0
        var labelsWidth: CGFloat = 0
        
        for label in labels {
            labelsWidth += label.frame.width + 30
        }
        
        if labelsWidth > self.frame.width*2 {
            var firstLabelsW = CGFloat()
            var secondLabelsW = CGFloat()
            
            for num in 0...labels.count/2 + labels.count % 2 {
                firstLabelsW += labels[num].frame.width + 30
            }
            
            for num in (labels.count/2 + labels.count % 2)..<labels.count {
                secondLabelsW += labels[num].frame.width + 30
            }
            
            scrollWidth =  firstLabelsW > secondLabelsW ? firstLabelsW + 100 : secondLabelsW + 100
        } else {
            for label in labels {
                scrollWidth = (label.bounds.width + 10+30) * CGFloat(labels.count + labels.count % 2) + 100
            }
        }
        
        scrollWidth = scrollWidth > self.frame.width ? scrollWidth : self.frame.width
        scrollView.contentSize = CGSize(width: scrollWidth, height: 0)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = true
        scrollView.clipsToBounds = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func createNewLabel(text: String) -> UILabel {
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
    
    func setupTitleLabel(label: UILabel, text: String) {
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor.black
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.sizeToFit()
        self.addSubview(label)
    }
    
    
    private func layoutScrollView(scrollView: UIScrollView, labels: [UILabel], capLabel: UILabel) {
        
        scrollView.topAnchor.constraint(equalTo: capLabel.bottomAnchor, constant: 5.0).isActive = true
        scrollView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        scrollView.leftAnchor.constraint(equalTo: capLabel.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        if labels.count == 1 {
            labels[0].leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 5.0).isActive = true
            labels[0].topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 5.0).isActive = true
            labels[0].heightAnchor.constraint(equalToConstant: 35).isActive = true
            labels[0].widthAnchor.constraint(equalToConstant: labels[0].frame.width+30).isActive = true
        } else {
            for label in 0..<labels.count/2 {
                labels[label].topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 5.0).isActive = true
                labels[label].heightAnchor.constraint(equalToConstant: 35).isActive = true
                labels[label].widthAnchor.constraint(equalToConstant: labels[label].frame.width+30).isActive = true
                if label == 0 {
                    labels[label].leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 5.0).isActive = true
                } else {
                    labels[label].leftAnchor.constraint(equalTo: labels[label-1].rightAnchor, constant: 5.0).isActive = true
                }
            }
            
            for label in labels.count/2..<labels.count {
                labels[label].topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 45.0).isActive = true
                labels[label].heightAnchor.constraint(equalToConstant: 35).isActive = true
                labels[label].widthAnchor.constraint(equalToConstant: labels[label].frame.width+30).isActive = true
                if label == labels.count/2 {
                    labels[label].leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 5.0).isActive = true
                } else if label > 0 {
                    labels[label].leftAnchor.constraint(equalTo: labels[label-1].rightAnchor, constant: 5.0).isActive = true
                }
            }
        }
    }
    
    private func setInteractiveElements(labels: [UILabel]) {
        for label in labels {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.labelPressed(sender:)))
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(tap)
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
