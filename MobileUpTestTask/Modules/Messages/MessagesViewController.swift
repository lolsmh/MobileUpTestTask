//
//  ViewController.swift
//  MobileUpTestTask
//
//  Created by Даниил Апальков on 30.05.2021.
//

import UIKit
import RxSwift
import RxCocoa

class MessagesViewController: UIViewController {
    //MARK: - Outltes
    @IBOutlet weak var messagesTableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    //MARK: - Views
    private let refreshControl = UIRefreshControl()
    
    //MARK: - Properties
    private let bag = DisposeBag()
    private var viewModel: MessagesViewModelProtocol!
    private var messages = [MessageModel]()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkConnection()
        configure()
        configureMessagesTableView()
        bindViewModel()
        bindRefreshControl()
    }
    
    //MARK: - Configuration
    private func configure() {
        title = "Messages"
        navigationController?.navigationBar.prefersLargeTitles = true
        viewModel = MessagesViewModel()
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemGray6
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func configureMessagesTableView() {
        messagesTableView.register(UINib(nibName: "MessagesTVC", bundle: nil), forCellReuseIdentifier: MessagesTVC.id)
        messagesTableView.refreshControl = refreshControl
        messagesTableView.dataSource = self
        messagesTableView.delegate = self
    }
    
    //MARK: - Binding
    private func bindViewModel() {
        viewModel.output.refreshTableView.drive { messages in
            guard let messages = messages else { return }
            self.viewModel.output.isLoading.accept(false)
            self.messages = messages
            self.refreshControl.endRefreshing()
            self.messagesTableView.reloadData()
        }.disposed(by: bag)
        
        viewModel.output.isLoading.bind { showIndicator in
            if !self.refreshControl.isRefreshing {
                self.loadingIndicator.isHidden = !showIndicator
                self.messagesTableView.isHidden = showIndicator
                if showIndicator {
                    self.loadingIndicator.startAnimating()
                } else {
                    self.loadingIndicator.stopAnimating()
                }
            }
        }.disposed(by: bag)
    }
    
    private func bindRefreshControl() {
        refreshControl.rx
            .controlEvent(.valueChanged)
            .filter { _ in self.refreshControl.isRefreshing }
            .bind(to: viewModel.input.fetchData)
            .disposed(by: bag)
    }
    
    private func checkConnection() {
        if !ConnectionCheckManager.isConnectedToNetwork() {
            AlertManager.showCloseActionAlert(title: "No internet connection")
        }
    }
}

//MARK: - Data Source
extension MessagesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if messages.count > 0 {
            tableView.separatorStyle = .singleLine
            tableView.backgroundView = nil
        } else {
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: messagesTableView.bounds.size.height))
            noDataLabel.text          = "Nothing found"
            noDataLabel.textColor     = UIColor.gray
            noDataLabel.textAlignment = .center
            messagesTableView.backgroundView  = noDataLabel
            messagesTableView.separatorStyle  = .none
        }
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessagesTVC.id, for: indexPath) as? MessagesTVC else { return UITableViewCell() }
        let info = messages[indexPath.row]
        cell.userNameLabel.text = info.name
        cell.lastMessageLabel.text = info.lastMessage
        cell.iconImageView.image = info.icon
        cell.dateLabel.text = info.date
        return cell
    }
}

//MARK: - Table View Delegate
extension MessagesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 80 }
}
