import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    @IBOutlet private weak var imageView: UIImageView! // Постер
    @IBOutlet private weak var textLabel: UILabel!     // Вопрос
    @IBOutlet private weak var counterLabel: UILabel!  // Счётчик
    @IBOutlet private weak var yesButton: UIButton!    // Кнопка "Да"
    @IBOutlet private weak var noButton: UIButton!     // Кнопка "Нет"
    
    // Индекс текущего вопроса
    private var currentQuestionIndex: Int = 0
    // Кол-во правильных ответов
    private var correctAnswers: Int = 0
    // Количество вопросов
    private let questionsAmount: Int = 10
    // Фабрика вопросов
    private var questionFactory: QuestionFactoryProtocol?
    // Вопрос для пользователя
    private var currentQuestion: QuizQuestion?
    // Экран алерта
    private var alertPresenter: AlertPresenterProtocol?
    // Хранение статистики
    private var statisticService: StatisticServiceProtocol?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Делегирование в фабрику вопросов
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        
        // Отображение 1 вопроса при запуске
        questionFactory.requestNextQuestion()
        
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
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        // Отображение полученного вопроса
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - AlertPresenterDelegate
    // Отображение алерта
    func didReceiveAlert(alert: UIAlertController, action: UIAlertAction) {
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    // MARK: - Private functions
    // Конвертация из mock в view model
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    // Вкл/выкл кнопок
    private func switchButtonMode(to mode: Bool) {
        yesButton.isEnabled = mode
        noButton.isEnabled = mode
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
        if currentQuestionIndex == questionsAmount - 1 {
            guard let statisticService else { return }
            // Модель результата текущей игры
            let result = GameResult(correct: correctAnswers,
                                    total: questionsAmount,
                                    date: Date())
            // Сохраняем данные
            statisticService.store(current: result)
            
            // Получаем текст статистики
            let text = "Ваш результат: \(correctAnswers)/\(questionsAmount)\n" + statisticService.getStatistics()
            
            // Модель алерта
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть ещё раз"
            ) { [weak self] in
                    guard let self = self else { return }
                    self.currentQuestionIndex = 0
                    self.correctAnswers = 0
                    self.questionFactory?.requestNextQuestion()
                }
            
            // Делегируем показ алерта в презентер
            alertPresenter?.showAlert(model: alertModel)
            
        } else { // Иначе продолжаем раунд
            currentQuestionIndex += 1
            
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
    
    // Отрисовка ответа + переход
    private func showAnswerResult(isCorrect: Bool) {
        // Рисуем рамку
        drawBorder(isCorrect)
        
        if isCorrect { correctAnswers += 1}
        
        // Задержка 1 секунда перед след. вопросом
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResult()
        }
    }
    
    // Обработать ответ
    private func handleAnswer(_ answer: Bool) {
        // Выключаем кнопки
        switchButtonMode(to: false)
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        showAnswerResult(isCorrect: answer == currentQuestion.correctAnswer)
    }
    
    // MARK: - Actions
    // Нажал "Да"
    @IBAction private func yesButtonClicked(_ sender: Any) {
        handleAnswer(true)
    }
    
    // Нажал "Нет"
    @IBAction private func noButtonClicked(_ sender: Any) {
        handleAnswer(false)
    }
}
