import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol, AlertPresenterDelegate {
    @IBOutlet private weak var imageView: UIImageView! // Постер
    @IBOutlet private weak var textLabel: UILabel!     // Вопрос
    @IBOutlet private weak var counterLabel: UILabel!  // Счётчик
    @IBOutlet private weak var yesButton: UIButton!    // Кнопка "Да"
    @IBOutlet private weak var noButton: UIButton!     // Кнопка "Нет"
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView! // Индикатор загрузки
    private var presenter: MovieQuizPresenter?  // Presenter
    var alertPresenter: AlertPresenterProtocol? // Экран алерта
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        
        // Делегирование в алерт
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter
    }
    
    // MARK: - AlertPresenterDelegate
    // Отображение алерта
    func didReceiveAlert(alert: UIAlertController, action: UIAlertAction) {
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    // MARK: - Public functions
    // Вкл/выкл кнопок
    func switchButtonMode(to mode: Bool) {
        yesButton.isEnabled = mode
        noButton.isEnabled = mode
    }
    
    // Отобразить вопрос
    func show(quiz step: QuizStepViewModel) {
        // Сбрасываем рамку предыдущего ответа
        resetAnswerBorder()
        // Включаем кнопки
        switchButtonMode(to: true)
        
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // Отображение индикатора загрузки
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    // Выключение индикатора загрузки
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    // Отобразить алерт сетевой ошибки
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз"
        ) { [weak self] in
            guard let self = self else { return }
            self.presenter?.tryLoadAgain()
        }
        
        alertPresenter?.showAlert(model: alertModel)
    }
    
    // Нарисовать рамку-ответ
    func drawBorder(_ isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    // MARK: - Private functions
    // Сбросить рамку ответа
    private func resetAnswerBorder() {
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    // MARK: - Actions
    // Нажал "Да"
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter?.handleAnswer(true)
    }
    
    // Нажал "Нет"
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter?.handleAnswer(false)
    }
}
