//
//  MessageService.swift
//  MobileUpTestTask
//
//  Created by Даниил Апальков on 30.05.2021.
//

import Foundation
import RxSwift
import RxCocoa

protocol MessageServiceProtocol {
    func fetchMessages() -> Observable<[MessageModel]?>
}

class MessageService: MessageServiceProtocol {
    //MARK: - Properties
    let bag = DisposeBag()
    private let result = BehaviorRelay<[MessageModel]?>(value: nil)

    func fetchMessages() -> Observable<[MessageModel]?> {
        guard let url = URL(string: "https://s3-eu-west-1.amazonaws.com/builds.getmobileup.com/storage/MobileUp-Test/api.json") else { return result.asObservable() }

        URLSession.shared.rx
            .response(request: URLRequest(url: url))
            .bind(to: fetchBinder())
            .disposed(by: bag)
        
        return result.skip(1)
    }
    
    func formateDate(_ isoDate: String) -> String? {
        let dateFormatter = ISO8601DateFormatter()
        let calendar = Calendar.current
        if let date = dateFormatter.date(from: isoDate) {
            if calendar.isDateInToday(date) {
                return "\(calendar.get(.hour, from: date)):\(calendar.get(.minute, from: date))"
            } else if Calendar.current.isDateInYesterday(date) {
                return "Yesterday"
            } else if Calendar.current.isDayInCurrentWeek(date) ?? false {
                return DateFormatter().weekdaySymbols[calendar.get(.weekday, from: date)]
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd.MM.yyyy"
                return formatter.string(from: date)
            }
        }
        return nil
    }
    
    //MARK: - Binders
    private func fetchBinder() -> Binder<(response: HTTPURLResponse, data: Data)> {
        Binder(self) { service, input in
            guard input.response.statusCode < 400 else {
                AlertManager.showCloseActionAlert(title: "No connection to server.", message: "Please, try again later.")
                return
            }
            guard let model = try? JSONDecoder().decode([MessageResponceModel].self, from: input.data) else { return }
            if model.isEmpty { service.result.accept([]); return }
            
            var users = [MessageModel]()
            let group = DispatchGroup()
            
            DispatchQueue.global(qos: .userInitiated).async {
                model.enumerated().forEach { index, user in
                    group.enter()
                    guard var image = UIImage(named: "Default Profile Icon") else { fatalError("Wrong default image name") }
                    if let stringURL = user.user.avatar_url,
                       let url = URL(string: stringURL),
                       let data = try? Data(contentsOf: url),
                       let img = UIImage(data: data) {
                            image = img
                    }
                    group.leave()
                    group.notify(queue: .main) {
                        users += [MessageModel(name: user.user.nickname,
                                               icon: image,
                                               lastMessage: user.message.text,
                                               date: service.formateDate(user.message.receiving_date) ?? "")]
                        
                        if index == model.count - 1 {
                            service.result.accept(users)
                        }
                    }
                }
            }
        }
    }
}
