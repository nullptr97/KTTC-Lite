//
//  ViewController.swift
//  WoT Manager
//
//  Created by Ярослав Стрельников on 11.10.2021.
//

import UIKit
import ObjectMapper

struct NeedCalculateData {
    var battles: Double = 0
    var averageLevel: Double = 0
    var wn6: WN6 = 0
    var wn7: WN7 = 0
    var wn8: WN8 = 0
    var eff: EFF = 0
    
    var xp: Double = 0
    var damage: Double = 0
    var spotted: Double = 0
    var frags: Double = 0
    var wins: Double = 0
    var maxFrags: Double = 0
    var def: Double = 0
    var cap: Double = 0
    
    var assist: Double = 0
    var hits: Double = 0
    
    var maxDamage: Double = 0
    
    var avgDamage: Double {
        (damage / battles).round(to: 2)
    }
    
    var avgSpotted: Double {
        (spotted / battles).round(to: 2)
    }
    
    var avgFrags: Double {
        (frags / battles).round(to: 2)
    }
    
    var avgDef: Double {
        (def / battles).round(to: 2)
    }
    
    var avgXP: Double {
        (xp / battles).round(to: 2)
    }
    
    var avgCap: Double {
        (cap / battles).round(to: 2)
    }

    var winrate: Double {
        (wins / (battles / 100)).round(to: 2)
    }
    
    mutating func erase() {
        battles = 0
        averageLevel = 0
        wn8 = 0
        wn7 = 0
        wn6 = 0
        eff = 0
        xp = 0
        damage = 0
        spotted = 0
        frags = 0
        wins = 0
        maxDamage = 0
        maxFrags = 0
        def = 0
        cap = 0
        assist = 0
        hits = 0
    }
}

struct DataValue: Hashable {
    var key: String
    var value: Any
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
    
    static func == (lhs: DataValue, rhs: DataValue) -> Bool {
        return lhs.key == rhs.key
    }
}

enum Section {
    case ratings
    case firstDivider
    case winrate
    case secondDivider
    case shoots
    case thirdDivider
    case frags
    case fourtDivider
    case good
    case average
    case bad
}

enum Item: Hashable {
    static func == (lhs: Item, rhs: Item) -> Bool {
        switch lhs {
        case .key(let string1):
            switch rhs {
            case .key(let string):
                return string1 == string
            default:
                return false
            }
        case .value(let dictionary1):
            switch rhs {
            case .value(let dictionary):
                return dictionary1 == dictionary
            default:
                return false
            }
        case .level(let dictionary2):
            switch rhs {
            case .level(let dictionary):
                return dictionary2 == dictionary
            default:
                return false
            }
        }
    }
    
    case key(String)
    case value([String: Double])
    
    case level([String: String])
}

typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

struct TankModel {
    var name: String
    var level: String
    var id: Int
}

open class BaseController: UIViewController {
    let api: KTTCApi = KTTCApi()
}

class ViewController<T>: BaseController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate where T: Mappable {
    var collectionView: UICollectionView!
    var activityIndicator: UIActivityIndicatorView!
    var updater = UIRefreshControl()

    var accountId: Int = 0 {
        didSet {
            getAnotherData(with: accountId)
        }
    }
    var gameType: KTTCApi.GameType = .bb

    var existTanks: [Int] = []
    
    var calcData: [WN8CalculateData] = []
    var expCalcData: [WN8CalculateData] = []
    var averageData: WN8CalculateData?

    var calculator: KTTCCalculator?
    
    var names: [Int: TankModel] = [:]
    
    var isBlitz: Bool {
        return T.self is AnyBlitzTanksStats.Type
    }
    
    lazy var dataSource = makeDataSource()
    lazy var snapshot = makeSnapshot()
    
    var searchController: UISearchController!
    private var startController: StartViewController { StartViewController(by: gameType) }
    
    private var needCalculateData = NeedCalculateData()
    
    private var winrate: Double = 0
    private var battles: Double = 0
    private var averageLevel: Double = 0
    private var wn6: Double = 0
    private var wn8: Double = 0
    
    private var isSearch: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Статистика игрока"
        
        view.backgroundColor = .systemBackground
        searchController = UISearchController(searchResultsController: startController)
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.searchBarStyle = .default
        searchController.searchBar.placeholder = "Введите никнейм игрока"
        navigationItem.searchController = searchController
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.obscuresBackgroundDuringPresentation = true
        
