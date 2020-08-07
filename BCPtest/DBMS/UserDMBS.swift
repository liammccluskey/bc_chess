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
import CoreData

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
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        if let result = try? context.fetch(NSFetchRequest<PuzzledUser>(entityName: "PuzzledUser")) {
            for pa in result {
                context.delete(pa)
            }
        }
        let puzzledUser = PuzzledUser(context: context)
        puzzledUser.puzzle_Elo = 1200
        puzzledUser.puzzleB_Elo = 1200
        puzzledUser.rush3_HS = 0
        puzzledUser.rush3B_HS = 0
        puzzledUser.rush5_HS = 0
        puzzledUser.rush5B_HS = 0
        puzzledUser.registerTimestamp = Date()
        do { try context.save() }
        catch { print("couldnt init puzzledUser coredata obj") }
        
        Firestore.firestore().collection("users").document(uid).setData([
            "PRUSH5_HS": 0,
            "PRUSH3_HS": 0,
            "PRUSH5B_HS": 0,
            "PRUSH3B_HS": 0,
            "USERNAME": username,
            "UID": uid
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
    
    /*
    func addCompletedPuzzle(completedPuzzle: PUZZLE_COMPLETED, forUID uid: String) {
        let docRef = Firestore.firestore().collection("users").document(uid)
        docRef.updateData([
            "PUZZLES_COMPLETED": FieldValue.arrayUnion([completedPuzzle])
        ])
    }
    */
}


struct User: Codable {
    var PRUSH5_HS: Int
    var PRUSH3_HS: Int
    var PRUSH5B_HS: Int
    var PRUSH3B_HS: Int
    var USERNAME: String
    var UID: String
}




