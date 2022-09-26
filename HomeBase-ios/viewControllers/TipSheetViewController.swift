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
    
    var tipSheetViewModel : TipSheetViewModel!
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViewModel()
        
        dateLabel.text = createDateFormatter(withFormat: "yyyy-MM-dd").string(from: tipSheetViewModel.tipSheetDate!)
        dateLabel.adjustsFontSizeToFitWidth = true
        
        refreshControl.addTarget(self, action: #selector(self.refreshData), for: .valueChanged)
        tableview.addSubview(refreshControl)
        
        tipSheetViewModel.getAndSortShifts()
    }
    
    func initViewModel() {
        tipSheetViewModel = TipSheetViewModel()
        tipSheetViewModel.displayError = { (title, message) in
            DispatchQueue.main.async {
                displayAlert(title, message: message, sender: self)
            }
        }
        tipSheetViewModel.reloadTable = {
            DispatchQueue.main.async {
                self.tableview.reloadData()
                self.totalTipsAmountLabel.text = (self.tipSheetViewModel.displayShifts?.isEmpty)! ? createCurrencyFormatter().string(from: 0 as NSNumber) : createCurrencyFormatter().string(from: (self.tipSheetViewModel.displayShifts?[0].totalTips ?? 0) as NSNumber)
            }
        }
        tipSheetViewModel.finishedLoading = {
            DispatchQueue.main.async {
                endLoadingView()
                self.refreshControl.endRefreshing()
            }
        }
        tipSheetViewModel.updateDateUI = {
            DispatchQueue.main.async {
                self.updateDateUI()
            }
        }
    }
    
    @objc func refreshData() {
        startLoadingView(controller: self)
        tipSheetViewModel.refreshData()
    }
    
    func updateDateUI() {
        dateLabel.text = createDateFormatter(withFormat: "yyyy-MM-dd").string(from: tipSheetViewModel.tipSheetDate!)
        dateLabel.adjustsFontSizeToFitWidth = true
        refreshData()
    }
    
    @IBAction func backDateButton(_ sender: Any) {
        tipSheetViewModel.changeDateAndRefresh(byDays: -1)
    }
    
    @IBAction func forwardDateButton(_ sender: Any) {
        tipSheetViewModel.changeDateAndRefresh(byDays: 1)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tipSheetViewModel.displayShifts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TipSheetCell", for: indexPath) as! TipSheetCell
        let shift = (tipSheetViewModel.displayShifts?[indexPath.row])!
        
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
