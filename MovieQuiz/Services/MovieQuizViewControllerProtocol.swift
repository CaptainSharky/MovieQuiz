protocol MovieQuizViewControllerProtocol: AnyObject {
    var alertPresenter: AlertPresenterProtocol? { get set }
    
    func show(quiz step: QuizStepViewModel)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func drawBorder(_ isCorrect: Bool)
    func switchButtonMode(to mode: Bool)
    
    func showNetworkError(message: String)
}
