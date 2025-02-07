import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    // Количество вопросов
    let questionsAmount: Int = 10
    // Индекс текущего вопроса
    private var currentQuestionIndex: Int = 0
    // Вопрос для пользователя
    var currentQuestion: QuizQuestion?
    // Controller
    private weak var viewController: MovieQuizViewController?
    // Кол-во правильных ответов
    var correctAnswers: Int = 0
    // Фабрика вопросов
    private var questionFactory: QuestionFactoryProtocol?
    // Хранение статистики
    private let statisticService: StatisticServiceProtocol!
    
    init(viewController: MovieQuizViewController?) {
        self.viewController = viewController
        
        // Инициализация хранителя статистики
        statisticService = StatisticService()
        // Инициализация фабрики вопросов
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        // Включаем индикатор загрузки
        viewController?.showLoadingIndicator()
        // Загружаем данные
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    // Получили модель вопроса
    // Получили модель вопроса
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        // Отображение полученного вопроса
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    func didFailToLoadPoster() {
        viewController?.showNetworkError(message: "Не удалось загрузить постер фильма")
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    // Конвертация из mock в view model
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    // Обработать ответ кнопки
    func handleAnswer(_ answer: Bool) {
        // Выключаем кнопки
        viewController?.switchButtonMode(to: false)
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let truth = answer == currentQuestion.correctAnswer
        if truth { correctAnswers += 1}
        
        viewController?.showAnswerResult(isCorrect: truth)
    }
    
    // Проверка окончания раунда || следующий вопрос
    func showNextQuestionOrResult() {
        // Завершаем раунд если кончились вопросы
        if self.isLastQuestion() {
            guard let statisticService = statisticService else { return }
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
                    self.restartGame()
                }
            
            // Делегируем показ алерта в презентер
            viewController?.alertPresenter?.showAlert(model: alertModel)
            
        } else { // Иначе продолжаем раунд
            self.switchToNextQuestion()
            
            // Показываем следующий вопрос
            questionFactory?.requestNextQuestion()
        }
    }
}
