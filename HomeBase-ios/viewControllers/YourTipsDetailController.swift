//
//  YourTipsDetailController.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 6/27/22.
//

import Foundation
import UIKit

class YourTipsDetailController: NavBarViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var clockInLabel: UILabel!
    @IBOutlet weak var clockOutLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var totalTipsLabel: UILabel!
    @IBOutlet weak var yourTipsLabel: UILabel!
    
    var shiftsDict : [Date : [Shift]]?
    var cumulatedShift : CumulativeShift?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let cumulatedShift = cumulatedShift, let shiftsDict = shiftsDict {
            let shiftArray = shiftsDict[cumulatedShift.date]!
            let firstShift = shiftArray[0]
            
            dateLabel.text = createDateFormatter(withFormat: "MM/dd/YYYY").string(from: cumulatedShift.date)
            if shiftArray.count > 1 {
                clockInLabel.text = "Various times"
                clockOutLabel.text = "Various times"
                if Set(arrayLiteral: shiftArray.map({ $0.position })).count > 1 {
                    positionLabel.text = "Various positions"
                } else {
                    positionLabel.text = firstShift.position.rawValue
                }
            } else {
                let dateFormatter = createDateFormatter(withFormat: "h:mm a")
                clockInLabel.text = dateFormatter.string(from: firstShift.clockIn!)
                clockOutLabel.text = dateFormatter.string(from: firstShift.clockOut!)
                positionLabel.text = firstShift.position.rawValue
            }
            let numFormatter = createCurrencyFormatter()
            totalTipsLabel.text = numFormatter.string(from: firstShift.totalTips! as NSNumber)
            yourTipsLabel.text = numFormatter.string(from: cumulatedShift.tips as NSNumber)
            
            dateLabel.adjustsFontSizeToFitWidth = true
            clockInLabel.adjustsFontSizeToFitWidth = true
            clockOutLabel.adjustsFontSizeToFitWidth = true
            positionLabel.adjustsFontSizeToFitWidth = true
            totalTipsLabel.adjustsFontSizeToFitWidth = true
            yourTipsLabel.adjustsFontSizeToFitWidth = true
        }
    }
}
