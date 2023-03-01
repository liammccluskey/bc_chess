//
//  UpgradeController.swift
//  BCPtest
//
//  Created by Liam Mccluskey on 8/16/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit
import StoreKit

class UpgradeController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {

    // MARK: - Properties
    
    var goldProduct: SKProduct?
    var goldID = "kingliam.bcptest.gold"
    
    var silverProduct: SKProduct?
    var silverID = "kingliam.bcptest.silver"
    
    let header: UILabel = {
        let label = UILabel()
        label.text = "For a one time purchase,\n become a"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Avenir-Black", size: 24)
        label.backgroundColor = .clear
        label.numberOfLines = 0
        return label
    }()
    
    var goldView: UIView!
    var silverView: UIView!
    
    var vstack: UIStackView!
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchProducts()
        configUI()
        configAutoLayout()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Config
    
    func configUI() {
        configNavBar()
        
        goldView = configUpgradeView(
            isGold: true,
            title: "Gold Member",
            price: "$4.99",
            feat1: "Unlimited Puzzle Rush",
            feat2: "Unlimited Rated Puzzles",
            feat3: "Unlimited Explorer Access"
        )
        silverView = configUpgradeView(
            isGold: false,
            title: "Silver Member",
            price: "$1.99",
            feat1: "25 Puzzle Rush per day",
            feat2: "50 Rated Puzzles per day",
            feat3: "25 Explorer Moves"
        )
        
        vstack = CommonUI().configureStackView(arrangedSubViews: [header, goldView, silverView])
        vstack.distribution = .fillEqually
        vstack.spacing = 30
        view.addSubview(vstack)
        view.backgroundColor = CommonUI().blackColor
    }
    
    func configAutoLayout() {
        vstack.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        vstack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        vstack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        vstack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
    }
    
    func configNavBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = CommonUI().navBarColor
        navigationController?.navigationBar.tintColor = .lightGray
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.shadowImage = UIImage()
        let font = UIFont(name: fontStringBold, size: 17)
        navigationController?.navigationBar.titleTextAttributes = [.font: font!, .foregroundColor: UIColor.white]
        navigationItem.title = "Upgrade"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Restore", style: .plain, target: self, action: #selector(restoreAction))
    }
    
    func configUpgradeView(isGold: Bool, title: String, price: String, feat1: String, feat2: String, feat3: String) -> UIView {
        let tintColor = isGold ? CommonUI().goldColor : CommonUI().silverColor
        let v = UIView()
        v.backgroundColor = CommonUI().blackColorLight
        v.layer.cornerRadius = 10
        v.clipsToBounds = true
        
        let header = UILabel()
        header.text = title + " : " + price
        header.font = UIFont(name: "Avenir-Black", size: 22)
        header.textColor = tintColor
        header.textAlignment = .center
        
        let f1 = UILabel()
        f1.font = UIFont(name: fontString, size: 18)
        f1.text = feat1
        f1.textColor = .white
        f1.textAlignment = .center
        
        let f2 = UILabel()
        f2.font = UIFont(name: fontString, size: 18)
        f2.text = feat2
        f2.textColor = .white
        f2.textAlignment = .center
        
        let f3 = UILabel()
        f3.font = UIFont(name: fontString, size: 18)
        f3.text = feat3
        f3.textColor = .white
        f3.textAlignment = .center
        
        let tag = isGold ? 0 : 1
        let upgradeButton = configUpgradeButton(color: tintColor, tag: tag)
        
        let vstack = CommonUI().configureStackView(arrangedSubViews: [header, f1, f2, f3, upgradeButton])
        vstack.distribution = .fillEqually
        vstack.spacing = 10
        
        v.addSubview(vstack)
        vstack.topAnchor.constraint(equalTo: v.topAnchor, constant: 15).isActive = true
        vstack.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: -15).isActive = true
        vstack.leftAnchor.constraint(equalTo: v.leftAnchor, constant: 10).isActive = true
        vstack.rightAnchor.constraint(equalTo: v.rightAnchor, constant: -10).isActive = true
        
        return v
    }
    
    // MARK: - Selectors
    
    @objc func upgradeAction(_ sender: UIButton) {
        guard let goldProduct = goldProduct, let silverProduct = silverProduct else {
            showPaymentErrorAlert()
            return
        }
        let chosenProduct = sender.tag == 0 ? goldProduct : silverProduct
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: chosenProduct)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
        } else {
            showPaymentErrorAlert()
        }
    }
    
    @objc func restoreAction() {
        SKPaymentQueue.default().add(self)
        let refresh = SKReceiptRefreshRequest()
        refresh.delegate = self
        refresh.start()
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    // MARK: - Alerts
    
    func showPaymentErrorAlert() {
        let message = "\nYour payment could not be processed at this time. Please try again later."
        let alert = UIAlertController(title: "Payment Error\n", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    func showPurchaseSuccessAlert(membershipName: String) {
        let message = "\nThank you for your purchase. You are now a \(membershipName.capitalized), welcome to the club."
        let alert = UIAlertController(title: "Purchase Complete", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    func showRestoreSuccessAlert(membershipName: String) {
        let message = "\nYour purchase has been restored. You are now a \(membershipName.capitalized), welcome to the club."
        let alert = UIAlertController(title: "Restore Complete", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    // MARK: - Products
    
    func fetchProducts() {
        let productIDs: Set<String> = [goldID, silverID]
        let request = SKProductsRequest(productIdentifiers: productIDs)
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let gold = response.products.first, let silver = response.products.last {
            goldProduct = gold
            silverProduct = silver
            print("gold: " + gold.productIdentifier)
            print("silver: " + silver.productIdentifier)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { (transaction) in
            let pid = transaction.payment.productIdentifier
            let membershipID = pid == goldID ? 2 : 1
            switch transaction.transactionState {
            case .purchasing:
                break
            case .purchased:
                let membership = MembershipType(rawValue: membershipID)!
                UserDataManager().setMembershipType(type: membershipID)
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                showPurchaseSuccessAlert(membershipName: membership.displayName)
                break
            case .restored:
                UserDataManager().setMembershipType(type: membershipID)
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
            case .failed:
                showPaymentErrorAlert()
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                break
            case .deferred:
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                break
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        let membershipName = UserDataManager().getMembershipName()
        showRestoreSuccessAlert(membershipName: membershipName)
    }
}

extension UpgradeController {
    func configUpgradeButton(color: UIColor, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.tag = tag
        button.setTitle("Upgrade", for: .normal)
        button.titleLabel?.font = UIFont(name: fontString, size: 20)
        button.backgroundColor = color
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(upgradeAction), for: .touchUpInside)
        button.setTitleColor(CommonUI().blackColor, for: .normal)
        return button
    }
}

enum MembershipType: Int {
    case free, silver, gold
    
    var rushLimit: Int {
        switch self {
        case .free: return 5
        case .silver: return 25
        case .gold: return 1000000 // should be infinte
        }
    }
    
    var puzzleLimit: Int {
        switch self {
        case .free: return 10
        case .silver: return 50
        case .gold: return 1000000 // should be infinite
        }
    }
    
    var explorerLimit: Int {
        switch self {
        case .free: return 3
        case .silver: return 25
        case .gold: return 1000000
        }
    }
    
    var displayName: String {
        switch self {
        case .free: return "Free Plan"
        case .silver: return "Silver Member"
        case .gold: return "Gold Member" // should be infinite
        }
    }

}
