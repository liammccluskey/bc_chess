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
    
    // MARK: - Firestore
    
    func initUserData(uid: String, username: String) {
        // create PuzzledUser
        let puzzledUser = PuzzledUser(context: context)
        puzzledUser.numPuzzleAttempts = 0
        puzzledUser.numPuzzleBAttempts = 0
        puzzledUser.puzzle_Elo = 1000
        puzzledUser.puzzleB_Elo = 800
        puzzledUser.rush3_HS = 0
        puzzledUser.rush3B_HS = 0
        puzzledUser.rush5_HS = 0
        puzzledUser.rush5B_HS = 0
        puzzledUser.registerTimestamp = Date()
        puzzledUser.uid = uid
        print(uid)
        do { try context.save() }
        catch { print("couldnt init puzzledUser coredata obj") }
        
        // create PuzzleReferences
        if UserDataManager().isFirstLaunch() {
            PFJ.savePuzzlesToCoreData()
            UserDataManager().setDidLaunch()
        }
        
        Firestore.firestore().collection("users").document(uid).setData([
            "RUSH5_HS": 0,
            "RUSH3_HS": 0,
            "RUSH5B_HS": 0,
            "RUSH3B_HS": 0,
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
    
    private func updateRushHighscore(withScore score: Int, rushMinutes: Int, isBlindfold: Bool) {
        let timeTag = String(rushMinutes)
        let blindfoldTag = isBlindfold ? "B" : ""
        let fieldName = "RUSH\(timeTag)\(blindfoldTag)_HS"
        guard let currentUser = Auth.auth().currentUser else {print("Error: can't update highscore while offlline"); return}
        Firestore.firestore().collection("users").document(currentUser.uid).updateData([fieldName: score]) { (error) in
            if let error = error { print("ERROR: couldn't set user's rush highscore in Firestore: \(error)") }
        }
        PublicDBMS().tryUpdateRankedUsers(withScore: score, rushMinutes: rushMinutes, isBlindfold: isBlindfold)
    }
    
    // MARK: - Core Data
    
    func getPuzzledUser() -> PuzzledUser? {
        guard let thisUser = Auth.auth().currentUser else {print("ERROR: no current user logged in"); return nil}
        print("Getting user with UID: \(thisUser.uid)")
        let userRequest = NSFetchRequest<PuzzledUser>(entityName: "PuzzledUser")
        do {
            let puzzledUsers = try context.fetch(userRequest)
            puzzledUsers.forEach{ print($0.uid!) }
            return puzzledUsers.filter{$0.uid! == thisUser.uid}[0]
        } catch { print("CoreData Error: couldn't fetch puzzledUsers"); return nil}
        /*
        guard let thisUser = Auth.auth().currentUser else {print("ERROR: no current user logged in"); return nil}
        print("Getting user with UID: \(thisUser.uid)")
        let userRequest = NSFetchRequest<PuzzledUser>(entityName: "PuzzledUser")
        userRequest.predicate = NSPredicate(format: "uid == %@", thisUser.uid)
        do {
            let puzzledUsers = try context.fetch(userRequest)
            if puzzledUsers.count == 1 { return puzzledUsers[0]}
            else { print("Incorrect # of users: \(puzzledUsers.count)"); return nil}
        } catch { print("CoreData Error: couldn't fetch puzzledUsers"); return nil}
        */
    }
    
    func updateUserPuzzleElo(forUser user: PuzzledUser, puzzleRating: Int32, wasCorrect: Bool, isBlindfold: Bool) -> PuzzledUser {
        let key = isBlindfold ? "puzzleB_Elo" : "puzzle_Elo"
        let sA = wasCorrect ? 1.0 : 0.0
        let oldRating = Double(isBlindfold ? user.puzzleB_Elo : user.puzzle_Elo)
        let qA = pow(10.0, Double(oldRating)/400.0)
        let qB = pow(10.0, Double(puzzleRating)/400.0)
        let eA = qA/(qA + qB)
        let newRating = Int32(oldRating + 32.0*(sA - eA))
        user.setValue(newRating, forKey: key)
        do { try context.save() }
        catch { print("Error saving PuzzledUser with updated Rating")}
        return user
    }
    
    func tryUpdateUserRushHS(forUser user: PuzzledUser, withScore score: Int, rushMinutes: Int, piecesHidden: Bool){
    /*
         Set new puzzle rush highscore if given score is greater than current highscore
    */
        let key = piecesHidden ? "rush\(rushMinutes)B_HS" : "rush\(rushMinutes)_HS"
        let scoreNew = Int32(score)
        if rushMinutes == 3 && piecesHidden == false {
            if scoreNew > user.rush3_HS {
                user.setValue(scoreNew, forKey: key)
                updateRushHighscore(withScore: score, rushMinutes: rushMinutes, isBlindfold: piecesHidden)
            }
        } else if rushMinutes == 3 && piecesHidden == true {
            if scoreNew > user.rush3B_HS {
                user.setValue(scoreNew, forKey: key)
                updateRushHighscore(withScore: score, rushMinutes: rushMinutes, isBlindfold: piecesHidden)
            }
        } else if rushMinutes == 5 && piecesHidden == false {
            if scoreNew > user.rush5_HS {
                user.setValue(scoreNew, forKey: key)
                updateRushHighscore(withScore: score, rushMinutes: rushMinutes, isBlindfold: piecesHidden)
            }
        } else if rushMinutes == 5 && piecesHidden == true {
            if scoreNew > user.rush5B_HS {
                user.setValue(scoreNew, forKey: key)
                updateRushHighscore(withScore: score, rushMinutes: rushMinutes, isBlindfold: piecesHidden)
            }
        }
        do {try context.save() }
        catch {print("error saving user's new highscore")}
    }
}


struct User: Codable {
    var RUSH5_HS: Int
    var RUSH3_HS: Int
    var RUSH5B_HS: Int
    var RUSH3B_HS: Int
    var USERNAME: String
    var UID: String
}




