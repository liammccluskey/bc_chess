//
//  CommonMovesTableController.swift
//  BCPtest
//
//  Created by Liam Mccluskey on 9/11/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit
import ChessKit
import CoreData

class CommonMovesTableController: UITableViewController {
    
    // MARK: - Properties
    
    var delegate: CommonMovesTableDelegate?
    
    let baseURL = "https://explorer.lichess.ovh/masters?fen="
    
    let startFEN: String = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    private var currentFEN: String = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    var currentMoveNumber: Int = 1 {
        didSet {
            turn = currentMoveNumber % 2 == 1 ? .white : .black
            if UserDataManager().hasReachedExplorerLimit(moveCount: currentMoveNumber / 2) {
                delegate?.didReachExplorerLimit()
                return
            } else {
                delegate?.didNotReachExplorerLimit()
            }
        }
    }
    private var turn: PieceColor = .white
    var positionData: OpeningPositionData?
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        
        tableView.register(MoveTableCell.self, forCellReuseIdentifier: moveCellID)
        
        displayPositionData(forFEN: startFEN)
    }
    
    // MARK: - Config
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let fetchErrorLabel = UILabel()
        fetchErrorLabel.font = UIFont(name: fontString, size: 17)
        fetchErrorLabel.textColor = .lightGray
        fetchErrorLabel.textAlignment = .center
        fetchErrorLabel.backgroundColor = .clear
        fetchErrorLabel.text = "No Results"
        guard let posData = positionData else {
            switch section {
            case 0: return fetchErrorLabel
            default: return nil
            }
        }
        if posData.moves.count == 0 {
            switch section {
            case 0: return fetchErrorLabel
            default: return nil
            }
        }
        
        let v = UIView()
        let l = UILabel()
        v.addSubview(l)
        l.translatesAutoresizingMaskIntoConstraints = false
        l.topAnchor.constraint(equalTo: v.topAnchor, constant: 15).isActive = true
        l.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: -10).isActive = true
        l.leftAnchor.constraint(equalTo: v.leftAnchor, constant: 10).isActive = true
        l.rightAnchor.constraint(equalTo: v.rightAnchor, constant: -10).isActive = true
        
        l.font = UIFont(name: fontString, size: 17)
        l.textColor = .lightGray
        l.textAlignment = .left
        l.backgroundColor = .clear
        l.numberOfLines = 0
        switch section {
        case 0:
            guard let _ = positionData?.opening?.name else {return nil}
            l.text = positionData?.opening?.name ; return v
        case 1: l.text = "Top Games" ; return v
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return positionData?.moves.count ?? 0
        case 1: return positionData?.topGames.count ?? 0
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: // moves
            guard let move = positionData?.moves[indexPath.row] else {return UITableViewCell()}
            let cell = tableView.dequeueReusableCell(withIdentifier: moveCellID) as! MoveTableCell
            cell.moveNumber = currentMoveNumber
            cell.turn = turn
            cell.move = move
            return cell
        default: // top games
            guard let topGame = positionData?.topGames[indexPath.row] else {return UITableViewCell()}
            let cell = UITableViewCell(style: .default, reuseIdentifier: "cellID")
            cell.backgroundColor = .clear
            cell.textLabel?.textColor = .white
            
            cell.textLabel?.text = topGame.white.name
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let currentPositionData = positionData else {return}
        switch indexPath.section {
        case 0:
            let move = currentPositionData.moves[indexPath.row]
            delegate?.didSelectMove(move: move)
        case 1:
            let game = currentPositionData.topGames[indexPath.row]
            delegate?.didSelectGame(game: game)
        default: return
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // MARK: - Interface
    
    func displayPositionData(forFEN fen: String) {
        tableView.isUserInteractionEnabled = false
        fetchOpeningPositionData(forFEN: fen) { (didCompleteFetch) in
            if !didCompleteFetch {return} // TODO: Show pop up error
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.isUserInteractionEnabled = true
            }
        }
    }
    
    private func fetchOpeningPositionData(forFEN fen: String, completion: @escaping (Bool) -> ()) {
        let fenFormatted = fen.replacingOccurrences(of: " ", with: "%20")
        let urlString = baseURL + fenFormatted
        print(urlString)
        let session = URLSession.shared
        let url = URL(string: urlString)!
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("\n\n\n\n\n Error fetching HTTP: \(error)")
                completion(false)
                return
            }
            if let data = data {
                do {
                    self.positionData = try JSONDecoder().decode(OpeningPositionData.self, from: data)
                    completion(true)
                } catch {
                    completion(false)
                    print("Error during JSON serialization: \(error)")
                }
            }
        }
        task.resume()
    }
}

