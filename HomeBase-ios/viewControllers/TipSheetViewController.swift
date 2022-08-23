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
    @IBOutlet weak var totalTipsAmountLabel: UILabel!
    
    var displayShifts = [Shift]()
    let refreshControl = UIRefreshControl()
    let dispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    func getAndSortShifts() {
        dispatchGroup.enter()
        let testDate = createDateFormatter(withFormat: "yyyy-MM-dd").date(from: "2022-08-11")
        let shiftRequest = ShiftRequest.init(id: nil, employee: nil, date: testDate, start: nil, end: nil)
        shiftRequest.fetchShifts { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print(error)
                    displayAlert("Error", message: "Could not load shift data at this time.", sender: self!)
                case .success(let shifts):
                    self?.sortShifts(shifts: shifts)
                }
                self?.dispatchGroup.leave()
            }
        }
    }
    
    func sortShifts(shifts: [Shift]) {
        var filledShifts = shifts.filter { shift in
            shift.clockIn != nil && shift.clockOut != nil && shift.tips != nil
        }
        filledShifts.sort(by: { $0.clockIn! > $1.clockIn! })
        displayShifts = filledShifts
        if !displayShifts.isEmpty {
            totalTipsAmountLabel.text = createCurrencyFormatter().string(from: (displayShifts[0].totalTips ?? 0) as NSNumber)
        }
        tableview.reloadData()
    }
    
    func refreshEmployees() {
        dispatchGroup.enter()
        EmployeeRequest.init(id: nil, username: nil).fetchEmployees { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print(error)
                    displayAlert("Error", message: "Could not load employee data at this time.", sender: self!)
                case .success(let employees):
                    allEmployees = employees
                }
                self?.dispatchGroup.leave()
            }
        }
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
