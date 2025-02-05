import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    @IBOutlet private weak var imageView: UIImageView! // Постер
    @IBOutlet private weak var textLabel: UILabel!     // Вопрос
    @IBOutlet private weak var counterLabel: UILabel!  // Счётчик
    @IBOutlet private weak var yesButton: UIButton!    // Кнопка "Да"
    @IBOutlet private weak var noButton: UIButton!     // Кнопка "Нет"
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView! // Индикатор загрузки
    // Кол-во правильных ответов
    private var correctAnswers: Int = 0
    // Фабрика вопросов
    private var questionFactory: QuestionFactoryProtocol?
    // Экран алерта
    private var alertPresenter: AlertPresenterProtocol?
    // Хранение статистики
    private var statisticService: StatisticServiceProtocol?
    // Presenter
    private let presenter = MovieQuizPresenter()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewController = self
        
        // Делегирование в фабрику вопросов
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        // Загружаем данные
        showLoadingIndicator()
        questionFactory?.loadData()
        
        // Делегирование в экран алерта
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter
        
        // Инициализация хранителя статистики
        statisticService = StatisticService()
    }
    
    // MARK: - QuestionFactoryDelegate
    // Получили модель вопроса
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        presenter.currentQuestion = question
        let viewModel = presenter.convert(model: question)
        
        // Отображение полученного вопроса
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didFailToLoadPoster() {
        showNetworkError(message: "Не удалось загрузить постер фильма")
    }
    
    // MARK: - AlertPresenterDelegate
    // Отображение алерта
    func didReceiveAlert(alert: UIAlertController, action: UIAlertAction) {
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    // MARK: - Public functions
    // Отрисовка ответа + переход
    func showAnswerResult(isCorrect: Bool) {
        // Рисуем рамку
        drawBorder(isCorrect)
        
        if isCorrect { correctAnswers += 1}
        
        // Задержка 1 секунда перед след. вопросом
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResult()
        }
    }
    
    // Вкл/выкл кнопок
    func switchButtonMode(to mode: Bool) {
        yesButton.isEnabled = mode
        noButton.isEnabled = mode
    }
    
    // MARK: - Private functions
    // Отображение индикатора загрузки
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    // Выключение индикатора загрузки
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    // Отобразить алерт сетевой ошибки
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз"
        ) { [weak self] in
            guard let self = self else { return }
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            
            self.questionFactory?.loadData()
        }
        
        alertPresenter?.showAlert(model: alertModel)
    }
    
    // Отобразить вопрос
    private func show(quiz step: QuizStepViewModel) {
        // Сбрасываем рамку предыдущего ответа
        resetAnswerBorder()
        // Включаем кнопки
        switchButtonMode(to: true)
        
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // Сбросить рамку ответа
    private func resetAnswerBorder() {
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    // Проверка окончания раунда || следующий вопрос
    private func showNextQuestionOrResult() {
        // Завершаем раунд если кончились вопросы
        if presenter.isLastQuestion() {
            guard let statisticService else { return }
            // Модель результата текущей игры
            let result = GameResult(correct: correctAnswers,
                                    total: presenter.questionsAmount,
                                    date: Date())
            // Сохраняем данные
            statisticService.store(current: result)
            
            // Получаем текст статистики
            let text = "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)\n" + statisticService.getStatistics()
            
            // Модель алерта
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть ещё раз"
            ) { [weak self] in
                    guard let self = self else { return }
                    self.presenter.resetQuestionIndex()
                    self.correctAnswers = 0
                    self.questionFactory?.requestNextQuestion()
                }
            
            // Делегируем показ алерта в презентер
            alertPresenter?.showAlert(model: alertModel)
            
        } else { // Иначе продолжаем раунд
            presenter.switchToNextQuestion()
            
            // Показываем следующий вопрос
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    // Нарисовать рамку-ответ
    private func drawBorder(_ isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    // MARK: - Actions
    // Нажал "Да"
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.handleAnswer(true)
    }
    
    // Нажал "Нет"
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.handleAnswer(false)
    }
}
