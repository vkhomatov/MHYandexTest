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
    var tableView = UITableView(frame: .zero)
    private var headerView = StocksHeaderView(frame: .zero)
    private let stockCellId = "stockCellId"
    private var searchView = StocksSearchView(frame: .zero)
    private let model = StocksModel()
    private var network = NetworkMonitor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupSearchBar()
        setupTable()
        setupHeader()
        setupSearchView()
        setCallbacks()
        startNetworkMonitor()
        getFavoriteQuotes()
        getSearchLabes()
        loadTickers(readRealm: true)
        getPopularSearchLabels()
        //message()
    }
   
    
    // MARK: - NetworkMonitor
    func startNetworkMonitor() {
        if !network.getNetworkStatus() {
            self.showError(message: "Offline Mode")
        }
        #if targetEnvironment(simulator)
        network.monitor.pathUpdateHandler = { path in
            if path.status == .unsatisfied  {
                self.showError(message: "Online Mode")
                if self.model.allQuotes.count < 25 {
                    self.loadTickers(readRealm: true)
                } else {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            } else if path.status == .satisfied {
                self.showError(message: "Offline Mode")
            }
        }
        #else
        network.monitor.pathUpdateHandler = { path in
            if path.status == .satisfied  {
                self.showError(message: "Online Mode")
                if self.model.allQuotes.count < 25 {
                    self.loadTickers(readRealm: true)
                } else {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            } else if path.status == .unsatisfied  {
                self.showError(message: "Offline Mode")
            }
        }
        #endif
    }
    
    
    func setFavoriteQuotes(quotes: [Quote]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            
            for fnum in 0..<self.model.myQuotes.count {
                for qnum in 0..<quotes.count {
                    if self.model.myQuotes[fnum] == quotes[qnum] {
                        try? RealmService.saveTicker(ticker: quotes[qnum], status: true)
                    }
                }
            }
            
//            self.model.myQuotes.forEach { quote in
//                if let index = quotes.firstIndex(of: quote) {
//                    try? RealmService.saveTicker(ticker: quotes[index], status: true)
//                }
//            }
            
            
        }
    }
    
    func getFavoriteQuotes() {
        if let quotes = try? RealmService.getTickers(Quote.self) {
            self.model.myQuotes = quotes.filter {$0.starStatus == true}
            print("Фавориты: \(self.model.myQuotes)")
        }
    }
    
    private func setCallbacks() {
        headerView.buttonCallback = { [weak self] state in
            guard let self = self else { return }
            switch state {
            case .favourite:
                //self.model.myQuotes = self.model.allQuotes.filter {$0.starStatus == true}
              //  self.model.myQuotes = try? RealmService.getTickers(<#T##type: Quote.Type##Quote.Type#>)
                self.getFavoriteQuotes()
               
                    
//                    self.model.allQuotes.forEach { quote in
//                        for realmQuote in self.model.myQuotes {
//                            if quote == realmQuote {
//                                quote.starStatus = realmQuote.starStatus
//                            }
//                        }
//                    }
                    
//                    self.model.myQuotes.forEach { quote in
//                        if let index = self.model.allQuotes.firstIndex(of: quote) {
//                            self.model.allQuotes[index].starStatus = true
//                        }
//                    }
                    
                    
                //}
                
                
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                if let index = self.model.favouriteIndexPath, index.row < self.model.myQuotes.count {
                    self.tableView.scrollToRow(at: index, at: .none, animated: false)
                }
            case .stocks:
              //  self.model.setFavorites(quotes: self.model.allQuotes)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    if let index = self.model.stocksIndexPath, index.row < self.model.allQuotes.count {
                        self.tableView.scrollToRow(at: index, at: .none, animated: false)
                    }
                }
                
            default :
                break
            }
        }
        
        searchView.labelCallback = { [weak self] text in
            guard let self = self else { return }
            self.searchController.searchBar.text = text
            self.headerView.state = .search
        }
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
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Find company or ticker")
        searchController.searchBar.searchTextField.layer.cornerRadius = 18
        searchController.searchBar.searchTextField.layer.masksToBounds = true
        searchController.searchBar.searchTextField.layer.borderWidth = 1
        searchController.searchBar.searchTextField.layer.borderColor = UIColor.systemGray5.cgColor
        searchController.searchBar.searchTextField.backgroundColor = .white
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
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.headerView.state = .stocks
                        self.spinnerStop()
                        self.model.isLoading = false
                        
                    }
                } else if !model.isLoading && text != model.searchText+","  {
                    DispatchQueue.main.async {
                        self.headerView.state = .search
                    }
                    model.searchText = text
                    hideLabels()
    
                    self.model.isLoading = true
                    spinnerStart(message: "Searching")
                    model.loadQuotes(symbol: text) {  [weak self] (message) in
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
                                DispatchQueue.main.async {

                                self.tableView.reloadData()
                                }
                            } else {
                                self.showError(message: error)
                            }
                        } else {
                            self.setFavoriteQuotes(quotes: self.model.searchQuotes)

                           
                          //      self.model.setFavorites(quotes: self.model.searchQuotes)
                               /* for num in 0..<self.model.myQuotes.count {
                                      if self.model.myQuotes[num].symbol == self.model.searchQuotes[num].symbol {
                                         // self.model.allQuotes[num].starStatus = self.model.searchQuotes[indexPath.row].starStatus
                                          try? RealmService.saveTicker(ticker: self.model.allQuotes[num], status: self.model.searchQuotes[indexPath.row].starStatus)
                                          //self.model.writeFavourites(index: num, status: status)
                                         // present = true
                                          break
                                      }
                                  } */
                                
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
        DispatchQueue.main.async {
            self.headerView.state = .stocks
            self.spinnerStop()
            self.model.isLoading = false
            self.tableView.reloadData()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if model.popularSearchLabels.count > 0 || model.mySearchLabels.count > 0  {
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
        if indexPath.row % 2 == 0 {
            cell.contentView.backgroundColor = .systemGray5
        }
        
        cell.starButtonCallback = { [weak self] status in
            guard let self = self else { return }
            
            
            
            switch self.headerView.state {
            case .stocks:
                print(self.headerView.state)
                try? RealmService.saveTicker(ticker: self.model.allQuotes[indexPath.row], status: status)
                self.getFavoriteQuotes()
                
            case .favourite:
                print(self.headerView.state)
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
                print(self.headerView.state)
                
                
                if let index = self.model.allQuotes.firstIndex(of: self.model.searchQuotes[indexPath.row]) {
                    try? RealmService.saveTicker(ticker: self.model.allQuotes[index], status: status)
                }
                
//                if let index = self.model.myQuotes.firstIndex(of: self.model.searchQuotes[indexPath.row]) {
//                    try? RealmService.saveTicker(ticker: self.model.myQuotes[index], status: status)
//                    self.model.myQuotes.remove(at: index)
//                }
//                
                
                try? RealmService.saveTicker(ticker: self.model.searchQuotes[indexPath.row], status: status)
                
            }
            
            
            
       /*     if !self.model.search {
                // объекты из основной таблицы, не режим поиска
                if self.headerView.state == .favourite {
                    if let index = self.model.allQuotes.firstIndex(of: self.model.myQuotes[indexPath.row]) {
                       // self.model.allQuotes[index].starStatus = status
                        try? RealmService.saveTicker(ticker: self.model.allQuotes[index], status: status)
                      //  self.model.writeFavourites(index: index, status: status)
                    }
                    self.model.myQuotes.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else if self.headerView.state == .stocks {
                    try? RealmService.saveTicker(ticker: self.model.allQuotes[indexPath.row], status: status)
                }
                
                // режим поиска
            } else {
                print(self.headerView.state)
                var present: Bool = false
                self.model.searchQuotes[indexPath.row].starStatus = status
                for num in 0..<self.model.allQuotes.count {
                    if self.model.allQuotes[num].symbol == self.model.searchQuotes[indexPath.row].symbol {
                       // self.model.allQuotes[num].starStatus = self.model.searchQuotes[indexPath.row].starStatus
                        try? RealmService.saveTicker(ticker: self.model.allQuotes[num], status: self.model.searchQuotes[indexPath.row].starStatus)
                        //self.model.writeFavourites(index: num, status: status)
                        present = true
                        break
                    }
                }
                if !present {
                    self.model.allQuotes.append(self.model.searchQuotes[indexPath.row])
                   // self.model.writeFavourites(index: indexPath.row, status: status)
                    try? RealmService.saveTicker(ticker: self.model.searchQuotes[indexPath.row], status: status)

                }
            } */
        }
        
        if !model.search {
            if self.headerView.state == .stocks {
                setCellData(cell: cell, indexPath: indexPath, quotes: model.allQuotes)
                model.stocksIndexPath = indexPath
            } else {
                setCellData(cell: cell, indexPath: indexPath, quotes: model.myQuotes)
                model.favouriteIndexPath = indexPath
            }
        } else {
            setCellData(cell: cell, indexPath: indexPath, quotes: model.searchQuotes)
            //            if model.searchQuotes.count > 0 {
            //                if !model.mySearchLabels.contains(model.searchText) {
            //                    model.mySearchLabels.append(model.searchText)
            //                    self.searchView.yoursStrings = model.mySearchLabels
            //
            //                }
            //            }
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
    
    
    
    // MARK: - Functions
    private func loadTickers(start: Int = 1, readRealm: Bool? = nil) {
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
                            DispatchQueue.main.async {
                            self.tableView.reloadData()
                            }
                            #if DEBUG
                            print("Characters load from Realm")
                            #endif
                           // self.model.setFavorites(quotes: self.model.allQuotes)
                            self.showError(message: "Дата последнего обновления базы: \(self.model.searchLabels.getFullDateString(from: self.model.searchLabels.dataDate))")
                            

                        }
                    
                }
                self.showError(message: error)


                #if DEBUG
                print("Error = ", error)
                #endif
                
            } else {
                self.setFavoriteQuotes(quotes: self.model.allQuotes)

                 
                    self.spinnerStop()
                    self.model.isLoading = false
                   // self.model.setFavorites(quotes: self.model.allQuotes)
                    
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                    try? RealmService.saveTickers(tickers: self.model.allQuotes)
                }
            
            
        }
    }
    
    
    
    func setStarStatus() {
        
    }
    
    fileprivate func getSearchLabes() {
        if let searchLabels = try? RealmService.getSearchLabels(SearchLabels.self) {
            model.searchLabels = searchLabels
//            model.popularSearchLabels = labelsAndFavourites.popularSymbols
//            model.mySearchLabels = labelsAndFavourites.yoursSymbols
//            searchView.yoursStrings = model.mySearchLabels
//            searchView.popularStrings = model.popularSearchLabels

        }
    }
    
    fileprivate func getPopularSearchLabels() {
        model.networkService.getMostWatchedLabels { result in
            switch result {
            case let .success(data):
                self.model.popularSearchLabels = data[0].popularSymbols
                self.searchView.popularStrings = self.model.popularSearchLabels
            case .failure(let error):
                self.showError(message: error.localizedDescription.split(separator: ":").last?.description ?? error.localizedDescription)
               // self.getLabesAndFavourite()
                #if DEBUG
                print(error.localizedDescription.split(separator: ":").last as Any)
                #endif
            }
        }
    }
    
    fileprivate func setCellData(cell: StockTableViewCell, indexPath: IndexPath, quotes: [Quote]) {
        
        if indexPath.row < quotes.count {
            cell.symbolLabel.text = quotes[indexPath.row].symbol
            cell.companyLabel.text = quotes[indexPath.row].getCompanyName()
            cell.priceLabel.text = quotes[indexPath.row].getPrice()
            cell.dayPriceChangeLabel.text = quotes[indexPath.row].getCoeff()
            cell.dayPriceChangeLabel.textColor = quotes[indexPath.row].coeffColor
            cell.starButtonStatus = quotes[indexPath.row].starStatus
            cell.logoImageView.kf.setImage(with: URL(string: quotes[indexPath.row].logoStr))
        }
    }
    
    fileprivate func spinnerStart(message: String) {
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
    
    fileprivate func spinnerStop() {
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
    
    fileprivate func showError(message: String) {
        DispatchQueue.main.async {
            guard let navcontroller = self.navigationController?.view else { return }
            let errorMessage = ErrorMessage(view: navcontroller)
            errorMessage.showError(reverse: true, message: message, delay: 2.0)
        }
    }
    
    fileprivate func hideLabels() {
        if self.model.labelsDidShow {
            UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: { [weak self] in
                guard let self = self else { return }
                self.searchView.removeFromSuperview()
            }, completion: { _ in self.model.labelsDidShow.toggle() })
        }
    }
    
    fileprivate func showLabels(popularStrings: Int, yoursStrings: Int) {
        if !self.model.labelsDidShow && (popularStrings > 0 ||  yoursStrings > 0 ) {
            UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: { [weak self] in
                guard let self = self else { return }
                self.view.addSubview(self.searchView)
                self.view.bringSubviewToFront(self.searchView)
            }, completion: { _ in self.model.labelsDidShow.toggle() })
        }
    }
    
    func message() {
        let message = "Ребята, когда я подавал заявку в первый раз, мне пришло только алгоритмическое задание. Я сделал несколько задач, всего было 6 заданий на 6 часов и думал на этом тест закончен. Об этой второй части я случайно узнал только, когда смотрел эфир Яндекс школы на youtube, времени было очень мало, поэтому сделал только первичный функционал на сколько успел. О том, что успел: API не позволяет выполнять поиск по первым буквам и выдавать список тикером, поэтому такая возможность у меня есть только в оффлайн режиме, в API так же нет возможности получить логотипы компаний, поэтому для получения лого я использовал внешний сервис. Спасибо за внимание!"
        let alert = UIAlertController(title: "Привет!", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "лады", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
}


//func loadFavouriteTickers() {
//
//    print(model.labelsAndFavourites.favourites)
//    print(model.allQuotes.count)
//    model.myQuotes.removeAll()
//    for ticker in model.labelsAndFavourites.favourites {
//        if let quote = try? RealmService.getTicker(Quote.self, key: ticker) {
//            quote.starStatus = true
//            if !model.myQuotes.contains(quote) {
//                model.myQuotes.append(quote)
//            }
//        }
//    }
//}
