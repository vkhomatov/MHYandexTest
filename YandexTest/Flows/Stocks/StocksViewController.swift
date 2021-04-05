//
//  MainViewController.swift
//  YandexTest
//
//  Created by Vitaly Khomatov on 24.03.2021.
//

import UIKit
import Kingfisher
import RealmSwift


class StocksViewController: UIViewController, UISearchBarDelegate, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
    
    private var searchController = UISearchController(searchResultsController: nil)
    private var tableView = UITableView(frame: .zero)
    public var headerView = StocksHeaderView(frame: .zero)
    private let stockCellId = "stockCellId"
    private var searchView = StocksSearchView(frame: .zero)
    public let model = StocksModel()
    private var network = NetworkMonitor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupSearchBar()
        setupTable()
        setupHeader()
        setupSearchView()
        setupRefreshControl()
        setCallbacks()
        startNetworkMonitor()
        getFavoriteQuotes()
        getSearchLabes()
        loadTickers(readRealm: true)
        getPopularSearchLabels()
        message()
    }
    
    
    // MARK: - NetworkMonitor
    private func startNetworkMonitor() {

        #if targetEnvironment(simulator)
        network.monitor.pathUpdateHandler = { path in
            if path.status == .unsatisfied  {
                self.showError(message: "Online Mode", delay: 2)
            //self.updateData()
            } else if path.status == .satisfied {
                self.showError(message: "Offline Mode", delay: 2)
            }
        }
        #else
        network.monitor.pathUpdateHandler = { path in
            if path.status == .satisfied  {
                self.showError(message: "Online Mode", delay: 2)
             //   self.updateData()
            } else if path.status == .unsatisfied  {
                self.showError(message: "Offline Mode", delay: 2)
            }
        }
        #endif
    }
    
    
    
    // MARK: - NavigationBar
    private func setupNavBar() {
        navigationController?.definesPresentationContext = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.layoutIfNeeded()
        navigationController?.navigationBar.sizeToFit()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView:searchController.searchBar)
    }
    
    // MARK: - SerchBar
    private func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.definesPresentationContext = true
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Find ticker or company")
        searchController.searchBar.searchTextField.layer.cornerRadius = 18
        searchController.searchBar.searchTextField.layer.masksToBounds = true
        searchController.searchBar.searchTextField.layer.borderWidth = 1
        searchController.searchBar.searchTextField.layer.borderColor = UIColor.systemGray5.cgColor
        searchController.searchBar.searchTextField.backgroundColor = .white
       // searchController.searchBar.showsCancelButton = false
    }
    
    func searchBar(_ frendsSearch: UISearchBar, textDidChange searchText: String) {
        updateSearchResults(for: self.searchController)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            if let text = searchField.text {
                
                if text.count < 1 {
                    model.search = false
                    model.searchText = ""
                    searchController.resignFirstResponder()
                    self.spinnerStop()
                    self.model.isLoading = false
                    self.headerView.state = self.model.stateName
                    DispatchQueue.main.async { self.tableView.reloadData() }
                    
                } else if !model.isLoading && text != model.searchText + ","  {
                    self.headerView.state = .search
                    model.searchText = text
                    hideLabels()
                    
                    self.model.isLoading = true
                    spinnerStart(message: "Searching")
                    model.loadQuotes(symbol: text) {  [weak self] message in
                        guard let self = self else { return }
                        if let error = message {
                            self.spinnerStop()
                            self.model.isLoading = false
                            if self.model.allQuotes.count > 0  {
                                self.model.searchQuotes =  self.model.allQuotes.filter( { $0.symbol.prefix(text.count).description.lowercased() == text.lowercased() } )
                                for element in self.model.allQuotes.filter( { $0.shortName.prefix(text.count).description.lowercased() == text.lowercased() } ) {
                                    if  !self.model.searchQuotes.contains(element) {
                                        self.model.searchQuotes.append(element)
                                    }
                                }
                                self.model.search = true
                                DispatchQueue.main.async { self.tableView.reloadData() }
                            } else {
                                self.showError(message: error, delay: 2)
                            }
                        } else {
                            self.setFavoriteQuotes(quotes: self.model.searchQuotes)
                            
                            self.spinnerStop()
                            self.model.isLoading = false
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                    model.search = true
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideLabels()
        model.search = false
        model.searchText = ""
        self.spinnerStop()
        self.model.isLoading = false
        self.headerView.state = self.model.stateName
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.spinnerStop()
        self.model.isLoading = false
        if model.searchLabels.popularSymbols.count > 0 || model.searchLabels.yoursSymbols.count > 0 {
            showLabels(popularStrings: searchView.popularStrings.count, yoursStrings: searchView.yoursStrings.count)
        }
    }
    
    func setupSearchView() {
        searchView = StocksSearchView(frame: CGRect(x: 0, y: headerView.frame.minY, width: view.frame.width, height: view.frame.height - headerView.frame.minY))
    }
    
    
    // MARK: - HeaderView
    private func setupHeader() {
        headerView = StocksHeaderView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: 62.0))
        headerView.backgroundColor = .white
        //headerView.layer.cornerRadius = 10
    }
    
    // MARK: - RefreshControl
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(updateData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        refreshControl.layer.opacity = 0.75
        refreshControl.tintColor = .red
    }
    
    // MARK: - TableView
    private func setupTable() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(StockTableViewCell.self, forCellReuseIdentifier: stockCellId)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.keyboardDismissMode = .onDrag
        view.addSubview(tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if model.search {
            return model.searchQuotes.count
        }  else {
            if headerView.state == .favourite {
                return model.myQuotes.count
            } else {
                return model.allQuotes.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: stockCellId, for: indexPath) as? StockTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        if indexPath.row % 2 == 0 { cell.contentView.backgroundColor = .systemGray5 }
        
        cell.starButtonCallback = { [weak self] status in
            guard let self = self else { return }
            
            switch self.headerView.state {
            case .stocks:
                try? RealmService.saveTicker(ticker: self.model.allQuotes[indexPath.row], status: status)
                self.getFavoriteQuotes()
            case .favourite:
                if let index = self.model.allQuotes.firstIndex(of: self.model.myQuotes[indexPath.row]) {
                    try? RealmService.saveTicker(ticker: self.model.allQuotes[index], status: status)
                } else {
                    try? RealmService.saveTicker(ticker: self.model.myQuotes[indexPath.row], status: status)
                }
                self.model.myQuotes.remove(at: indexPath.row)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .search:
                if let index = self.model.allQuotes.firstIndex(of: self.model.searchQuotes[indexPath.row]) {
                    try? RealmService.saveTicker(ticker: self.model.allQuotes[index], status: status)
                }
                try? RealmService.saveTicker(ticker: self.model.searchQuotes[indexPath.row], status: status)
                self.getFavoriteQuotes()
            }
        }
        
        if !model.search {
            if  headerView.state == .stocks {
                setCellData(cell: cell, indexPath: indexPath, quotes: model.allQuotes)
            } else {
                setCellData(cell: cell, indexPath: indexPath, quotes: model.myQuotes)
            }
        } else {
            setCellData(cell: cell, indexPath: indexPath, quotes: model.searchQuotes)
            if model.searchQuotes.count > 0 {
                if !model.searchLabels.yoursSymbols.contains(model.searchText.trimmingCharacters(in: .whitespaces)) {
                    try? RealmService.saveSearchLabels(searchLabels: model.searchLabels, labels: [model.searchText], my: true)
                    self.searchView.newLabel = model.searchText
                }
            }
        }
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height && headerView.state == .stocks && !model.search {
            if !self.model.firstTime {
                if model.isLoading == false  {
                    loadTickers(start: model.allQuotes.count+1)
                } else {
                    #if DEBUG
                    print("Loading Process")
                    #endif
                }
            }
            self.model.firstTime = false
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 62
    }
    
    
    // MARK: - Callbacks
    private func setCallbacks() {
        headerView.buttonCallback = { [weak self] state in
            guard let self = self else { return }
            switch state {
            case .favourite:
                DispatchQueue.main.async {
                    self.getFavoriteQuotes()
                    self.model.stateName = self.headerView.state
                    if self.model.firstRun {
                        if self.model.myQuotes.count > 0  {
                            self.updateQuotesData(oldQuotes: self.model.myQuotes)
                            self.model.firstRun = false

                        }
                    }
                    self.tableView.reloadData()
                }
            case .stocks:
                self.model.stateName = self.headerView.state
                DispatchQueue.main.async {
                    if self.model.allQuotes.count < 25 {
                        self.loadTickers(readRealm: true)
                    }
                    self.tableView.reloadData()
                }
            case .search:
                break
            }
        }
        searchView.labelCallback = { [weak self] text in
            guard let self = self else { return }
            self.searchController.searchBar.text = text
        }
    }
    
    
    // MARK: - Functions
    public func loadTickers(start: Int = 1, readRealm: Bool? = nil) {
        self.model.isLoading = true
        self.spinnerStart(message: "Loading")
        model.loadQuoteCollections(start: start) {  [weak self] (message) in
            guard let self = self else { return }
            if let error = message {
                
                self.spinnerStop()
                self.model.isLoading = false
                
                if let readRealm = readRealm, readRealm == true {
                    if let quote = try? RealmService.getTickers(Quote.self) {
                        self.model.allQuotes = quote
                        DispatchQueue.main.async { self.tableView.reloadData() }
                        #if DEBUG
                        print("Characters load from Realm")
                        #endif
                        self.model.stocksPriceColor = .red
                        self.showError(message: "Offline mode, загружена база от \(self.model.searchLabels.getFullDateString(from: self.model.searchLabels.dataDate))", delay: 4)
                    } else {
                        self.showError(message: error, delay: 2)
                    }
                }
                #if DEBUG
                print("Error = ", error)
                #endif
            } else {
                self.setFavoriteQuotes(quotes: self.model.allQuotes)
                self.spinnerStop()
                self.model.isLoading = false
                self.model.stocksPriceColor = .black
                DispatchQueue.main.async { self.tableView.reloadData() }
                try? RealmService.saveTickers(tickers: self.model.allQuotes)
            }
        }
    }
    
    
    public func updateQuotesData(oldQuotes: [Quote]) {
        self.model.isLoading = true
        self.spinnerStart(message: "Update data")
        self.model.reloadQuotes(oldQuotes: oldQuotes) { [weak self] message in
            guard let self = self else { return }
            if let error = message {
                self.spinnerStop()
                self.model.isLoading = false
                self.showError(message: error, delay: 2)
                
                switch self.headerView.state {
                case .stocks:
                    self.model.stocksPriceColor = .red
                case .favourite:
                    self.model.favouritesPriceColor = .red
                case .search:
                    break
                }
                DispatchQueue.main.async { self.tableView.reloadData() }

                #if DEBUG
                print("Ошибка обновления тикеров \(error)")
                #endif
            } else {
                
                switch self.headerView.state {
                case .stocks:
                    self.model.stocksPriceColor = .black
                case .favourite:
                    self.model.favouritesPriceColor = .black
                case .search:
                    break
                }
                
                self.spinnerStop()
                self.model.isLoading = false
                DispatchQueue.main.async { self.tableView.reloadData() }
                #if DEBUG
                print("Обновления тикеров завершено")
                #endif
            }
        }
    }
    
    
    @objc func updateData() {
        tableView.refreshControl?.beginRefreshing()
        switch self.headerView.state {
        case .stocks:
                if self.model.allQuotes.count > 0 {
                    self.updateQuotesData(oldQuotes: self.model.allQuotes)
                } else {
                    self.loadTickers(readRealm: true)
                }
            
        case .favourite:
                if self.model.myQuotes.count > 0 {
                    self.updateQuotesData(oldQuotes: self.model.myQuotes)
                }
        case .search:
            break
        }
        tableView.refreshControl?.endRefreshing()
    }
    
    
    
    private func setFavoriteQuotes(quotes: [Quote]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            for fnum in 0..<self.model.myQuotes.count {
                for qnum in 0..<quotes.count {
                    if self.model.myQuotes[fnum] == quotes[qnum] {
                        try? RealmService.saveTicker(ticker: quotes[qnum], status: true)
                    }
                }
            }
        }
    }
    
    private func getFavoriteQuotes() {
        if let quotes = try? RealmService.getTickers(Quote.self) {
            self.model.myQuotes = quotes.filter {$0.starStatus == true}
        }
    }
    
    private func getSearchLabes() {
        if let searchLabels = try? RealmService.getSearchLabels(SearchLabels.self) {
            model.searchLabels = searchLabels
        }
    }
    
    private func getPopularSearchLabels() {
        model.networkService.getMostWatchedLabels { result in
            switch result {
            case let .success(data):
                try? RealmService.saveSearchLabels(searchLabels: self.model.searchLabels, labels: data[0].popularSymbols, my: false)
            case .failure(let error):
                #if DEBUG
                print(error.localizedDescription.split(separator: ":").last as Any)
                #endif
            }
            self.searchView.popularStrings = self.model.searchLabels.popularSymbols
            self.searchView.yoursStrings = self.model.searchLabels.yoursSymbols
        }
    }
    
    private func setCellData(cell: StockTableViewCell, indexPath: IndexPath, quotes: [Quote]) {
        
        if indexPath.row < quotes.count {
            cell.symbolLabel.text = quotes[indexPath.row].symbol
            cell.companyLabel.text = quotes[indexPath.row].getCompanyName()
            cell.priceLabel.text = quotes[indexPath.row].getPrice()
            switch self.headerView.state {
            case .stocks:
                cell.priceLabel.textColor = model.stocksPriceColor
            case .favourite:
                cell.priceLabel.textColor = model.favouritesPriceColor
            case .search:
                break
            }
            cell.dayPriceChangeLabel.text = quotes[indexPath.row].getCoeff()
            cell.dayPriceChangeLabel.textColor = quotes[indexPath.row].coeffColor
            cell.starButtonStatus = quotes[indexPath.row].starStatus
            cell.logoImageView.kf.setImage(with: URL(string: quotes[indexPath.row].logoStr))
        }
    }
    
    private func spinnerStart(message: String) {
        if !model.spinnerWork {
            DispatchQueue.main.async {
                for cell in self.tableView.visibleCells { cell.layer.opacity = 0.2 }
                self.model.spinner = SpinnerView(frame: CGRect(x: self.view.frame.midX-self.view.frame.width/6, y: self.view.frame.midY-100, width: self.view.frame.width/3, height: 50))
                self.model.spinner.messageLabel.text = message
                self.tableView.isUserInteractionEnabled = false
                self.view.addSubview(self.model.spinner)
                self.model.spinner.start()
                self.model.spinnerWork.toggle()
            }
        }
    }
    
    private func spinnerStop() {
        if model.spinnerWork {
            DispatchQueue.main.async {
                self.model.spinner.stop()
                self.model.spinner.removeFromSuperview()
                for cell in self.tableView.visibleCells { cell.layer.opacity = 1 }
                self.tableView.isUserInteractionEnabled = true
                self.model.spinnerWork.toggle()
            }
        }
    }
    
    private func showError(message: String, delay: Double) {
        DispatchQueue.main.async {
            
            guard let navcontroller = self.navigationController?.view else { return }
            let errorMessage = ErrorMessage(view: navcontroller)
            errorMessage.showError(reverse: true, message: message, delay: delay)
        }
    }
    
    private func hideLabels() {
        if self.model.labelsDidShow {
            DispatchQueue.main.async {
                UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: { [weak self] in
                    guard let self = self else { return }
                    self.searchView.removeFromSuperview()
                }, completion: { _ in self.model.labelsDidShow.toggle() })
            }
        }
    }
    
    private func showLabels(popularStrings: Int, yoursStrings: Int) {
        if !self.model.labelsDidShow && (popularStrings > 0 ||  yoursStrings > 0 ) {
            DispatchQueue.main.async {
                UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: { [weak self] in
                    guard let self = self else { return }
                    self.view.addSubview(self.searchView)
                    self.view.bringSubviewToFront(self.searchView)
                }, completion: { _ in self.model.labelsDidShow.toggle() })
            }
        }
    }
    
    private func message() {
        let message = "Ребята, когда я подавал заявку в первый раз, мне пришло только алгоритмическое задание. Я сделал несколько задач, всего было 6 заданий на 6 часов и думал на этом тест закончен. Об этой второй части я случайно узнал только, когда смотрел эфир Яндекс школы на youtube, времени было очень мало, поэтому сделал только первичный функционал на сколько успел. О том, что успел: API не позволяет выполнять поиск по первым буквам и выдавать список тикером, поэтому такая возможность у меня есть только в оффлайн режиме, в API так же нет возможности получить логотипы компаний, поэтому для получения лого я использовал внешний сервис. Спасибо за внимание и понимание)!"
        let alert = UIAlertController(title: "Привет!", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "лады", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
}

