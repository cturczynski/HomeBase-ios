//
//  FirebaseAuthManager.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 10/13/22.
//

import Foundation
import FirebaseAuth

class FirebaseAuthManager {
    
    func signUp(email: String, password: String, completion: @escaping (_ errorString: String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if authResult?.user != nil && error == nil {
                completion(nil)
            } else {
                print(error as Any)
                completion(error?.localizedDescription)
            }
        }
    }
    
    func login(email: String, password: String, completion: @escaping (_ errorString: String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if authResult?.user != nil && error == nil {
                completion(nil)
            } else {
                print(error as Any)
                completion(error?.localizedDescription)
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("ERROR: \(error.localizedDescription)")
        }
    }
}
