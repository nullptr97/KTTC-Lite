//
//  ViewController.swift
//  WoT Manager
//
//  Created by Ярослав Стрельников on 11.10.2021.
//

import UIKit
import SPAlert
import ObjectMapper
import PureLayout
import SwiftUI
import Lottie

open class BaseController: UIViewController {
    let api: KTTCApi = KTTCApi()
}

class StatisticsViewController<T>: BaseController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate, UIConfigurable where T: Mappable {
    var presenter: StatisticsPresenterInterface!
    lazy var formatter: StatisticsFormatterInterface = presenter.formatter

    var collectionView: UICollectionView!
    var activityIndicator: UIActivityIndicatorView!
    var animation: AnimationView!
    var updater = UIRefreshControl()

    var accountId: Int = 0 {
        didSet {
            if accountId > 0 {
                activityIndicator.startAnimating()
                presenter.didRunProcess(with: T.self, accountId: accountId, gameType: gameType, nickName: "")
            }
        }
    }
    var gameType: KTTCApi.GameType = .bb
    
    var isBlitz: Bool {
        return T.self is AnyBlitzTanksStats.Type
    }
    
    lazy var dataSource = formatter.makeDataSource(collectionView: collectionView)
    lazy var snapshot = formatter.makeSnapshot()
    
    var searchController: UISearchController!
    private var startController: SearchViewController { SearchWireframe(by: gameType).viewController }
        
    private var isSearch: Bool = false
    private let titleLabel = UILabel()
    private var nickName: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        coordinator.animate { [weak self] context in
            guard let self = self else { return }
            self.collectionView.collectionViewLayout.invalidateLayout()
        } completion: { [weak self] context in
            guard let self = self else { return }
            self.collectionView.reloadData()
        }
    }
    
    func setUI() {
        title = "Статистика игрока"
        
        view.backgroundColor = .systemBackground
        searchController = UISearchController(searchResultsController: startController)
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.placeholder = "Введите никнейм игрока"
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.obscuresBackgroundDuringPresentation = true
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.modalTransitionStyle = .crossDissolve
        
        definesPresentationContext = true
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: configureLayout())
        view.addSubview(collectionView)
        collectionView.register(UINib(nibName: "ParameterCell", bundle: nil), forCellWithReuseIdentifier: "ParameterCell")
        collectionView.dataSource = dataSource
        collectionView.backgroundColor = .systemBackground
        collectionView.refreshControl = updater
        collectionView.autoPinEdge(toSuperviewSafeArea: .top)
        collectionView.autoPinEdge(toSuperviewSafeArea: .leading)
        collectionView.autoPinEdge(toSuperviewSafeArea: .trailing)
        collectionView.autoPinEdge(.bottom, to: .bottom, of: view)
        updater.addTarget(self, action: #selector(update), for: .valueChanged)
        
        animation = AnimationView(animation: Animation.named("search"))
        view.addSubview(animation)
        animation.autoPinEdgesToSuperviewSafeArea()
        animation.loopMode = .loop
        animation.play()
        
        activityIndicator = UIActivityIndicatorView(style: .medium)
        collectionView.addSubview(activityIndicator)
        activityIndicator.frame = CGRect(origin: view.bounds.origin, size: CGSize(width: view.bounds.width, height: 56))
    }
    
    func nullableAllData() {
        snapshot.deleteSections(snapshot.sectionIdentifiers)
        dataSource.apply(snapshot)
    }
    
    func runProcess(accountId: Int, gameType: KTTCApi.GameType, nickName: String?) {
        self.gameType = gameType
        self.accountId = accountId
        searchController.dismiss(animated: true) { [weak self] in
            self?.searchController.isActive = false
            self?.searchController.searchBar.placeholder = nickName
            self?.nickName = nickName
        }
    }
    
    func setXVMTitle(withColor color: UIColor) {
        UIView.transition(with: navigationController!.navigationBar, duration: 0.5, options: [.preferredFramesPerSecond60]) {
            self.navigationItem.titleView = nil
            self.navigationController?.navigationBar.tintColor = color
            self.titleLabel.attributedText = NSMutableAttributedString(string: self.nickName ?? "", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .semibold), .foregroundColor: color])
            self.titleLabel.sizeToFit()
            self.navigationItem.titleView = self.titleLabel
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let search = searchController.searchBar.text, !search.isEmpty else { return }
        guard let searchViewController = searchController.searchResultsController as? SearchViewController else { return }
        guard isSearch else { return }
        
        searchViewController.presenter.didSearchUsers(by: search, with: gameType) { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                searchController.searchBar.endEditing(true)
                self.isSearch = false
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        isSearch = true
        updateSearchResults(for: searchController)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        searchController.searchResultsController?.view.isHidden = false
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        searchController.searchResultsController?.view.isHidden = true
    }
    
    func stopLoading() {
        if !animation.isHidden {
            animation.stop()
            animation.isHidden = true
        }
        activityIndicator.stopAnimating()
        nullableAllData()
    }
    
    @objc func update() {
        if accountId > 0 {
            activityIndicator.startAnimating()
            presenter.didRunProcess(with: T.self, accountId: accountId, gameType: gameType, nickName: "")
        }
        updater.endRefreshing()
    }
}

extension StatisticsViewController {
    func configureLayout() -> UICollectionViewCompositionalLayout {
        let layout = layout()
        return layout
    }

    private func layout() -> UICollectionViewCompositionalLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { [weak self] index, layoutEnvironment in
            guard let self = self, self.snapshot.sectionIdentifiers.indices.contains(index) else { return .none }
            let layoutWidth = layoutEnvironment.container.contentSize.width
            
            let section = self.snapshot.sectionIdentifiers[index]
            
            let layoutSection: NSCollectionLayoutSection
            
            switch section {
            case .average, .good, .bad:
                let firstItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1))
                let firstItem = NSCollectionLayoutItem(layoutSize: firstItemSize)
                
                let secondItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1))
                let secondItem = NSCollectionLayoutItem(layoutSize: secondItemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(layoutWidth), heightDimension: .absolute(28))
                let group: NSCollectionLayoutGroup = .horizontal(layoutSize: groupSize, subitems: [firstItem, secondItem])

                layoutSection = NSCollectionLayoutSection(group: group)
            case .firstDivider, .secondDivider, .thirdDivider, .fourtDivider:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(layoutWidth), heightDimension: .absolute(10))
                let group: NSCollectionLayoutGroup = .horizontal(layoutSize: groupSize, subitem: item, count: 1)
                

                layoutSection = NSCollectionLayoutSection(group: group)
            default:
                let firstItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(2.25/3), heightDimension: .fractionalHeight(1))
                let firstItem = NSCollectionLayoutItem(layoutSize: firstItemSize)
                
                let secondItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.75/3), heightDimension: .fractionalHeight(1))
                let secondItem = NSCollectionLayoutItem(layoutSize: secondItemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(layoutWidth), heightDimension: .absolute(36))
                let group: NSCollectionLayoutGroup = .horizontal(layoutSize: groupSize, subitems: [firstItem, secondItem])

                layoutSection = NSCollectionLayoutSection(group: group)
            }
            return layoutSection
        }, configuration: config)

        return layout
    }
}

extension StatisticsViewController: StatisticsViewInterface {
    func error(withMessage message: String) {
        DispatchQueue.main.async { [self] in
            SPAlert.present(title: "Ошибка", message: message, preset: .error, haptic: .error)
            activityIndicator.stopAnimating()
        }
    }
}
