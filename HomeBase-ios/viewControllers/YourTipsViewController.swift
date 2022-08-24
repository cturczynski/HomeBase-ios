//
//  YourTipsViewController.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 6/27/22.
//

import Foundation
import UIKit

class YourTipsViewController: NavBarViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableview: UITableView!
    
    var shiftsDict = [Date : [Shift]]()
    var cumulatedShifts = [CumulativeShift]()
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action: #selector(self.refreshData), for: .valueChanged)
        tableview.addSubview(refreshControl)
        getAndSortShifts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // deselect the selected row if any
        let selectedRow: IndexPath? = tableview.indexPathForSelectedRow
        if let selectedRow = selectedRow {
            tableview.deselectRow(at: selectedRow, animated: true)
        }
    }
    
    @objc func refreshData() {
        startLoadingView(controller: self)
        getAndSortShifts()
    }
    
    //get all of the shifts for our user and only send forward the ones with tips,
    //as that is only what we are populating in this tableview
    func getAndSortShifts() {
        let shiftRequest = ShiftRequest.init(id: nil, employee: currentUser?.id, date: nil, start: nil, end: nil)
        shiftRequest.fetchShifts { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print("ERROR: \n\(error)")
                    displayAlert("Error", message: "Could not load shift data at this time.\n\(error)", sender: self!)
                case .success(let shifts):
                    let filledShifts = shifts.filter { $0.tips != nil }
                    self?.sortAndCumulateShifts(shifts: filledShifts)
                }
                self?.refreshControl.endRefreshing()
                endLoadingView()
            }
        }
    }
    
    //an employee may have multiple complete shifts in a day, so we need to group the shifts by date
    //and sum the tips for each date. CumulativeShift object captures this grouped sum for the display array
    func sortAndCumulateShifts(shifts: [Shift]) {
        shiftsDict = [Date : [Shift]]()
        cumulatedShifts = [CumulativeShift]()
        for shift in shifts {
            shiftsDict[shift.date] = shiftsDict[shift.date] == nil ? [Shift]() : shiftsDict[shift.date]
            shiftsDict[shift.date]?.append(shift)
        }
        for key in shiftsDict.keys {
            var cumShift = CumulativeShift(date: key, tips: 0.0)
            for shift in shiftsDict[key]! {
                cumShift.tips += shift.tips!
            }
            cumulatedShifts.append(cumShift)
        }
        cumulatedShifts.sort(by: { $0.date > $1.date })
        tableview.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cumulatedShifts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "YourTipsCell", for: indexPath) as! YourTipsCell
        cell.dateLabel.text = createDateFormatter(withFormat: "MM/dd/YYYY").string(from: cumulatedShifts[indexPath.row].date)
        cell.tipsLabel.text = createCurrencyFormatter().string(from: cumulatedShifts[indexPath.row].tips as NSNumber)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "YourTipsDetailController") as! YourTipsDetailController
        detailVC.shiftsDict = shiftsDict
        detailVC.cumulatedShift = cumulatedShifts[indexPath.row]
        
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}
