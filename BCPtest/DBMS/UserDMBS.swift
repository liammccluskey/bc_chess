//
//  UserDMBS.swift
//  BCPtest
//
//  Created by Guest on 8/2/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import FirebaseFirestore

class UserDBMS {
    
    // MARK: - Properties
    
    var delegate: UserDBMSDelegate?
    let usersRef = Firestore.firestore().collection("users")
    
    // MARK: - Init Set/Get
    
    func isValidRegistration(email: String, password: String, confirmPassword: String) -> Bool {
        // email: verify is rutgers email
        // dorm: verify dorm exists
        // dormRoom: verify dormRoom in dorm
        // password: verify == confirmPassword and >= 6 characters
        return true
    }
    
    func initUserData(uid: String) {
        usersRef.document(uid).setData([
            "UID": uid
        ]) { (error) in
            if let error = error {
                print("user_dbms.initUserData() Error: \(error)")
            }
        }
        // Set currentUser.displayName to "customer", used to sign in
        /*
        let changeRequest =  Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = "customer"
        changeRequest?.commitChanges { (error) in
            if let error = error {
                print("CustomerRegisterController.registerAction() Error: couldn't set display name \(error)")
            }
        }
        */
    }
    
    func getUser(uid: String) {
        let docRef = usersRef.document(uid)
        docRef.getDocument { (document, error) in
            if let document = document {
                guard let docData = document.data() else {return}
                let user = User()
                /*
                let customer = Customer(
                    completedJobs: docData["COMPLETED_JOBS"] as! [String]
                )
                */
                self.delegate?.sendUser(user: user)
            } else {
                self.delegate?.sendUser(user: nil)
            }
        }
    }
    
    // MARK: - User Data Updates
    
    func addCompletedJob(jobID: String, forCustomerUID uid: String) {
        let docRef = customersRef.document(uid)
        docRef.updateData([
            "COMPLETED_JOBS": FieldValue.arrayUnion([jobID])
        ])
    }
}
