import Foundation
import XCTest
@testable import MovieQuiz

final class ArrayTests: XCTestCase {
    // Успешное взятие элемента по индексу
    func testGetValueInRange() throws {
        // Given
        let array = [1, 1, 2, 3, 5]
        // When
        let value = array[safe: 2]
        // Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    // Взятие элемента по неправильному индексу
    func testGetValueOutOfRange() throws {
        // Given
        let array = [1, 1, 2, 3, 5]
        // When
        let value = array[safe: 20]
        // Then
        XCTAssertNil(value)
    }
}


