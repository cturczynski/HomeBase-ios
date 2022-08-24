//
//  TipSheetViewController.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 6/27/22.
//

import Foundation
import UIKit

class TipSheetViewController: NavBarViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var totalTipsAmountLabel: UILabel!
    
    var displayShifts = [Shift]()
    let refreshControl = UIRefreshControl()
    let dispatchGroup = DispatchGroup()
    var tipSheetDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateLabel.text = createDateFormatter(withFormat: "yyyy-MM-dd").string(from: tipSheetDate)
        dateLabel.adjustsFontSizeToFitWidth = true
        
        refreshControl.addTarget(self, action: #selector(self.refreshData), for: .valueChanged)
        tableview.addSubview(refreshControl)
        getAndSortShifts()
    }
    
    @objc func refreshData() {
        startLoadingView(controller: self)
        getAndSortShifts()
        refreshEmployees()
        dispatchGroup.notify(queue: .main) {
            endLoadingView()
            self.refreshControl.endRefreshing()
        }
    }
    
    //get all of the shifts for today
    func getAndSortShifts() {
        dispatchGroup.enter()
        let shiftRequest = ShiftRequest.init(id: nil, employee: nil, date: tipSheetDate, start: nil, end: nil)
        shiftRequest.fetchShifts { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print("ERROR: \n\(error)")
                    displayAlert("Error", message: "Could not load shift data at this time.", sender: self!)
                case .success(let shifts):
                    self?.sortShifts(shifts: shifts)
                }
                self?.dispatchGroup.leave()
            }
        }
    }
    
    //filter down to the relative shifts and sort them in order for easy readability in our display array
    func sortShifts(shifts: [Shift]) {
        var filledShifts = shifts.filter { shift in
            shift.clockIn != nil && shift.clockOut != nil && shift.tips != nil
        }
        filledShifts.sort(by: { $0.clockIn! > $1.clockIn! })
        displayShifts = filledShifts
        totalTipsAmountLabel.text = displayShifts.isEmpty ? createCurrencyFormatter().string(from: 0 as NSNumber) : createCurrencyFormatter().string(from: (displayShifts[0].totalTips ?? 0) as NSNumber)
        tableview.reloadData()
    }
    
    //want to get fresh employee data for accurate id -> name matching
    func refreshEmployees() {
        dispatchGroup.enter()
        EmployeeRequest.init(id: nil, username: nil).fetchEmployees { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print("ERROR: \n\(error)")
                    displayAlert("Error", message: "Could not load employee data at this time.", sender: self!)
                case .success(let employees):
                    allEmployees = employees
                }
                self?.dispatchGroup.leave()
            }
        }
    }
    
    func changeDateAndRefresh(byDays: Int) {
        tipSheetDate = Calendar.current.date(byAdding: .day, value: byDays, to: tipSheetDate)!
        dateLabel.text = createDateFormatter(withFormat: "yyyy-MM-dd").string(from: tipSheetDate)
        dateLabel.adjustsFontSizeToFitWidth = true
        refreshData()
    }
    
    @IBAction func backDateButton(_ sender: Any) {
        changeDateAndRefresh(byDays: -1)
    }
    
    @IBAction func forwardDateButton(_ sender: Any) {
        changeDateAndRefresh(byDays: 1)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayShifts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TipSheetCell", for: indexPath) as! TipSheetCell
        let shift = displayShifts[indexPath.row]
        
        //match the employeeId so we can have the employees' names here
        if let emp = allEmployees?.filter({ $0.id == shift.employeeId }), !emp.isEmpty {
            cell.empLabel.text = emp[0].name
        } else {
            cell.empLabel.text = String(shift.employeeId)
        }
        
        let dateFormatter = createDateFormatter(withFormat: "h:mm a")
        cell.inLabel.text = dateFormatter.string(from: shift.clockIn!)
        cell.outLabel.text = dateFormatter.string(from: shift.clockOut!)
        cell.hoursLabel.text = String(format: "%.2f", calculateShiftHours(inTime: shift.clockIn!, outTime: shift.clockOut!))
        cell.tipshareLabel.text = createCurrencyFormatter().string(from: (shift.tips ?? 0) as NSNumber)
        
        cell.empLabel.adjustsFontSizeToFitWidth = true
        cell.inLabel.adjustsFontSizeToFitWidth = true
        cell.outLabel.adjustsFontSizeToFitWidth = true
        cell.hoursLabel.adjustsFontSizeToFitWidth = true
        cell.tipshareLabel.adjustsFontSizeToFitWidth = true
        
        return cell
    }
}
