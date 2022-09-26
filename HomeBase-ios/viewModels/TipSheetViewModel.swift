//
//  TipSheetViewModel.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 9/25/22.
//

import Foundation

class TipSheetViewModel: ViewModel {
    
    var reloadTable: (() -> Void)?
    var displayShifts : [Shift]? {
        didSet {
            self.reloadTable?()
        }
    }
    let dispatchGroup = DispatchGroup()
    var updateDateUI: (() -> Void)?
    var tipSheetDate : Date? {
        didSet {
            self.updateDateUI?()
        }
    }
    
    override init() {
        super.init()
        self.tipSheetDate = Date()
    }
    
    //get all of the shifts for today
    func getAndSortShifts() {
        dispatchGroup.enter()
        let shiftRequest = ShiftRequest.init(id: nil, employee: nil, date: tipSheetDate, start: nil, end: nil)
        shiftRequest.fetchShifts { [weak self] result in
            switch result {
            case .failure(let error):
                print("ERROR: \n\(error)")
                self?.errorMessage = DisplayError(title: "Error", message: "Could not load shift data at this time.\n\(error)")
            case .success(let shifts):
                self?.sortShifts(shifts: shifts)
            }
            self?.dispatchGroup.leave()
        }
    }
    
    //filter down to the relative shifts and sort them in order for easy readability in our display array
    func sortShifts(shifts: [Shift]) {
        var filledShifts = shifts.filter { shift in
            shift.clockIn != nil && shift.clockOut != nil && shift.tips != nil && shift.position != .manager
        }
        filledShifts.sort(by: { $0.clockIn! > $1.clockIn! })
        displayShifts = filledShifts
    }
    
    //want to get fresh employee data for accurate id -> name matching
    func refreshEmployees() {
        dispatchGroup.enter()
        EmployeeRequest.init(id: nil, username: nil).fetchEmployees { [weak self] result in
            switch result {
            case .failure(let error):
                print("ERROR: \n\(error)")
                self?.errorMessage = DisplayError(title: "Error", message: "Could not load employee data at this time.\n\(error)")
            case .success(let employees):
                allEmployees = employees
            }
            self?.dispatchGroup.leave()
        }
    }
    
    func refreshData() {
        getAndSortShifts()
        refreshEmployees()
        dispatchGroup.notify(queue: .main) {
            self.finishedLoading?()
        }
    }
    
    func changeDateAndRefresh(byDays: Int) {
        tipSheetDate = Calendar.current.date(byAdding: .day, value: byDays, to: tipSheetDate!)
    }
}
