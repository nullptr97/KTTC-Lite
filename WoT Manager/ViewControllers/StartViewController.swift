//
//  StartViewController.swift
//  WoT Manager
//
//  Created by Ярослав Стрельников on 19.10.2021.
//

import UIKit

class StartViewController: BaseController {
    var mainTable: UITableView!
    
    var gameType: KTTCApi.GameType
    
    var searchController: UISearchController!
    var users: [User] = [] {
        didSet {
            DispatchQueue.main.async {
                self.mainTable.backgroundView?.isHidden = self.users.isEmpty
            }
        }
    }
    
    init(by gameType: KTTCApi.GameType) {
        self.gameType = gameType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTable = UITableView(frame: view.bounds, style: .plain)
        view.addSubview(mainTable)
        
        mainTable.dataSource = self
        mainTable.delegate = self
        mainTable.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        mainTable.separatorStyle = .none
        
        definesPresentationContext = true
    }
}

extension StartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        guard let label = cell.textLabel else { return UITableViewCell() }
        label.attributedText = NSAttributedString(string: users[indexPath.row].nickname ?? "", attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .semibold)])
        label.attributedText! += .attributedSpace
        label.attributedText! += NSAttributedString(string: "(\(users[indexPath.row].accountId ?? 0))", attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .medium)])
        return cell
    }
}

extension StartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        print(gameType)
        
        switch gameType {
        case .bb:
            guard let viewController = (view.window?.rootViewController as? UINavigationController)?.viewControllers.controller(byIndex: 1) as? ViewController<AnyTanksStats> else { return }
            viewController.runProcess(accountId: users[indexPath.row].accountId ?? 0, gameType: .bb, nickName: users[indexPath.row].nickname)
        case .blitz:
            guard let viewController = (view.window?.rootViewController as? UINavigationController)?.viewControllers.controller(byIndex: 1) as? ViewController<AnyBlitzTanksStats> else { return }
            viewController.runProcess(accountId: users[indexPath.row].accountId ?? 0, gameType: .blitz, nickName: users[indexPath.row].nickname)
        }
        
        users.erase()
    }
}

extension StartViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let search = searchBar.text, !search.isEmpty else { return }
        api.request(with: UserInfoWithArray<User>.self, .account, .list, [.search: (searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)]).start { [weak self] users in
            guard let self = self else { return }
            self.users = users.data ?? []
        } error: { error in
            print(error)
        } completed: { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.mainTable.reloadData()
                searchBar.endEditing(true)
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}

extension StartViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) { }
}

extension Array where Element == UIViewController {
    func controller(byIndex index: Int) -> Element? {
        if indices.contains(index) {
            return self[index]
        } else { return nil }
    }
}

extension Array {
    mutating func erase() {
        removeAll()
    }
}
