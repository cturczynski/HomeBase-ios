//
//  YourTipsViewModel.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 9/25/22.
//

import Foundation

class YourTipsViewModel: ViewModel {
    
    var reloadTable: (() -> Void)?
    
    var shiftsDict : [Date : [Shift]]?
    var cumulatedShifts : [CumulativeShift]?
    
    //get all of the shifts for our user and only send forward the ones with tips,
    //as that is only what we are populating in this tableview
    func getAndSortShifts() {
        let shiftRequest = ShiftRequest.init(id: nil, employee: currentUser?.id, date: nil, start: nil, end: nil)
        shiftRequest.fetchShifts { [weak self] result in
            switch result {
            case .failure(let error):
                print("ERROR: \n\(error)")
                self?.errorMessage = DisplayError(title: "Error", message: "Could not load shift data at this time.\n\(error)")
            case .success(let shifts):
                let filledShifts = shifts.filter { $0.tips != nil }
                self?.sortAndCumulateShifts(shifts: filledShifts)
            }
            self?.finishedLoading?()
        }
    }
    
    //an employee may have multiple complete shifts in a day, so we need to group the shifts by date
    //and sum the tips for each date. CumulativeShift object captures this grouped sum for the display array
    func sortAndCumulateShifts(shifts: [Shift]) {
        shiftsDict = [Date : [Shift]]()
        cumulatedShifts = [CumulativeShift]()
        for shift in shifts {
            if shiftsDict?[shift.date] == nil {
                shiftsDict?[shift.date] = [Shift]()
            }
            shiftsDict?[shift.date]?.append(shift)
        }
        for key in (shiftsDict?.keys)! {
            var cumShift = CumulativeShift(date: key, tips: 0.0)
            for shift in (shiftsDict?[key])! {
                cumShift.tips += shift.tips!
            }
            cumulatedShifts?.append(cumShift)
        }
        cumulatedShifts?.sort(by: { $0.date > $1.date })
        self.reloadTable?()
    }
}
