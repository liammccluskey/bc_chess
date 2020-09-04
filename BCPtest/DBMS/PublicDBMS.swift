//
//  PublicDBMS.swift
//  BCPtest
//
//  Created by Liam Mccluskey on 8/14/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore
import FirebaseAuth

class PublicDBMS {
    
    let db = Firestore.firestore()
    var delegate: PublicDBMSDelegate?
    
    
    // MARK: - Public Ranking
    
    func fetchRankedUsers() {
        let docRef = db.collection("rankedUsers").document("usersData")
        docRef.getDocument { (document, error) in
            guard let document = document else { print("Error: couldn't read ranked users document"); return}
            do {
                let rankedUsers: RankedUsers? = try document.data(as: RankedUsers.self) ?? nil
                self.delegate?.sendRankedUsers(rankedUsers: rankedUsers)
            } catch {
                print(error)
            }
        }
    }
    
    func tryUpdateRankedUsers(withScore score: Int, rushMinutes: Int, isBlindfold: Bool, scoreOld: Int) {
        let timeTag = String(rushMinutes)
        let blindfoldTag = isBlindfold ? "B" : ""
        let fieldName = "RUSH\(timeTag)\(blindfoldTag)"
        let CC: String = Locale.current.regionCode ?? "US"
        
        guard let currentUser = Auth.auth().currentUser else {print("ERROR: no current user"); return}
        let thisUser = RankedUser(UID: currentUser.uid, USERNAME: currentUser.displayName ?? "anonymous", SCORE: String(score), COUNTRY_CODE: CC)
        let thisUserOld = RankedUser(UID: currentUser.uid, USERNAME: currentUser.displayName ?? "anonymous", SCORE: String(scoreOld), COUNTRY_CODE: CC)
        
        let usersDocRef = db.collection("rankedUsers").document("usersData")
        usersDocRef.updateData([fieldName: FieldValue.arrayRemove([thisUserOld.toDict()])])
        usersDocRef.updateData([fieldName: FieldValue.arrayUnion([thisUser.toDict()])])
    }
   
    // MARK: - Daily Puzzles
    
    func fetchDailyPuzzlesInfo() {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        let docName = formatter.string(from: Date()).replacingOccurrences(of: "/", with: "_")
        print("\n\n\n\n\n the daily puzzles doc is \(docName)")
        let docRef = db.collection("dailyPuzzles").document(docName)
        docRef.getDocument { (document, error) in
            guard let document = document else { print("ERROR reading DailyPuzzlesDocument: \(String(describing: error))"); return}
            do {
                let dailyPuzzlesInfo: DailyPuzzlesInfo? = try document.data(as: DailyPuzzlesInfo.self) ?? nil
                self.delegate?.sendDailyPuzzlesInfo(info: dailyPuzzlesInfo)
            } catch { print(error) }
        }
    }
    
    func updateDailyPuzzlesInfo(puzzleNumber: Int, attemptWasCorrect: Bool) {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm_dd_yyyy"
        let docName = formatter.string(from: Date())
        let docRef = db.collection("dailyPuzzles").document(docName)
        
        let attemptsField = "P\(puzzleNumber)_ATTEMPTS"
        let correctnessField = attemptWasCorrect ? "P\(puzzleNumber)_CORRECT" : "P\(puzzleNumber)_INCORRECT"
        
        var data: [String: Any] = [
            "P1_ATTEMPTS": FieldValue.increment(Int64(0)),
            "P1_CORRECT": FieldValue.increment(Int64(0)),
            "P1_INCORRECT": FieldValue.increment(Int64(0)),
            "P2_ATTEMPTS": FieldValue.increment(Int64(0)),
            "P2_CORRECT": FieldValue.increment(Int64(0)),
            "P2_INCORRECT": FieldValue.increment(Int64(0)),
            "P3_ATTEMPTS": FieldValue.increment(Int64(0)),
            "P3_CORRECT": FieldValue.increment(Int64(0)),
            "P3_INCORRECT": FieldValue.increment(Int64(0)),
        ]
        data[attemptsField] = FieldValue.increment(Int64(1))
        data[correctnessField] = FieldValue.increment(Int64(1))
        
        docRef.setData(data, merge: true) { (error) in
            if let error = error {
                print("ERROR updating daily puzzles doc: \(error)")
            }
        }
        
    }
}

struct DailyPuzzlesInfo: Codable {
    var P1_ATTEMPTS: Int
    var P1_CORRECT: Int
    var P1_INCORRECT: Int
    var P2_ATTEMPTS: Int
    var P2_CORRECT: Int
    var P2_INCORRECT: Int
    var P3_ATTEMPTS: Int
    var P3_CORRECT: Int
    var P3_INCORRECT: Int
}

class TestPublicDBMS {
    
    let db = Firestore.firestore()
    var delegate: PublicDBMSDelegate?
    
    var baseNames = ["apple", "dogman", "newman", "kramer", "jerry", "steve", "pinetree", "pinecone", "guyfieri", "ericandre", "chess", "pawn", "king", "queen", "assman", "rook", "tactics", "pro"]
    
    
    // MARK: - Public Ranking
    
    private func makeRankedUser() -> RankedUser {
        let countryCode = ["AU", "AT", "BD", "BB", "US", "BR", "CA", "CN", "CO"].randomElement()!
        let username = baseNames.randomElement()! + String(Int.random(in: 0...1000)) + baseNames.randomElement()!
        let score = String(Int.random(in: 1...3))
        return RankedUser(UID: "test", USERNAME: username, SCORE: score, COUNTRY_CODE: countryCode)
    }
    
    func tryUpdateRankedUsers(rushMinutes: Int, isBlindfold: Bool) {
        let timeTag = String(rushMinutes)
        let blindfoldTag = isBlindfold ? "B" : ""
        let fieldName = "RUSH\(timeTag)\(blindfoldTag)"
        
        let thisUser = makeRankedUser()
        let score = Int(thisUser.SCORE)!
        
        let minsDocRef = db.collection("rankedUsers").document("rankedMinimums")
        let usersDocRef = db.collection("rankedUsers").document("usersData")
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let doc: DocumentSnapshot
            do { try doc = transaction.getDocument(minsDocRef) }
            catch let fetchError as NSError { errorPointer?.pointee = fetchError; return nil }

            let rankMins: RankedMinimums?
            var minUser: RankedUser
            do { try rankMins = doc.data(as: RankedMinimums.self) ?? nil }
            catch { print("ERROR: couldn't read rankedMinimums doc \(error)"); return nil }
            guard let mins = rankMins else {print("ERROR: rankMins was nil"); return nil }
            minUser = mins.getValue(forKey: fieldName)
            
            if score > Int(minUser.SCORE)! {
                transaction.updateData([fieldName: FieldValue.arrayUnion([thisUser.toDict()])], forDocument: usersDocRef)
//                transaction.updateData([
//                   fieldName: FieldValue.arrayRemove([minUser])
//               ], forDocument: usersDocRef)
            } else if score <= Int(minUser.SCORE)! {
                transaction.updateData([fieldName: thisUser.toDict()], forDocument: minsDocRef)
//                transaction.updateData([
 //                   fieldName: FieldValue.arrayRemove([minUser])
 //               ], forDocument: usersDocRef)
                transaction.updateData([fieldName: FieldValue.arrayUnion([thisUser.toDict()])], forDocument: usersDocRef)
            }
            return nil
        }) { (object, error) in
            if let error = error {
                print("PublicDBMS.tryUpdateRankedUsers() Error: Transaction failed with \(error)")
            }
        }
    }

}

