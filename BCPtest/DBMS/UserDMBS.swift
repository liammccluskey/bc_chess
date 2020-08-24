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
        
        if UserDataManager().isFirstLaunch() {
            PFJ.savePuzzlesToCoreData()
            UserDataManager().setDidLaunch()

            UserDataManager().setMembershipType(type: 0)
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
    
    private func updateRushHighscore(withScore score: Int, rushMinutes: Int, isBlindfold: Bool, scoreOld: Int) {
        let timeTag = String(rushMinutes)
        let blindfoldTag = isBlindfold ? "B" : ""
        let fieldName = "RUSH\(timeTag)\(blindfoldTag)_HS"
        guard let currentUser = Auth.auth().currentUser else {print("Error: can't update highscore while offlline"); return}
        Firestore.firestore().collection("users").document(currentUser.uid).updateData([fieldName: score]) { (error) in
            if let error = error { print("ERROR: couldn't set user's rush highscore in Firestore: \(error)") }
        }
        PublicDBMS().tryUpdateRankedUsers(withScore: score, rushMinutes: rushMinutes, isBlindfold: isBlindfold, scoreOld: scoreOld)
    }
    
    // MARK: - Core Data
    
    func initExistingUserCoreData(uid: String) {
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
        do { try context.save() }
        catch { print("couldnt init puzzledUser coredata obj") }
    }
    
    func getPuzzledUser(withUID uid: String = Auth.auth().currentUser!.uid) -> PuzzledUser? {
        //guard let thisUser = Auth.auth().currentUser else {print("ERROR: no current user logged in"); return nil}
        print("Getting user with UID: \(uid)")
        let userRequest = NSFetchRequest<PuzzledUser>(entityName: "PuzzledUser")
        do {
            let puzzledUsers = try context.fetch(userRequest)
            let thisUserMatches = puzzledUsers.filter{$0.uid! == uid}
            if thisUserMatches.count == 0 {
                return nil
            }
            else {
                return puzzledUsers.filter{$0.uid! == uid}[0]
            }
        } catch { print("CoreData Error: couldn't fetch puzzledUser with uid : \(uid)"); return nil}
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
            let scoreOld = user.rush3_HS
            if scoreNew > scoreOld {
                user.setValue(scoreNew, forKey: key)
                updateRushHighscore(withScore: score, rushMinutes: rushMinutes, isBlindfold: piecesHidden, scoreOld: Int(scoreOld))
            }
        } else if rushMinutes == 3 && piecesHidden == true {
            let scoreOld = user.rush3B_HS
            if scoreNew > scoreOld {
                user.setValue(scoreNew, forKey: key)
                updateRushHighscore(withScore: score, rushMinutes: rushMinutes, isBlindfold: piecesHidden, scoreOld: Int(scoreOld))
            }
        } else if rushMinutes == 5 && piecesHidden == false {
            let scoreOld = user.rush5_HS
            if scoreNew > scoreOld {
                user.setValue(scoreNew, forKey: key)
                updateRushHighscore(withScore: score, rushMinutes: rushMinutes, isBlindfold: piecesHidden, scoreOld: Int(scoreOld))
            }
        } else if rushMinutes == 5 && piecesHidden == true {
            let scoreOld = user.rush5B_HS
            if scoreNew > scoreOld {
                user.setValue(scoreNew, forKey: key)
                updateRushHighscore(withScore: score, rushMinutes: rushMinutes, isBlindfold: piecesHidden, scoreOld: Int(scoreOld))
            }
        }
        do {try context.save() }
        catch {print("error saving user's new highscore")}
    }
    
    func getDailyRushCount() -> Int {
        var rush3: [Rush3Attempt]
        var rush5: [Rush5Attempt]
        
        let req3 = NSFetchRequest<Rush3Attempt>(entityName: "Rush3Attempt")
        do { rush3 = try context.fetch(req3) }
        catch { print(error); return 0}
        let req5 = NSFetchRequest<Rush5Attempt>(entityName: "Rush5Attempt")
        do { rush5 = try context.fetch(req5) }
        catch { print(error); return 0}
        
        let thisDay = Date()
        rush3 = rush3.filter{$0.timestamp!.hasSame(.year, as: thisDay) && $0.timestamp!.hasSame(.day, as: thisDay)}
        rush5 = rush5.filter{$0.timestamp!.hasSame(.year, as: thisDay) && $0.timestamp!.hasSame(.day, as: thisDay)}
        print("Num Rush Today: \(rush3.count + rush5.count)")
        
        return rush3.count + rush5.count
    }
    
    func getDailyRatedPuzzleCount() -> Int {
        var puzzleAttempts: [PuzzleAttempt]
        let req = NSFetchRequest<PuzzleAttempt>(entityName: "PuzzleAttempt")
        do { puzzleAttempts = try context.fetch(req) }
        catch { print(error); return 0}
        
        let thisDay = Date()
        puzzleAttempts = puzzleAttempts.filter{$0.timestamp!.hasSame(.year, as: thisDay) && $0.timestamp!.hasSame(.day, as: thisDay)}
        print("Num Puzzles today: \(puzzleAttempts.count)")
        
        return puzzleAttempts.count
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




