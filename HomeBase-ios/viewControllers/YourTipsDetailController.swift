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
    @IBOutlet weak var weekTotalLabel: UILabel!
    @IBOutlet weak var monthTotalLabel: UILabel!
    @IBOutlet weak var yearTotalLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