        searchController.delegate = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: configureLayout())
        view.addSubview(collectionView)
        collectionView.register(UINib(nibName: "ParameterCell", bundle: nil), forCellWithReuseIdentifier: "ParameterCell")
        collectionView.dataSource = dataSource
        collectionView.backgroundColor = .systemBackground
        collectionView.refreshControl = updater
        updater.addTarget(self, action: #selector(update), for: .valueChanged)
        
        activityIndicator = UIActivityIndicatorView(style: .medium)
        collectionView.addSubview(activityIndicator)
        activityIndicator.frame = view.bounds
        
        snapshot.appendSections([.winrate, .firstDivider, .ratings, .secondDivider, .frags, .thirdDivider, .shoots, .fourtDivider, .good, .average, .bad])
        dataSource.apply(snapshot)
        
        if accountId > 0 { getAnotherData(with: accountId) }
    }
    
    func nullableAllData() {
        snapshot.deleteSections(snapshot.sectionIdentifiers)
        dataSource.apply(snapshot)
        calcData.erase()
        expCalcData.erase()
        existTanks.erase()
        calculator = nil
        names.removeAll()
        needCalculateData.erase()
        collectionView.dataSource = dataSource
        snapshot.appendSections([.winrate, .firstDivider, .ratings, .secondDivider, .frags, .thirdDivider, .shoots, .fourtDivider, .good, .average, .bad])
        dataSource.apply(snapshot)
    }
    
    func runProcess(accountId: Int, gameType: KTTCApi.GameType, nickName: String?) {
        nullableAllData()
        self.gameType = gameType
        self.accountId = accountId
        searchController.dismiss(animated: true) { [weak self] in
            self?.searchController.isActive = false
            self?.searchController.searchBar.placeholder = nickName
        }
    }
    
    func getInfo(with accountId: Int) {
        api.request(with: UserInfo<AnyData<AnyUserData>>.self, gameType: gameType, .account, .info, [.accountId: "\(accountId)"]).start { [weak self] userInfo in
            guard let self = self else { return }
            if let all = userInfo.data?.data?.statistics?.all {
                let damage = all["damage_dealt"] ?? 0
                let battles = all["battles"] ?? 0
                let spotted = all["spotted"] ?? 0
                let frags = all["frags"] ?? 0
                let wins = all["wins"] ?? 0
                let maxFrags = all["max_frags"] ?? 0
                let def = all["dropped_capture_points"] ?? 0
                let xp = all["xp"] ?? 0
                let cap = all["capture_points"] ?? 0
                let hits = all["hits_percents"] ?? 0
                let assist = all["avg_damage_assisted"] ?? 0
                let maxDamage = all["max_damage"] ?? 0
                
                self.needCalculateData.xp = xp ?? 0
                self.needCalculateData.damage = damage ?? 0
                self.needCalculateData.battles = battles ?? 0
                self.needCalculateData.spotted = spotted ?? 0
                self.needCalculateData.frags = frags ?? 0
                self.needCalculateData.wins = wins ?? 0
                self.needCalculateData.maxFrags = maxFrags ?? 0
                self.needCalculateData.def = def ?? 0
                self.needCalculateData.cap = cap ?? 0
                self.needCalculateData.hits = hits?.round(to: 2) ?? 0
                self.needCalculateData.assist = assist?.round(to: 2) ?? 0
                self.needCalculateData.maxDamage = maxDamage?.round(to: 2) ?? 0
                
                self.averageData = WN8CalculateData(DAMAGE_DEAULT: damage ?? 0, SPOTTED: spotted ?? 0, FRAGS: frags ?? 0, DROPPED_CAPTURE_POINTS: def ?? 0, WIN_RATE: ((wins ?? 0) / (battles ?? 0) * 100).round(to: 2), WINS: wins ?? 0, BATTLES: battles ?? 0, ID: 0)
            }
        } error: { error in
            print(error.userInfo["message"].unsafelyUnwrapped)
        }
    }
    
    func getAnotherData(with accountId: Int) {
        activityIndicator.startAnimating()
        api.request(with: UserInfo<AnyData<T>>.self, gameType: gameType, .tanks, .stats, [.accountId: "\(accountId)"]).start { [weak self] userInfo in
            guard let self = self else { return }
            userInfo.data?.dataArray?.forEach { anyValue in
                if let anyValue = anyValue as? AnyBlitzTanksStats {
                    if let all = anyValue.all {
                        self.calcData.append(WN8CalculateData(DAMAGE_DEAULT: Double(all["damage_dealt"] ?? 0), SPOTTED: Double(all["spotted"] ?? 0), FRAGS: Double(all["frags"] ?? 0), DROPPED_CAPTURE_POINTS: Double(all["dropped_capture_points"] ?? 0), WIN_RATE: (Double(all["wins"] ?? 0) / Double(all["battles"] ?? 0)) * 100, BATTLES: Double(all["battles"] ?? 0), ID: anyValue.tankId ?? 0))
                    }
                    if let id = anyValue.tankId {
                        self.existTanks.append(id)
                    }
                } else if let anyValue = anyValue as? AnyTanksStats {
                    if let all = anyValue.all {
                        self.calcData.append(WN8CalculateData(DAMAGE_DEAULT: Double(all["damage_dealt"] ?? 0), SPOTTED: Double(all["spotted"] ?? 0), FRAGS: Double(all["frags"] ?? 0), DROPPED_CAPTURE_POINTS: Double(all["dropped_capture_points"] ?? 0), WIN_RATE: (Double(all["wins"] ?? 0) / Double(all["battles"] ?? 0)) * 100, BATTLES: Double(all["battles"] ?? 0), ID: anyValue.tankId ?? 0))
                    }
                    if let id = anyValue.tankId {
                        self.existTanks.append(id)
                    }
                }
            }
            self.getInfo(with: self.accountId)
        } error: { error in
            print(error.userInfo["message"].unsafelyUnwrapped)
        } completed: { [weak self] in
            guard let self = self else { return }
            self.api.requestXVM(with: Info.self).start { expValues in
                expValues.data?.forEach({ data in
                    if let id = data.idNum, self.existTanks.contains(id) {
                        self.expCalcData.append(WN8CalculateData(DAMAGE_DEAULT: Double(data.expDamage ?? 0), SPOTTED: Double(data.expSpot ?? 0), FRAGS: Double(data.expFrag ?? 0), DROPPED_CAPTURE_POINTS: Double(data.expDef ?? 0), WIN_RATE: Double(data.expWinRate ?? 0), ID: id))
                    }
                })
                self.calcData = self.calcData.filter { firstElement in
                    self.expCalcData.contains { secondElement in
                        return firstElement.ID == secondElement.ID
                    }
                }
            } error: { error in
                print(error.userInfo["message"].unsafelyUnwrapped)
            } completed: {
                self.api.request(with: UserInfo<Data<Tank>>.self, gameType: self.gameType, .encyclopedia, .vehicles, [.tankId: self.calcData.map { String($0.ID) }.joined(separator: ",")]).start { tanksInfo in
                    var levelSum = 0
                    var levels: [Int] = []
                    for tank in tanksInfo.data?.dataArray ?? [] {
                        let tankName = tank.name ?? ""
                        let tankId = tank.tankId ?? 0
                        let level = tank.tier ?? 0
                        levelSum += tank.tier ?? 0
                        levels.append(tank.tier ?? 0)
                        self.names[tankId] = TankModel(name: tankName, level: "\(level) уровень", id: tankId)
                    }
                    self.needCalculateData.averageLevel = Double(levelSum) / Double(levels.count)
                } error: { error in
                    print(error.userInfo["message"].unsafelyUnwrapped)
                } completed: {
                    self.calculator = KTTCCalculator(WN6CalculateData(DAMAGE_DEAULT: self.needCalculateData.avgDamage, SPOTTED: self.needCalculateData.avgSpotted, FRAGS: self.needCalculateData.avgFrags, DROPPED_CAPTURE_POINTS: self.needCalculateData.avgDef, WIN_RATE: self.needCalculateData.winrate, AVERAGE_LEVEL: self.needCalculateData.averageLevel, BATTLES: self.needCalculateData.battles))
                    self.needCalculateData.wn6 = self.calculator?.calculate(state: .wn6) as? WN6 ?? 0
                    
                    self.calculator = nil
                    
                    self.calculator = KTTCCalculator(WN6CalculateData(DAMAGE_DEAULT: self.needCalculateData.avgDamage, SPOTTED: self.needCalculateData.avgSpotted, FRAGS: self.needCalculateData.avgFrags, DROPPED_CAPTURE_POINTS: self.needCalculateData.avgDef, WIN_RATE: self.needCalculateData.winrate, AVERAGE_LEVEL: self.needCalculateData.averageLevel, BATTLES: self.needCalculateData.battles))
                    self.needCalculateData.wn7 = self.calculator?.calculate(state: .wn7) as? WN7 ?? 0
                    
                    self.calculator = nil

                    if let averageData = self.averageData {
                        self.calculator = KTTCCalculator(self.calcData, self.expCalcData, averageData)
                        
                        self.needCalculateData.wn8 = self.calculator?.calculate(state: .wn8) as? WN8 ?? 0
                        self.calculator = nil
                    }
                    
                    self.calculator = KTTCCalculator(EFFCalculateData(AVERAGE_LEVEL: self.needCalculateData.averageLevel, DAMAGE_DEAULT: self.needCalculateData.avgDamage, SPOTTED: self.needCalculateData.avgSpotted, FRAGS: self.needCalculateData.avgFrags, DROPPED_CAPTURE_POINTS: self.needCalculateData.avgDef, CAP: self.needCalculateData.avgCap))
                    self.needCalculateData.eff = self.calculator?.calculate(state: .eff) as? EFF ?? 0
                    
                    self.calculator = nil
                    
                    self.snapshot.appendItems([.key("Количество боёв:"), .value(["battles": self.needCalculateData.battles])], toSection: .winrate)
                    self.snapshot.appendItems([.key("Процент побед:"), .value(["winrate": self.needCalculateData.winrate])], toSection: .winrate)
                    self.snapshot.appendItems([.key("Средний уровень:"), .value(["averageLevel": self.needCalculateData.averageLevel.round(to: 1)])], toSection: .winrate)
                    
                    self.snapshot.appendItems([.key(" "), .value(["d1": 0])], toSection: .firstDivider)
                    
                    self.snapshot.appendItems([.key("Рейтинг WN6:"), .value(["wn6": self.needCalculateData.wn6])], toSection: .ratings)
                    self.snapshot.appendItems([.key("Рейтинг WN7:"), .value(["wn7" : self.needCalculateData.wn7])], toSection: .ratings)
                    self.snapshot.appendItems([.key("Рейтинг WN8:"), .value(["wn8" : self.needCalculateData.wn8])], toSection: .ratings)
                    self.snapshot.appendItems([.key("Рейтинг РЭ:"), .value(["eff": self.needCalculateData.eff])], toSection: .ratings)
                    
                    self.snapshot.appendItems([.key("  "), .value(["d2": 0])], toSection: .secondDivider)
                    
                    self.snapshot.appendItems([.key("Средний урон:"), .value(["avgDamage": self.needCalculateData.avgDamage])], toSection: .frags)
                    self.snapshot.appendItems([.key("Максимально уничтожил:"), .value(["maxFrags": self.needCalculateData.maxFrags])], toSection: .frags)
                    if !self.isBlitz {
                        self.snapshot.appendItems([.key("Ассист урон:"), .value(["assist": self.needCalculateData.assist])], toSection: .frags)
                        self.snapshot.appendItems([.key("Максимальный урон:"), .value(["maxDamage": self.needCalculateData.maxDamage])], toSection: .frags)
                        self.snapshot.appendItems([.key("Процент попаданий:"), .value(["hits": self.needCalculateData.hits])], toSection: .frags)
                    }
                    
                    self.snapshot.appendItems([.key("   "), .value(["d3": 0])], toSection: .thirdDivider)
                    
                    self.snapshot.appendItems([.key("Обнаружено врагов (всего):"), .value(["spotted": self.needCalculateData.spotted])], toSection: .shoots)
                    self.snapshot.appendItems([.key("Обнаружено врагов (cредний):"), .value(["avgSpotted": self.needCalculateData.avgSpotted])], toSection: .shoots)
                    self.snapshot.appendItems([.key("Уничтожено врагов (всего):"), .value(["frags": self.needCalculateData.frags])], toSection: .shoots)
                    self.snapshot.appendItems([.key("Уничтожено врагов (cредний):"), .value(["avgFrags": self.needCalculateData.avgFrags])], toSection: .shoots)
                    
                    self.snapshot.appendItems([.key("    "), .value(["d4": 0])], toSection: .fourtDivider)
                    
                    self.snapshot.appendItems([.level(["Уникум": "6"]), .level(["Средний игрок": "5"])], toSection: .good)
                    self.snapshot.appendItems([.level(["Великолепный игрок": "4"]), .level(["Игрок ниже среднего": "3"])], toSection: .average)
                    self.snapshot.appendItems([.level(["Хороший игрок": "2"]), .level(["Плохой игрок": "1"])], toSection: .bad)
                    
                    DispatchQueue.main.async {
                        self.dataSource.apply(self.snapshot)
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        }
    }
    
    func makeDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, object in
            guard let self = self else { abort() }
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ParameterCell", for: indexPath) as? ParameterCell else { abort() }
            
            let section = self.snapshot.sectionIdentifiers[indexPath.section]
            
            switch object {
            case .level(let dictionary):
                if let key = dictionary.keys.first, indexPath.section > 7 {
                    cell.backgroundColor = .systemBackground
                    cell.parameterLabel.text = key
                    cell.parameterLabel.font = .systemFont(ofSize: 13, weight: .bold)

                    switch key {
                    case "Уникум":
                        cell.parameterLabel.textColor = .color(from: 0xb14cc2)
                    case "Великолепный игрок":
                        cell.parameterLabel.textColor = .color(from: 0x06a7a7)
                    case "Хороший игрок":
                        cell.parameterLabel.textColor = .color(from: 0x59e500)
                    case "Средний игрок":
                        cell.parameterLabel.textColor = .color(from: 0xffe704)
                    case "Игрок ниже среднего":
                        cell.parameterLabel.textColor = .color(from: 0xff8e00)
                    case "Плохой игрок":
                        cell.parameterLabel.textColor = .color(from: 0xff2901)
                    default:
                        cell.parameterLabel.textColor = .label
                    }
                }
            case .key(let key):
                cell.parameterLabel.text = key
                cell.parameterLabel.textColor = .label
                cell.parameterLabel.font = .systemFont(ofSize: 14, weight: .medium)
            case .value(let dictionary):
                cell.parameterLabel.text = "\((dictionary[dictionary.keys.first ?? ""] ?? 0))"
                cell.parameterLabel.font = .systemFont(ofSize: 14, weight: .medium)

                if let key = dictionary.keys.first {
                    let value = dictionary[key]
                    
                    if indexPath.item % 2 != 0 && indexPath.section < 8 {
                        switch key {
                        case "avgDamage":
                            cell.parameterLabel.textColor = .xwmColor(from: .damage, with: Int(value ?? 0))
                        case "wn6":
                            cell.parameterLabel.textColor = .xwmColor(from: .wn6, with: Int(value ?? 0))
                            cell.parameterLabel.text = "\((dictionary[dictionary.keys.first ?? ""] ?? 0).round(to: 2))"
                        case "wn7":
                            cell.parameterLabel.textColor = .xwmColor(from: .wn7, with: Int(value ?? 0))
                            cell.parameterLabel.text = "\((dictionary[dictionary.keys.first ?? ""] ?? 0).round(to: 2))"
                        case "wn8":
                            cell.parameterLabel.textColor = .xwmColor(from: .wn8, with: Int(value ?? 0))
                            cell.parameterLabel.text = "\((dictionary[dictionary.keys.first ?? ""] ?? 0).round(to: 2))"
                        case "winrate":
                            cell.parameterLabel.textColor = .xwmColor(from: .winrate, with: Int(value ?? 0))
                            cell.parameterLabel.text = "\(dictionary[dictionary.keys.first ?? ""] ?? 0)%"
                        case "battles":
                            cell.parameterLabel.textColor = .label
                            cell.parameterLabel.text = "\(Int(dictionary[dictionary.keys.first ?? ""] ?? 0))"
                        case "maxFrags":
                            cell.parameterLabel.textColor = .xwmColor(from: .frags, with: Int(value ?? 0))
                            cell.parameterLabel.text = "\(Int(dictionary[dictionary.keys.first ?? ""] ?? 0))"
                        case "eff":
                            cell.parameterLabel.textColor = .xwmColor(from: .eff, with: Int(value ?? 0))
                            cell.parameterLabel.text = "\((dictionary[dictionary.keys.first ?? ""] ?? 0).round(to: 2))"
                        case "spotted", "frags":
                            cell.parameterLabel.textColor = .label
                            cell.parameterLabel.text = "\(Int(dictionary[dictionary.keys.first ?? ""] ?? 0))"
                        default:
                            cell.parameterLabel.textColor = .label
                        }
                    }
                }
            }
            
            switch section {
            case .firstDivider, .secondDivider, .thirdDivider, .fourtDivider:
                cell.backgroundColor = .color(from: 0xFCF8E3)
                cell.parameterLabel.text = nil
            default:
                cell.backgroundColor = .systemBackground
            }
            
            return cell
        }
        
        return dataSource
    }
    
    func makeSnapshot() -> Snapshot {
        return Snapshot()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let search = searchController.searchBar.text, !search.isEmpty else { return }
        guard let searchViewController = searchController.searchResultsController as? StartViewController else { return }
        guard isSearch else { return }
        api.request(with: UserInfoWithArray<User>.self, .account, .list, [.search: search.trimmingCharacters(in: .whitespacesAndNewlines)]).start { users in
            searchViewController.users = users.data ?? []
        } error: { error in
            print(error)
        } completed: { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                searchViewController.mainTable.reloadData()
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
    
    @objc func update() {
        if accountId > 0 { nullableAllData(); getAnotherData(with: accountId) }
        updater.endRefreshing()
    }
}

extension Array: Mappable {
    public init?(map: Map) { self.init() }
    public mutating func mapping(map: Map) { }
}

/// MARK: NSAttributedString
extension NSAttributedString {
    func replacingCharacters(in range: NSRange, with attributedString: NSAttributedString) -> NSMutableAttributedString {
        let ns = NSMutableAttributedString(attributedString: self)
        ns.replaceCharacters(in: range, with: attributedString)
        return ns
    }
    
    static func += (lhs: inout NSAttributedString, rhs: NSAttributedString) {
        let ns = NSMutableAttributedString(attributedString: lhs)
        ns.append(rhs)
        lhs = ns
    }
    
    static func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
        let ns = NSMutableAttributedString(attributedString: lhs)
        ns.append(rhs)
        return NSAttributedString(attributedString: ns)
    }
    
    func with(lineSpacing spacing: CGFloat) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(attributedString: self)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.lineSpacing = spacing
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: string.count))
        return NSAttributedString(attributedString: attributedString)
    }
    
    class var attributedSpace: NSAttributedString {
        return NSAttributedString(string: " ")
    }

    class var attributedNewLine: NSAttributedString {
        return NSAttributedString(string: "\n")
    }
}

