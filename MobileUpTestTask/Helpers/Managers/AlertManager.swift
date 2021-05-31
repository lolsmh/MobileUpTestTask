//
//  AlertManager.swift
//  MobileUpTestTask
//
//  Created by Даниил Апальков on 30.05.2021.
//

import UIKit
import RxSwift

class AlertManager {
    @discardableResult
    class func showCloseActionAlert(title: String? = nil, message: String? = nil, closeTitle: String = "Close") -> Observable<Void> {
        let result = PublishSubject<Void>()
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let close = UIAlertAction(title: closeTitle, style: .cancel) { (_) in
            result.onCompleted()
        }
        alertVC.addAction(close)
        show(alertVC)
        return result
    }
    
    private class func show(_ alert: UIViewController) {
        if var controller = UIApplication.shared.windows[0].rootViewController {
            while let presentedViewController = controller.presentedViewController {
                controller = presentedViewController
            }
            if !(controller is UIAlertController) {
                if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
                    if let popoverController = alert.popoverPresentationController {
                        popoverController.sourceView = controller.view
                        popoverController.sourceRect = CGRect(x: controller.view.bounds.midX, y: controller.view.bounds.maxY, width: 0, height: 0)
                        popoverController.permittedArrowDirections = []
                    }
                }
                controller.present(alert,
                                   animated: true,
                                   completion: nil)
            }
        }
    }
}
