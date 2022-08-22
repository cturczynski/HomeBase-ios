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
    
    var timeclockShifts = [IndividualShift]()
    var openShift : Shift?
    var position : Position = Position.allCases[0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clockInButton.addTarget(self, action: #selector(self.clockInOutAction), for: .touchUpInside)
        getTodaysShift()
        makeIndividualShifts()
    }
    
    func makeIndividualShifts() {
        var shifts = currentUserShifts?.filter({ $0.clockIn != nil })
        shifts?.sort(by: { (lhs, rhs) in
            if lhs.date == rhs.date {
                return lhs.clockIn! > rhs.clockIn!
            }
            return lhs.date > rhs.date
        })
        
        for shift in shifts! {
            let individualShifts = individualShiftsFromShift(shift: shift)
            if individualShifts.1 != nil {
                timeclockShifts.append(individualShifts.1!)
            }
            timeclockShifts.append(individualShifts.0!)
        }
        tableview.reloadData()
    }
    
    func getTodaysShift() {
        var todaysShifts = currentUserShifts?.filter({ shift in
            Calendar.current.isDateInToday(shift.date) && shift.clockIn != nil
        })
        if !todaysShifts!.isEmpty {
            todaysShifts?.sort(by: { $0.clockIn! > $1.clockIn! })
            if todaysShifts![0].clockOut == nil {
                openShift = todaysShifts![0]
                clockInButton.setTitle("Clock Out", for: .normal)
            }
        }
    }
    
    func individualShiftsFromShift(shift: Shift) -> (IndividualShift?, IndividualShift?) {
        var returnShifts : (IndividualShift?, IndividualShift?) = (nil, nil)
        
        let clockIn = IndividualShift.init(date: shift.date, clockTime: shift.clockIn!, clockDirection: "In", totalShiftTime: "")
        returnShifts.0 = clockIn
        
        if shift.clockOut != nil {
            let diff = calculateShiftHours(inTime: shift.clockIn!, outTime: shift.clockOut!)
            let clockOut = IndividualShift.init(date: shift.date, clockTime: shift.clockOut!, clockDirection: "Out", totalShiftTime: String(format: "%.2f", diff))
            returnShifts.1 = clockOut
        }
        
        return returnShifts
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
        position = Position.allCases[row]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeclockShifts.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let shift = timeclockShifts[indexPath.row]
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
    
    func clockOutAndUpdateShift() {
        openShift?.clockOut = Date()
        ShiftRequest(action: "update").saveToDb(obj: openShift!) { [weak self] result in
            DispatchQueue.main.async {
                endLoadingView()
                switch result {
                case .failure(let error):
                    print(error)
                    displayAlert("Error", message: "Could not clock out of existing open shift. Please contact support.", sender: self!)
                case .success(_):
                    let individualShifts = self?.individualShiftsFromShift(shift: (self?.openShift!)!)
                    self?.timeclockShifts.insert((individualShifts?.1!)!, at: 0)
                    self?.openShift = nil
                    self!.tableview.reloadData()
                    self?.clockInButton.setTitle("Clock In", for: .normal)
                }
            }
        }
    }
    
    func clockInNewShift() {
        var newShift = Shift(id: 0, date: Date(), employeeId: currentUser!.id, position: position, start: Date(), end: Date(), clockIn: Date(), clockOut: nil, tips: nil, totalTips: nil)

        ShiftRequest(action: "create").saveToDb(obj: newShift) { [weak self] result in
            DispatchQueue.main.async {
                endLoadingView()
                switch result {
                case .failure(let error):
                    print(error)
                    displayAlert("Error", message: "Could not clock in new shift. Please contact support.", sender: self!)
                case .success(let updateResult):
                    newShift.id = updateResult.insertId ?? 0
                    let individualShifts = self?.individualShiftsFromShift(shift: newShift)
                    self?.timeclockShifts.insert((individualShifts?.0!)!, at: 0)
                    self?.openShift = newShift
                    currentUserShifts?.append(newShift)
                    self!.tableview.reloadData()
                    self?.clockInButton.setTitle("Clock Out", for: .normal)
                }
            }
        }
    }
    
    //get updated shift array for currentUserShifts
    @objc func clockInOutAction() {
        startLoadingView(controller: self)
        Task {
            let updatedShifts = await ShiftRequest(id: nil, employee: currentUser?.id, date: nil, start: nil, end: nil).refreshShifts()
            if updatedShifts == nil {
                displayAlert("Error", message: "Could not get updated shifts at this time. Please try again later.", sender: self)
                return
            } else {
                currentUserShifts = updatedShifts
                getTodaysShift()
                makeIndividualShifts()
            }
            if openShift != nil {
                clockOutAndUpdateShift()
            } else {
                clockInNewShift()
            }
        }
    }
}