extension UIColor {
    static func xwmColor(from state: StatType, with value: Int) -> UIColor {
        switch state {
        case .wn6, .wn7:
            if Range(0...469).contains(value) {
                return .color(from: 0xff2901)
            } else if Range(470...859).contains(value) {
                return .color(from: 0xff8e00)
            } else if Range(860...1224).contains(value) {
                return .color(from: 0xffe704)
            } else if Range(1225...1634).contains(value) {
                return .color(from: 0x59e500)
            } else if Range(1635...1989).contains(value) {
                return .color(from: 0x06a7a7)
            } else {
                return .color(from: 0xb14cc2)
            }
        case .wn8:
            if Range(0...314).contains(value) {
                return .color(from: 0xff2901)
            } else if Range(315...754).contains(value) {
                return .color(from: 0xff8e00)
            } else if Range(755...1314).contains(value) {
                return .color(from: 0xffe704)
            } else if Range(1315...1964).contains(value) {
                return .color(from: 0x59e500)
            } else if Range(1965...2524).contains(value) {
                return .color(from: 0x06a7a7)
            } else {
                return .color(from: 0xb14cc2)
            }
        case .eff:
            if Range(0...629).contains(value) {
                return .color(from: 0xff2901)
            } else if Range(630...859).contains(value) {
                return .color(from: 0xff8e00)
            } else if Range(860...1139).contains(value) {
                return .color(from: 0xffe704)
            } else if Range(1140...1459).contains(value) {
                return .color(from: 0x59e500)
            } else if Range(1460...1734).contains(value) {
                return .color(from: 0x06a7a7)
            } else {
                return .color(from: 0xb14cc2)
            }
        case .winrate:
            if Range(0...46).contains(value) {
                return .color(from: 0xff2901)
            } else if Range(47...48).contains(value) {
                return .color(from: 0xff8e00)
            } else if Range(49...51).contains(value) {
                return .color(from: 0xffe704)
            } else if Range(52...56).contains(value) {
                return .color(from: 0x59e500)
            } else if Range(57...64).contains(value) {
                return .color(from: 0x06a7a7)
            } else {
                return .color(from: 0xb14cc2)
            }
        case .xte:
            if Range(0...314).contains(value) {
                return .color(from: 0xff2901)
            } else if Range(315...754).contains(value) {
                return .color(from: 0xff8e00)
            } else if Range(755...1314).contains(value) {
                return .color(from: 0xffe704)
            } else if Range(1315...1964).contains(value) {
                return .color(from: 0x59e500)
            } else if Range(1965...2524).contains(value) {
                return .color(from: 0x06a7a7)
            } else {
                return .color(from: 0xb14cc2)
            }
        case .battles:
            if Range(0...1500).contains(value) {
                return .color(from: 0xff2901)
            } else if Range(1001...4000).contains(value) {
                return .color(from: 0xff8e00)
            } else if Range(4001...10000).contains(value) {
                return .color(from: 0xffe704)
            } else if Range(10001...15000).contains(value) {
                return .color(from: 0x59e500)
            } else if Range(15001...20000).contains(value) {
                return .color(from: 0x06a7a7)
            } else {
                return .color(from: 0xb14cc2)
            }
        case .damage:
            if Range(0...500).contains(value) {
                return .color(from: 0xff2901)
            } else if Range(501...750).contains(value) {
                return .color(from: 0xff8e00)
            } else if Range(751...1000).contains(value) {
                return .color(from: 0xffe704)
            } else if Range(1001...1800).contains(value) {
                return .color(from: 0x59e500)
            } else if Range(1801...2500).contains(value) {
                return .color(from: 0x06a7a7)
            } else {
                return .color(from: 0xb14cc2)
            }
        case .frags:
            if Range(1...2).contains(value) {
                return .color(from: 0xff2901)
            } else if Range(2...3).contains(value) {
                return .color(from: 0xff8e00)
            } else if Range(3...4).contains(value) {
                return .color(from: 0xffe704)
            } else if Range(4...5).contains(value) {
                return .color(from: 0x59e500)
            } else if Range(5...6).contains(value) {
                return .color(from: 0x06a7a7)
            } else {
                return .color(from: 0xb14cc2)
            }
        }
    }
}

