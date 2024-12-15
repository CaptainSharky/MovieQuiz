import UIKit

final class MovieQuizViewController: UIViewController {
    @IBOutlet private weak var imageView: UIImageView! // Постер
    @IBOutlet private weak var textLabel: UILabel!     // Вопрос
    @IBOutlet private weak var counterLabel: UILabel!  // Счётчик
    
    // Индекс текущего вопроса
    private var currentQuestionIndex: Int = 0
    // Кол-во правильных ответов
    private var correctAnswers: Int = 0
    // Mock вопросы
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Отображение 1 вопроса при запуске
        let currentQuestion = questions[currentQuestionIndex]
        let currentQuestionViewModel = convert(model: currentQuestion)
        
        show(quiz: currentQuestionViewModel)
    }
    
    // Конвертация из mock в view model
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
    }
    
    // Отобразить вопрос
    private func show(quiz step: QuizStepViewModel) {
        // Сбрасываем рамку предыдущего ответа
        resetAnswerBorder()
        
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
            style: .default) { _ in
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                
                let firstQuestion = self.questions[self.currentQuestionIndex]
                let viewModel = self.convert(model: firstQuestion)
                self.show(quiz: viewModel)
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
        if currentQuestionIndex == questions.count - 1 {
            let text = "Ваш результат: \(correctAnswers)/10"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            
            // Показываем текущий вопрос
            show(quiz: viewModel)
        }
    }
    
    // Отрисовка ответа + переход
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        if isCorrect { correctAnswers += 1}
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResult()
        }
    }
    
    private func handleAnswer(_ answer: Bool) {
        let currentQuestion = questions[currentQuestionIndex]
        
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

// Mock вопрос
private struct QuizQuestion {
    let image: String
    let text: String
    let correctAnswer: Bool
}

// Вью вопроса
private struct QuizStepViewModel {
    let image: UIImage
    let question: String
    let questionNumber: String
}

// Вью результатов
private struct QuizResultsViewModel {
    let title: String
    let text: String
    let buttonText: String
}
