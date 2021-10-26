//
//  SearchViewController.swift
//  WoT Manager
//
//  Created by Ярослав Стрельников on 19.10.2021.
//

import UIKit

final class SearchViewController: BaseController, UIConfigurable {
    var presenter: SearchPresenterInterface!
    var mainTable: UITableView!
    
    var gameType: KTTCApi.GameType
    
    init(by gameType: KTTCApi.GameType) {
        self.gameType = gameType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
    }
    
    internal func setUI() {
        view.backgroundColor = .clear
        view.setBlurBackground(style: .regular, frame: view.bounds, withAlpha: 0.98)
        
        mainTable = UITableView(frame: view.bounds, style: .plain)
        mainTable.backgroundColor = .clear
        view.addSubview(mainTable)
        
        mainTable.dataSource = self
        mainTable.delegate = self
        mainTable.register(UITableViewCell.class, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
        mainTable.separatorStyle = .none
    }
}

extension SearchViewController: SearchViewInterface {
    func reloadData() {
        DispatchQueue.main.async { [self] in
            mainTable.reloadData()
        }
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let users = presenter.formatter.users
        return users.count > 0 ? users.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier, for: indexPath)
        guard let label = cell.textLabel else { return UITableViewCell() }
        cell.backgroundColor = .clear
        
        let users = presenter.formatter.users
        
        if users.count > 0 {
            let user = users[indexPath.row]

            label.textAlignment = .natural
            label.attributedText = NSAttributedString(string: user.nickname ?? "", attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .semibold), .foregroundColor: UIColor.label])
            label.attributedText! += .attributedSpace
            label.attributedText! += NSAttributedString(string: "(\(user.accountId ?? 0))", attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .medium), .foregroundColor: UIColor.label])
        } else {
            label.textAlignment = .center
            label.attributedText = NSAttributedString(string: "Никто не найден, измените запрос", attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium), .foregroundColor: UIColor.secondaryLabel])
        }
        
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var users = presenter.formatter.users
        let user = users[indexPath.row]
        
        switch gameType {
        case .bb:
            guard let viewController = (view.window?.rootViewController as? UINavigationController)?.viewControllers.controller(byIndex: 1) as? StatisticsViewController<AnyTanksStats> else { return }
            viewController.runProcess(accountId: user.accountId ?? 0, gameType: .bb, nickName: user.nickname)
        case .blitz:
            guard let viewController = (view.window?.rootViewController as? UINavigationController)?.viewControllers.controller(byIndex: 1) as? StatisticsViewController<AnyBlitzTanksStats> else { return }
            viewController.runProcess(accountId: user.accountId ?? 0, gameType: .blitz, nickName: user.nickname)
        }
        
        users.erase()
        mainTable.reloadData()
    }
}