extension ViewController {
    func configureLayout() -> UICollectionViewCompositionalLayout {
        let layout = layout()
        return layout
    }

    private func layout() -> UICollectionViewCompositionalLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { [weak self] index, layoutEnvironment in
            guard let self = self else { return .none }
            let layoutWidth = layoutEnvironment.container.contentSize.width
            
            let section = self.snapshot.sectionIdentifiers[index]
            
            let layoutSection: NSCollectionLayoutSection
            
            switch section {
            case .average, .good, .bad:
                let firstItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1))
                let firstItem = NSCollectionLayoutItem(layoutSize: firstItemSize)
                
                let secondItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1))
                let secondItem = NSCollectionLayoutItem(layoutSize: secondItemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(layoutWidth), heightDimension: .absolute(32))
                let group: NSCollectionLayoutGroup = .horizontal(layoutSize: groupSize, subitems: [firstItem, secondItem])

                layoutSection = NSCollectionLayoutSection(group: group)
            case .firstDivider, .secondDivider, .thirdDivider, .fourtDivider:
                let firstItemSize = NSCollectionLayoutSize(widthDimension: .absolute(0.01), heightDimension: .fractionalHeight(1))
                let firstItem = NSCollectionLayoutItem(layoutSize: firstItemSize)
                
                let secondItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let secondItem = NSCollectionLayoutItem(layoutSize: secondItemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(layoutWidth), heightDimension: .absolute(32))
                let group: NSCollectionLayoutGroup = .horizontal(layoutSize: groupSize, subitems: [firstItem, secondItem])
                

                layoutSection = NSCollectionLayoutSection(group: group)
            default:
                let firstItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(2.25/3), heightDimension: .fractionalHeight(1))
                let firstItem = NSCollectionLayoutItem(layoutSize: firstItemSize)
                
                let secondItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.75/3), heightDimension: .fractionalHeight(1))
                let secondItem = NSCollectionLayoutItem(layoutSize: secondItemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(layoutWidth), heightDimension: .absolute(32))
                let group: NSCollectionLayoutGroup = .horizontal(layoutSize: groupSize, subitems: [firstItem, secondItem])

                layoutSection = NSCollectionLayoutSection(group: group)
            }
            return layoutSection
        }, configuration: config)

        return layout
    }
}

extension Double {
    func round(to places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
