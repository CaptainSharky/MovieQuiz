import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    // Количество вопросов
    private let questionsAmount: Int = 10
    // Хранение статистики
    private let statisticService: StatisticServiceProtocol?
    // Индекс текущего вопроса
    private var currentQuestionIndex: Int = 0
    // Вопрос для пользователя
    private var currentQuestion: QuizQuestion?
    // Кол-во правильных ответов
    private var correctAnswers: Int = 0
    // Фабрика вопросов
    private var questionFactory: QuestionFactoryProtocol?
    // Controller
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    init(viewController: MovieQuizViewControllerProtocol?) {
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
    
    // MARK: - Public functions
    // Попробовать загрузить снова
    func tryLoadAgain() {
        questionFactory?.loadData()
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
        
        proceedWithAnswer(isCorrect: truth)
    }
    
    // Конвертация вопроса в view model
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    // MARK: - Private functions
    // Рестартнуть игры
    private func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    // Последний вопрос или нет
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    // Показ ответа + переход к след вопросу
    private func proceedWithAnswer(isCorrect: Bool) {
        // Рисуем рамку
        viewController?.drawBorder(isCorrect)
        
        // Задержка 1 секунда перед след. вопросом
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    // Увеличить счётчик вопросов
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    // Проверка окончания раунда || следующий вопрос
    private func proceedToNextQuestionOrResults() {
        // Завершаем раунд если кончились вопросы
        if isLastQuestion() {
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
            switchToNextQuestion()
            
            // Показываем следующий вопрос
            questionFactory?.requestNextQuestion()
        }
    }
}
