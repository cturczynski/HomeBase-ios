//
//  TimeClockViewModel.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 9/25/22.
//

import Foundation

class TimeClockViewModel: ViewModel {
    
    var timeclockShifts : [IndividualShift]? {
        didSet {
            self.reloadTable?()
        }
    }
    var openShift : Shift?
    var position : Position = Position.allCases[0]
    var updateClockButtonText : (() -> Void)?
    var clockButtonText : String? {
        didSet {
            self.updateClockButtonText?()
        }
    }
    var reloadTable: (() -> Void)?
    
    //get the individual shifts from all the user's shifts, and append them to our display array in order
    func getShifts(userShifts: [Shift]) {
        timeclockShifts = [IndividualShift]()
        var shifts = userShifts.filter({ $0.clockIn != nil })
        shifts.sort(by: { (lhs, rhs) in
            if lhs.date == rhs.date {
                return lhs.clockIn! > rhs.clockIn!
            }
            return lhs.date > rhs.date
        })
        
        for shift in shifts {
            let individualShifts = individualShiftsFromShift(shift: shift)
            if individualShifts.1 != nil {
                timeclockShifts?.append(individualShifts.1!)
            }
            timeclockShifts?.append(individualShifts.0!)
        }
    }
    
    //need to see if there's a current shift already started for today, and change UI accordingly
    func getTodaysShift(userShifts: [Shift]) {
        var todaysShifts = userShifts.filter({ shift in
            Calendar.current.isDateInToday(shift.date) && shift.clockIn != nil
        })
        if !todaysShifts.isEmpty {
            todaysShifts.sort(by: { $0.clockIn! > $1.clockIn! })
            if todaysShifts[0].clockOut == nil {
                openShift = todaysShifts[0]
                clockButtonText = "Clock Out"
            } else {
                clockButtonText = "Clock In"
            }
        }
    }
    
    //create tuple of the individual in-shift and the out-shift for a shift
    //each used for their own row in the shift history
    func individualShiftsFromShift(shift: Shift) -> (IndividualShift?, IndividualShift?) {
        var returnShifts : (IndividualShift?, IndividualShift?) = (nil, nil)
        
        let clockIn = IndividualShift.init(date: shift.clockIn!, clockTime: shift.clockIn!, clockDirection: "In", totalShiftTime: "")
        returnShifts.0 = clockIn
        
        if shift.clockOut != nil {
            let diff = calculateShiftHours(inTime: shift.clockIn!, outTime: shift.clockOut!)
            let clockOut = IndividualShift.init(date: shift.clockOut!, clockTime: shift.clockOut!, clockDirection: "Out", totalShiftTime: String(format: "%.2f", diff))
            returnShifts.1 = clockOut
        }
        
        return returnShifts
    }
    
    //when we have an open shift we need to clock out of
    func clockOutAndUpdateShift() {
        openShift?.clockOut = Date()
        ShiftRequest(action: "update").saveToDb(obj: openShift!) { [weak self] result in
            switch result {
            case .failure(let error):
                print("ERROR: \n\(error)")
                self?.errorMessage = DisplayError(title: "Error", message: "Could not clock out of existing open shift.\n\(error)")
            case .success(_):
                //add shift to display array and update other related variablesUI
                let individualShifts = self?.individualShiftsFromShift(shift: (self?.openShift)!)
                self?.timeclockShifts?.insert((individualShifts?.1!)!, at: 0)
                self?.openShift = nil
                
                self?.reloadTable?()
                self?.clockButtonText = "Clock In"
                self?.finishedLoading?()
            }
        }
    }
    
    //no currently open shift, so create a new one and clock in
    func clockInNewShift() {
        var newShift = Shift(id: 0, date: Date(), employeeId: currentUser!.id, position: position, start: Date(), end: Date(), clockIn: Date(), clockOut: nil, tips: nil, totalTips: nil)
        
        ShiftRequest(action: "create").saveToDb(obj: newShift) { [weak self] result in
            switch result {
            case .failure(let error):
                print("ERROR: \n\(error)")
                self?.errorMessage = DisplayError(title: "Error", message: "Could not clock in new shift.\n\(error)")
            case .success(_):
                //add shift to display array and update other related variablesUI
                let individualShifts = self?.individualShiftsFromShift(shift: newShift)
                self?.timeclockShifts?.insert((individualShifts?.0!)!, at: 0)
                self?.openShift = newShift
                currentUserShifts?.append(newShift)
                
                self?.reloadTable?()
                self?.clockButtonText = "Clock Out"
                self?.finishedLoading?()
            }
        }
    }
    
    //get updated shift array for currentUserShifts before making any updates
    //using async/await pattern here because we do not care as much about the error, just want fresh data
    //also wanted to work with Task
    func clockInOut() {
        Task {
            let updatedShifts = await ShiftRequest(id: nil, employee: currentUser?.id, date: nil, start: nil, end: nil).refreshShifts()
            if updatedShifts == nil {
                self.errorMessage = DisplayError(title: "Error", message: "Could not get updated shifts at this time. Please try again later.")
                return
            } else {
                currentUserShifts = updatedShifts
                self.getTodaysShift(userShifts: currentUserShifts!)
                self.getShifts(userShifts: currentUserShifts!)
            }
            if openShift != nil {
                clockOutAndUpdateShift()
            } else {
                clockInNewShift()
            }
        }
    }
}
