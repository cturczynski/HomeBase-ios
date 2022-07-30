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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let shiftRequest = ShiftRequest.init(id: nil, employee: currentUser?.id, date: nil, start: nil, end: nil)
        shiftRequest.fetchShifts { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let shifts):
                print(shifts)
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "YourTipsCell", for: indexPath) as! YourTipsCell
        return cell
    }
}
