import Foundation

final class StatisticService: StatisticServiceProtocol {
    // Сокращение UserDefaults.standard в storage
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        // Текущие результаты
        case correct
        case total
        case date
        // Сохраненные данные
        case bestGame
        case gamesCount
        case correctAnswers
    }
    
    // Всего квизов сыграно
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    // Рекорд результата по кол-ву правильных ответов
    var bestGame: GameResult {
        get {
            GameResult(correct: storage.integer(forKey: Keys.correct.rawValue),
                       total: storage.integer(forKey: Keys.total.rawValue),
                       date: storage.object(forKey: Keys.date.rawValue) as? Date ?? Date())
        }
        set {
            storage.set(newValue.correct, forKey: Keys.correct.rawValue)
            storage.set(newValue.total, forKey: Keys.total.rawValue)
            storage.set(newValue.date, forKey: Keys.date.rawValue)
        }
    }
    
    // Средняя точность
    var totalAccuracy: Double {
        if gamesCount == 0 { return 0 }
        
        return Double(correctAnswers) / Double(10 * gamesCount) * 100
    }
    
    // Кол-во правильных ответов за все квизы
    private var correctAnswers: Int {
        get {
            storage.integer(forKey: Keys.correctAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.correctAnswers.rawValue)
        }
    }
    
    // Сохранить текущий результат
    func store(current result: GameResult) {
        gamesCount += 1
        correctAnswers += result.correct
        
        if result.isBetterThan(bestGame) { bestGame = result }
    }
    
    // Получить статистику в алерт
    func getStatistics() -> String {
        var text = "Количество сыгранных квизов: \(gamesCount)\n"
        text += "Рекорд: \(bestGame.correct)/\(bestGame.total) \(bestGame.date.dateTimeString)\n"
        text += "Средняя точность: \(String(format: "%.2f", totalAccuracy))%"
        
        return text
    }
}
