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
    
    var yourTipsViewModel : YourTipsViewModel!
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViewModel()
        refreshControl.addTarget(self, action: #selector(self.refreshData), for: .valueChanged)
        tableview.addSubview(refreshControl)
        yourTipsViewModel.getAndSortShifts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // deselect the selected row if any
        let selectedRow: IndexPath? = tableview.indexPathForSelectedRow
        if let selectedRow = selectedRow {
            tableview.deselectRow(at: selectedRow, animated: true)
        }
    }
    
    func initViewModel() {
        yourTipsViewModel = YourTipsViewModel()
        yourTipsViewModel.displayError = { (title, message) in
            DispatchQueue.main.async {
                displayAlert(title, message: message, sender: self)
            }
        }
        yourTipsViewModel.finishedLoading = {
            DispatchQueue.main.async {
                endLoadingView()
                self.refreshControl.endRefreshing()
            }
        }
        yourTipsViewModel.reloadTable = {
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
        }
    }
    
    @objc func refreshData() {
        startLoadingView(controller: self)
        yourTipsViewModel.getAndSortShifts()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return yourTipsViewModel.cumulatedShifts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "YourTipsCell", for: indexPath) as! YourTipsCell
        cell.dateLabel.text = createDateFormatter(withFormat: "MM/dd/YYYY").string(from: (yourTipsViewModel.cumulatedShifts?[indexPath.row].date)!)
        cell.tipsLabel.text = createCurrencyFormatter().string(from: (yourTipsViewModel.cumulatedShifts?[indexPath.row].tips)! as NSNumber)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "YourTipsDetailController") as! YourTipsDetailController
        detailVC.shiftsDict = yourTipsViewModel.shiftsDict
        detailVC.cumulatedShift = yourTipsViewModel.cumulatedShifts?[indexPath.row]
        
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}
