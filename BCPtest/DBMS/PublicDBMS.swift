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
    
    func tryUpdateRankedUsers(withScore score: Int, rushMinutes: Int, isBlindfold: Bool) {
        let timeTag = String(rushMinutes)
        let blindfoldTag = isBlindfold ? "B" : ""
        let fieldName = "RUSH\(timeTag)\(blindfoldTag)"
        guard let currentUser = Auth.auth().currentUser else {print("ERROR: no current user"); return}
        let thisUser = RankedUser(UID: currentUser.uid, USERNAME: currentUser.displayName ?? "anonymous", SCORE: String(score))
        
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
            print(minUser)
            
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
