//
//  File.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 7/29/22.
//

import Foundation
import UIKit

//easy alert controller function
public func displayAlert(_ title:String, message:String, sender: UIViewController) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    sender.present(alert, animated: true, completion: nil)
}

//easy delay making function
public func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

public func goToViewController(vcId: String, fromController: UIViewController) {
    guard let vc = fromController.storyboard?.instantiateViewController(withIdentifier: vcId) else {return}
    vc.modalPresentationStyle = .fullScreen
    fromController.present(vc, animated: true, completion: nil)
}

public func createDateFormatter(withFormat: String) -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = withFormat
    return dateFormatter
}

public func createCurrencyFormatter() -> NumberFormatter {
    let numFormatter = NumberFormatter()
    numFormatter.numberStyle = .currency
    return numFormatter
}

public func formatPhoneNumber(phone: String) -> String {
    if phone.count < 10 {
        return phone
    }
    let first3 = String(phone[phone.index(phone.startIndex, offsetBy: 0)...phone.index(phone.startIndex, offsetBy: 2)])
    let next3 = String(phone[phone.index(phone.startIndex, offsetBy: 3)...phone.index(phone.startIndex, offsetBy: 5)])
    let last4 = String(phone[phone.index(phone.startIndex, offsetBy: 6)...phone.index(phone.startIndex, offsetBy: 9)])
    
    let phoneString = "(" + first3 + ") " + next3 + "-" + last4
    return phoneString
}

public func calculateShiftHours(inTime: Date, outTime: Date) -> Double{
    let diffComponents = Calendar.current.dateComponents([.hour, .minute], from: inTime, to: outTime)
    let diff = Double(diffComponents.hour!) + Double(diffComponents.minute!)/60.0
    return diff
}
