//
//  LoadingView.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 8/22/22.
//

import Foundation
import UIKit

public class LoadingView : UIView {
    
    let centerView: UIView
    let activityIndicator: UIActivityIndicatorView
    let loadingLabel: UILabel
    
    init() {
        let frame = UIScreen.main.bounds
        
        centerView = UIView(frame: CGRect(x: frame.width/2 - 50, y: frame.height/2 - 50, width: 100, height: 100))
        centerView.backgroundColor = .black
        centerView.layer.cornerRadius = 8
        centerView.layer.masksToBounds = true
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: centerView.frame.minX, y: centerView.frame.minY + 10, width: 100, height: 40))
        activityIndicator.style = .large
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        
        loadingLabel = UILabel(frame: CGRect(x: centerView.frame.minX, y: centerView.frame.midY, width: 100, height: 40))
        loadingLabel.text = "Loading..."
        loadingLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        loadingLabel.adjustsFontSizeToFitWidth = true
        loadingLabel.textColor = .white
        loadingLabel.textAlignment = .center
        
        super.init(frame: frame)
        self.frame = frame
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        self.addSubview(centerView)
        self.addSubview(activityIndicator)
        self.addSubview(loadingLabel)
        activityIndicator.startAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder is not needed")
    }
}
