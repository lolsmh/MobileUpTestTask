//
//  MessagesModel.swift
//  MobileUpTestTask
//
//  Created by Даниил Апальков on 30.05.2021.
//

import UIKit

struct MessageResponceModel: Codable {
    let user: User
    let message: Message
    
    struct User: Codable {
        let nickname: String
        let avatar_url: String?
    }

    struct Message: Codable {
        let text: String
        let receiving_date: String
    }
}

struct MessageModel {
    let name: String
    let icon: UIImage
    let lastMessage: String
    let date: String
}
