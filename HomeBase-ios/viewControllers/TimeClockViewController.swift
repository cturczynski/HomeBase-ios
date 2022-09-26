//
//  TimeClockViewController.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 6/27/22.
//

import Foundation
import UIKit

class TimeClockViewController: NavBarViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var positionPickerView: UIPickerView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var clockInButton: UIButton!
    
    var timeClockViewModel : TimeClockViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViewModel()
        timeClockViewModel.getShifts()
        timeClockViewModel.getTodaysShift()
        clockInButton.addTarget(self, action: #selector(self.clockInOutAction), for: .touchUpInside)
    }
    
    func initViewModel() {
        timeClockViewModel = TimeClockViewModel()
        timeClockViewModel.displayError = { (title, message) in
            DispatchQueue.main.async {
                displayAlert(title, message: message, sender: self)
            }
        }
        timeClockViewModel.updateClockButtonText = {
            DispatchQueue.main.async {
                self.clockInButton.setTitle((self.timeClockViewModel?.clockButtonText)!, for: .normal)
            }
        }
        timeClockViewModel.reloadTable = {
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        Position.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Position.allCases[row].rawValue
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        timeClockViewModel.position = Position.allCases[row]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeClockViewModel.timeclockShifts?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let shift = (timeClockViewModel.timeclockShifts?[indexPath.row])!
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimeClockCell", for: indexPath) as! TimeClockCell
        cell.dateLabel.text = createDateFormatter(withFormat: "MM/dd/yy").string(from: shift.date)
        cell.timeLabel.text = createDateFormatter(withFormat: "h:mm a").string(from: shift.clockTime)
        cell.directionLabel.text = shift.clockDirection
        cell.shiftTimeLabel.text = shift.totalShiftTime
        
        cell.dateLabel.adjustsFontSizeToFitWidth = true
        cell.timeLabel.adjustsFontSizeToFitWidth = true
        cell.directionLabel.adjustsFontSizeToFitWidth = true
        cell.shiftTimeLabel.adjustsFontSizeToFitWidth = true
        
        return cell
    }
    
    @objc func clockInOutAction() {
        startLoadingView(controller: self)
        timeClockViewModel.clockInOut()
    }
}
