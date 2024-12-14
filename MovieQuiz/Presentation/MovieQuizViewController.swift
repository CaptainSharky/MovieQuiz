import UIKit

final class MovieQuizViewController: UIViewController {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction private func yesButton(_ sender: Any) {
        
    }
    
    @IBAction private func noButton(_ sender: Any) {
        
    }
    
}

struct QuizQuestion {
    let image: String
    let text: String
    let correctAnswer: Bool
}

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


/*
 Mock-данные
 
 
 Картинка:
 Настоящий рейтинг: 9,2
 Вопрос:
 Ответ: ДА
 
 
 Картинка:
 Настоящий рейтинг: 9
 Вопрос:
 Ответ: ДА
 
 
 Картинка:
 Настоящий рейтинг: 8,1
 Вопрос:
 Ответ: ДА
 
 
 Картинка:
 Настоящий рейтинг: 8
 Вопрос:
 Ответ: ДА
 
 
 Картинка:
 Настоящий рейтинг: 8
 Вопрос:
 Ответ: ДА
 
 
 Картинка:
 Настоящий рейтинг: 6,6
 Вопрос:
 Ответ: ДА
 
 
 Картинка:
 Настоящий рейтинг: 5,8
 Вопрос:
 Ответ: НЕТ
 
 
 Картинка:
 Настоящий рейтинг: 4,3
 Вопрос:
 Ответ: НЕТ
 
 
 Картинка:
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка:
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
*/
