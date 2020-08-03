//
//  UserDMBS.swift
//  BCPtest
//
//  Created by Guest on 8/2/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import FirebaseFirestore
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

let P_COMPLETED_SAMPLE: [String] = ["0,0,0,5", "0,1,1,5", "0,2,0,5", "0,0,0,5", "0,3,1,5"]

class UserDBMS {
    
    // MARK: - Properties
    
    var delegate: UserDBMSDelegate?
    
    // MARK: - Init Set/Get
    
    func isValidRegistration(email: String, password: String, confirmPassword: String) -> Bool {
        // email: verify is rutgers email
        // dorm: verify dorm exists
        // dormRoom: verify dormRoom in dorm
        // password: verify == confirmPassword and >= 6 characters
        return true
    }
    
    func initUserData(uid: String, username: String) {
        
        Firestore.firestore().collection("users").document(uid).setData([
            "PUZZLES_COMPLETED": P_COMPLETED_SAMPLE,
            "PRUSH_5": [],
            "PRUSH_3": [],
            "ELO": 1000
        ]) { (error) in
            if let error = error {
                print("user_dbms.initUserData() Error: \(error)")
            }
        }
        let changeRequest =  Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = username
        changeRequest?.commitChanges { (error) in
            if let error = error {
                print("userdbms.inituserdata() Error: couldn't set display name \(error)")
            }
        }
    }
    
    func getUser(uid: String) {
        let docRef = Firestore.firestore().collection("users").document(uid)
        docRef.getDocument { (document, error) in
            guard let document = document else { self.delegate?.sendUser(user: nil); return}
            do {
                let user: User? = try document.data(as: User.self) ?? nil
                self.delegate?.sendUser(user: user)
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: - User Data Updates
    
    func addCompletedPuzzle(completedPuzzle: PUZZLE_COMPLETED, forUID uid: String) {
        let docRef = Firestore.firestore().collection("users").document(uid)
        docRef.updateData([
            "PUZZLES_COMPLETED": FieldValue.arrayUnion([completedPuzzle])
        ])
    }
}


struct User: Codable {
    var PUZZLES_COMPLETED: [String]
    var PRUSH_5: [Int]
    var PRUSH_3: [Int]
    var ELO: Int
    
    func getCompletedPuzzles() -> [PUZZLE_COMPLETED] {
        var puzzles_completed: [PUZZLE_COMPLETED] = []
        self.PUZZLES_COMPLETED.forEach{ (p) in
            let elems = p.split(separator: ",")
            let ints = elems.map{ Int(String($0))}
            let puzzle_completed = PUZZLE_COMPLETED(TYPE: ints[0]!, INDEX: ints[1]!, CORRECT: ints[2]!, ELO_DELTA: ints[3]!)
            puzzles_completed.append(puzzle_completed)
        }
        return puzzles_completed
    }
}

struct PUZZLE_COMPLETED: Codable {
    var TYPE: Int // 0->m1, 1->m2, ...
    var INDEX: Int
    var CORRECT: Int
    var ELO_DELTA: Int
}


