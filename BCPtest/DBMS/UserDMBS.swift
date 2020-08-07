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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
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
        // create PuzzledUser
        let puzzledUser = PuzzledUser(context: context)
        puzzledUser.numPuzzleAttempts = 0
        puzzledUser.numPuzzleBAttempts = 0
        puzzledUser.puzzle_Elo = 1200
        puzzledUser.puzzleB_Elo = 1200
        puzzledUser.rush3_HS = 0
        puzzledUser.rush3B_HS = 0
        puzzledUser.rush5_HS = 0
        puzzledUser.rush5B_HS = 0
        puzzledUser.registerTimestamp = Date()
        do { try context.save() }
        catch { print("couldnt init puzzledUser coredata obj") }
        
        // create PuzzleReferences
        if UserDBMS().isFirstLaunch() {
            
        }
        
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
    
    // MARK: - Core Data
    
    func getPuzzledUser() -> PuzzledUser? {
        let userRequest = NSFetchRequest<PuzzledUser>(entityName: "PuzzledUser")
        do {
            let puzzledUsers = try context.fetch(userRequest)
            if puzzledUsers.count == 1 { return puzzledUsers[0]}
            else { print("Incorrect # of users: \(puzzledUsers.count)"); return nil}
        } catch { print("CoreData Error: couldn't fetch puzzledUsers"); return nil}
    }
    
    func updatePuzzleElo(withRating: Int32, isBlindfold: Bool) {
        let userRequest = NSFetchRequest<PuzzledUser>(entityName: "PuzzledUser")
        do {
            let puzzledUsers = try context.fetch(userRequest)
            if puzzledUsers.count == 1 {
                let key = isBlindfold ? "puzzleB_Elo" : "puzzle_Elo"
                puzzledUsers[0].setValue(withRating, forKey: key)
                do { try context.save() }
                catch { print(error) }
            }
            else { print("Incorrect # of users: \(puzzledUsers.count)")}
        } catch { print("CoreData Error: couldn't fetch puzzledUsers")}
    }
    
    
}


struct User: Codable {
    var PRUSH5_HS: Int
    var PRUSH3_HS: Int
    var PRUSH5B_HS: Int
    var PRUSH3B_HS: Int
    var USERNAME: String
    var UID: String
}




