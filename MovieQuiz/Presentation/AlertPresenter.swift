import UIKit

class AlertPresenter: AlertPresenterProtocol {
    weak var delegate: AlertPresenterDelegate?
    
    func showAlert(model: AlertModel) {
        // Алерт
        let alert = UIAlertController(title: model.title,
                                        message: model.message,
                                        preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "Game results"
        
        // Кнопка действия
        let action = UIAlertAction(title: model.buttonText,
                                   style: .default) { _ in
            model.completion()
        }
        
        // Отправляем алерт в контроллер
        delegate?.didReceiveAlert(alert: alert, action: action)
    }
}
