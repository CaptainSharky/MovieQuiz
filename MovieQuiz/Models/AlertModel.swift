import Foundation

// Данные для отображения в алерт
struct AlertModel {
    // текст заголовка
    let title: String
    // текст сообщения
    let message: String
    // текст для кнопки
    let buttonText: String
    // замыкание для действия по кнопке
    let completion: () -> Void
}