fileprivate let moveCellID = "moveCellID"
class MoveTableCell: UITableViewCell {
    
    var moveNumber: Int!
    var turn: PieceColor!
    var move: CommonMove! {
        didSet {
            let number = "\(turn == .white ? moveNumber/2 + 1 : moveNumber/2 + 0)"
            let dots = turn == .white ? "." : "..."
            l1.text = number + dots + " " + move.san
            l2.text = "\(move.white + move.draws + move.black)"
            winPercentageBar.commonMove = move
        }
    }
    
    var l1: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont(name: fontString, size: 18)
        l.backgroundColor = .clear
        l.textColor = .lightGray
        l.textAlignment = .left
        return l
    }()
    var l2: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont(name: fontString, size: 18)
        l.backgroundColor = .clear
        l.textColor = .lightGray
        l.textAlignment = .right
        return l
    }()
    var winPercentageBar: WinPercentageBarController!
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configUI()
        configAutoLayout()
        selectionStyle = .default
    }
    
    override func layoutSubviews() {
        winPercentageBar.view.frame = CGRect(
            x: l2.frame.maxX + 10, y: 10,
            width: frame.width/2 + 30 - 10 - 2, // + l2LeftOffset - self.xOffset - leftPadding
            height: frame.height - 20)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configUI() {
        winPercentageBar = WinPercentageBarController()
        winPercentageBar.view.frame = .zero
        addSubview(winPercentageBar.view)
        
        addSubview(l1)
        addSubview(l2)
        backgroundColor = .clear
    }
    
    func configAutoLayout() {
        l1.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        l1.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        l2.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        l2.rightAnchor.constraint(equalTo: centerXAnchor, constant: -30).isActive = true
    }

}

class WinPercentageBarController: UIViewController {
    
    // MARK: - Properties
    
    var lWhite: UILabel!
    var lDraws: UILabel!
    var lBlack: UILabel!
    
    var commonMove: CommonMove! {
        didSet {
            let total: CGFloat = CGFloat( commonMove.white + commonMove.draws + commonMove.black )
            let whiteP = Int(100*CGFloat(commonMove.white) / total)
            let drawsP = Int(100*CGFloat( commonMove.draws) / total)
            let blackP = Int(100*CGFloat( commonMove.black ) / total)
            lWhite.text = "\(whiteP)%"
            lDraws.text = "\(drawsP)%"
            lBlack.text = "\(blackP)%"
            setFrames()
        }
    }
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    // MARK: - Config
    
    func configUI() {
        lWhite = configPercentLabel(backgroundColor: .lightGray, textColor: .darkGray)
        lDraws = configPercentLabel(backgroundColor: .darkGray, textColor: .lightGray)
        lBlack = configPercentLabel(backgroundColor: .black, textColor: .lightGray)
        view.addSubview(lWhite)
        view.addSubview(lDraws)
        view.addSubview(lBlack)
    }
    
    func setFrames() {
        let total: CGFloat = CGFloat( commonMove.white + commonMove.draws + commonMove.black )
        let whiteP = CGFloat(commonMove.white) / total
        let drawsP = CGFloat( commonMove.draws) / total
        let blackP = CGFloat( commonMove.black ) / total
        
        let w = view.frame.width
        let h = view.frame.height
        lWhite.frame = CGRect(x: 0, y: 0, width: w*whiteP, height: h)
        lDraws.frame = CGRect(x: lWhite.frame.maxX, y: 0, width: w*drawsP, height: h)
        lBlack.frame = CGRect(x: lDraws.frame.maxX, y: 0, width: w*blackP, height: h)
    }
    
    func configPercentLabel(backgroundColor: UIColor, textColor: UIColor) -> UILabel {
        let l = UILabel()
        l.backgroundColor = backgroundColor
        l.textColor = textColor
        l.font = UIFont(name: fontStringLight, size: 15)
        l.textAlignment = .center
        return l
    }
    
}

struct OpeningPositionData: Codable {
/*
     Reponse from GET /master?fen=
*/
    let white: Int
    let draws: Int
    let black: Int
    let moves: [CommonMove]
    let topGames: [TopGame]
    let opening: Opening?
}

struct CommonMove: Codable {
    let uci: String
    let san: String
    let white: Int
    let draws: Int
    let black: Int
    let averageRating: Int
}

struct TopGame: Codable {
    let id: String
    //let winner: String
    let white: Player
    let black: Player
}

struct Opening: Codable {
    let eco: String
    let name: String
}

struct Player: Codable {
    let name: String
    let rating: Int
}

