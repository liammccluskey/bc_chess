//
//  PositionTableController.swift
//  BCPtest
//
//  Created by Marty McCluskey on 7/12/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit

class PositionTableController: UITableViewController {
    
    // MARK: - Properties
    
    var puzzle: Puzzle?
    var isWhite: Bool = true // not checked unless self.puzzle != nil
    
    // MARK: - Config
    
    init(puzzle: Puzzle, isWhite: Bool) {
        self.puzzle = puzzle
        self.isWhite = isWhite
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 10
        tableView.clipsToBounds = true
        tableView.tableFooterView = UIView()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = isWhite ? "WHITE POSITION" : "BLACK POSITION"
        label.textColor = .lightGray
        label.font = UIFont(name: fontStringLight, size: 16)
        label.backgroundColor = .clear
        label.textAlignment = .center
        view.backgroundColor = .clear
        view.addSubview(label)
        label.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        guard let p = puzzle else {return cell}
        let position = p.position
        let pieceTag = isWhite ? indexPath.row*2 : indexPath.row*2 + 1
        let pieceType = PieceType(rawValue: pieceTag)
        let squares = position.getSquaresFor(isWhitePosition: isWhite, pieceTag: pieceTag)
        var pieceImage = pieceType?.image.withRenderingMode(.alwaysOriginal)
        cell.imageView?.clipsToBounds = true
        cell.textLabel?.text = squares
            .joined(separator: " ")
        if squares.count > 4 {
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.lineBreakMode = .byWordWrapping
            pieceImage = pieceImage?
                .resizeImageWithBounds(bounds: CGSize(width: cell.frame.width, height: cell.frame.height))
        }
        cell.imageView?.image = pieceImage
        cell.imageView?.contentMode = .scaleAspectFit
        cell.imageView?.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont(name: fontStringLight, size: 16)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        return cell
    }
 
    // MARK: - Interface
    
    func setData(puzzle: Puzzle, isWhite: Bool) {
        self.puzzle = puzzle
        self.isWhite = isWhite
    }
}

extension UIImage {
    func resizeImageWithBounds(bounds: CGSize) -> UIImage {
        let horizontalRatio = bounds.width/size.width
        let verticalRatio = bounds.height/size.height
        let ratio = max(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

