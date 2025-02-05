import UIKit

final class MovieQuizPresenter {
    // Количество вопросов
    let questionsAmount: Int = 10
    // Индекс текущего вопроса
    private var currentQuestionIndex: Int = 0
    // Вопрос для пользователя
    var currentQuestion: QuizQuestion?
    // Controller
    weak var viewController: MovieQuizViewController?
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
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
        
        viewController?.showAnswerResult(isCorrect: answer == currentQuestion.correctAnswer)
    }
}
