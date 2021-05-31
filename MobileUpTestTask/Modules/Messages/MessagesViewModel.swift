//
//  MessagesViewModel.swift
//  MobileUpTestTask
//
//  Created by Даниил Апальков on 30.05.2021.
//

import UIKit
import RxSwift
import RxCocoa


struct MessagesViewModelInput {
    var fetchData: BehaviorRelay<Void>
}

struct MessagesViewModelOutput {
    var refreshTableView: Driver<[MessageModel]?>
    var isLoading: BehaviorRelay<Bool>
}

protocol MessagesViewModelProtocol {
    var input: MessagesViewModelInput { get }
    var output: MessagesViewModelOutput { get }
    var service: MessageServiceProtocol { get }
}

class MessagesViewModel: MessagesViewModelProtocol {
    
    var input: MessagesViewModelInput
    var output: MessagesViewModelOutput
    var service: MessageServiceProtocol
    
    private let fetchData = BehaviorRelay<Void>(value: ())
    private let refreshTableView = BehaviorRelay<[MessageModel]?>(value: nil)
    private let isLoading = BehaviorRelay<Bool>(value: false)
    private let bag = DisposeBag()
    
    init() {
        input = MessagesViewModelInput(fetchData: fetchData)
        output = MessagesViewModelOutput(refreshTableView: refreshTableView.asDriver(), isLoading: isLoading)
        service = MessageService()
        fetchData.bind(to: fetchDataBinder()).disposed(by: bag)
    }
    
    //MARK: - Binders
    private func fetchDataBinder() -> Binder<Void> {
        Binder(self) { vm, _ in
            vm.isLoading.accept(true)
            vm.service
                .fetchMessages()
                .map({ vm.isLoading.accept(false); return $0 ?? [] })
                .bind(to: vm.refreshTableView)
                .disposed(by: vm.bag)
        }
    }
}
