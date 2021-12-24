import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
final class CanvasTests: XCTestCase {
    
    func testEnclosedView() throws {
        let sut = Canvas(renderer: { _, _ in }, symbols: { Spacer() })
        XCTAssertNoThrow(try sut.inspect().canvas().symbolsView().spacer())
    }
    
    func testResetsModifiers() throws {
        let sut = Canvas(renderer: { _, _ in }, symbols: { Spacer() }).padding()
        let view = try sut.inspect().canvas().symbolsView().spacer()
        XCTAssertEqual(view.content.medium.viewModifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = Button(action: { }, label: { Canvas(renderer: { _, _ in }) })
        XCTAssertNoThrow(try view.inspect().button().labelView().canvas())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            Canvas(renderer: { _, _ in })
            Canvas(renderer: { _, _ in })
        }
        XCTAssertNoThrow(try view.inspect().hStack().canvas(0))
        XCTAssertNoThrow(try view.inspect().hStack().canvas(1))
    }
    
    func testSearch() throws {
        let sut = try AnyView(Canvas(renderer: { _, _ in }, symbols: { Spacer() })).inspect()
        XCTAssertEqual(try sut.find(ViewType.Spacer.self).pathToRoot,
            "anyView().canvas().symbolsView().spacer()")
    }
    
    func testColorMode() throws {
        let sut1 = Canvas(colorMode: .extendedLinear, renderer: { _, _ in })
        XCTAssertEqual(try sut1.inspect().canvas().colorMode(), .extendedLinear)
        let sut2 = Canvas(colorMode: .nonLinear, renderer: { _, _ in })
        XCTAssertEqual(try sut2.inspect().canvas().colorMode(), .nonLinear)
    }
    
    func testOpaque() throws {
        let sut1 = Canvas(opaque: true, renderer: { _, _ in })
        XCTAssertTrue(try sut1.inspect().canvas().opaque())
        let sut2 = Canvas(opaque: false, renderer: { _, _ in })
        XCTAssertFalse(try sut2.inspect().canvas().opaque())
    }
    
    func testRendersAsynchronously() throws {
        let sut1 = Canvas(rendersAsynchronously: true, renderer: { _, _ in })
        XCTAssertTrue(try sut1.inspect().canvas().rendersAsynchronously())
        let sut2 = Canvas(rendersAsynchronously: false, renderer: { _, _ in })
        XCTAssertFalse(try sut2.inspect().canvas().rendersAsynchronously())
    }
}
