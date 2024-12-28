import UIKit

final class MovieQuizViewController: UIViewController {
    @IBOutlet private weak var imageView: UIImageView! // Постер
    @IBOutlet private weak var textLabel: UILabel!     // Вопрос
    @IBOutlet private weak var counterLabel: UILabel!  // Счётчик
    @IBOutlet weak var yesButton: UIButton! // Кнопка "Да"
    @IBOutlet weak var noButton: UIButton!  // Кнопка "Нет"
    
    // Индекс текущего вопроса
    private var currentQuestionIndex: Int = 0
    // Кол-во правильных ответов
    private var correctAnswers: Int = 0
    // Количество вопросов
    private let questionsAmount: Int = 10
    // Фабрика вопросов
    private var questionFactory: QuestionFactory = QuestionFactory()
    // Вопрос для пользователя
    private var currentQuestion: QuizQuestion?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Отображение 1 вопроса при запуске
        if let firstQuestion = questionFactory.requestNextQuestion() {
            currentQuestion = firstQuestion
            let viewModel = convert(model: firstQuestion)
            show(quiz: viewModel)
        }
    }
    
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
    
    // Отобразить алерт результатов
    private func show(quiz result: QuizResultsViewModel) {
        // Алерт
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        // Действие
        let action = UIAlertAction(
            title: result.buttonText,
            style: .default) { [weak self] _ in // слабая ссылка на self
                guard let self = self else { return }
                
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                
                if let firstQuestion = self.questionFactory.requestNextQuestion() {
                    self.currentQuestion = firstQuestion
                    let viewModel = self.convert(model: firstQuestion)
                    
                    self.show(quiz: viewModel)
                }
            }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Сбросить рамку ответа
    private func resetAnswerBorder() {
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    // Проверка окончания раунда || следующий вопрос
    private func showNextQuestionOrResult() {
        if currentQuestionIndex == questionsAmount - 1 {
            let text = correctAnswers == questionsAmount ?
            "Поздравляем, вы ответили на 10 из 10!" :
            "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
//            let text = "Ваш результат: \(correctAnswers)/10"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            
            if let nextQuestion = questionFactory.requestNextQuestion() {
                currentQuestion = nextQuestion
                let viewModel = convert(model: nextQuestion)
                
                // Показываем текущий вопрос
                show(quiz: viewModel)
            }
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
    
    // Нажал "Да"
    @IBAction private func yesButtonClicked(_ sender: Any) {
        handleAnswer(true)
    }
    
    // Нажал "Нет"
    @IBAction private func noButtonClicked(_ sender: Any) {
        handleAnswer(false)
    }
}
