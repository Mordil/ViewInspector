import XCTest
import Combine
import SwiftUI

@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct Test {
    struct InnerView: View, Inspectable {
        var body: some View {
            Button(action: { }, label: {
                HStack { Text("Btn") }
            }).mask(Group {
                Text("Test")
            })
        }
    }
    struct MainView: View, Inspectable {
        var body: some View {
            AnyView(Group {
                EmptyView()
                    .padding()
                    .overlay(HStack {
                        EmptyView()
                            .id("5")
                        InnerView()
                            .padding(15)
                            .tag(9)
                    })
                Text("123")
                    .font(.footnote)
                    .tag(4)
                    .id(7)
                    .background(Button("xyz", action: { }))
               })
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ViewSearchTests: XCTestCase {
    
    func testFindAll() throws {
        let testView = Test.MainView()
        XCTAssertEqual(try testView.inspect().findAll(ViewType.ZStack.self).count, 0)
        XCTAssertEqual(try testView.inspect().findAll(ViewType.HStack.self).count, 2)
        XCTAssertEqual(try testView.inspect().findAll(ViewType.Button.self).count, 2)
        XCTAssertEqual(try testView.inspect().findAll(ViewType.Text.self).map({ try $0.string() }),
                       ["Btn", "Test", "123", "xyz"])
        XCTAssertEqual(try testView.inspect().findAll(Test.InnerView.self).count, 1)
        XCTAssertEqual(try testView.inspect().findAll(where: { (try? $0.overlay()) != nil }).count, 1)
    }
    
    func testFindText() throws {
        let testView = Test.MainView()
        XCTAssertEqual(try testView.inspect().find(text: "123").pathToRoot,
        "view(MainView.self).anyView().group().text(1)")
        XCTAssertEqual(try testView.inspect().find(text: "Test").pathToRoot,
        """
        view(MainView.self).anyView().group().emptyView(0).overlay().hStack()\
        .view(InnerView.self, 1).button().mask().group().text(0)
        """)
        XCTAssertEqual(try testView.inspect().find(text: "Btn").pathToRoot,
        """
        view(MainView.self).anyView().group().emptyView(0).overlay().hStack()\
        .view(InnerView.self, 1).button().labelView().hStack().text(0)
        """)
        XCTAssertEqual(try testView.inspect().find(text: "xyz").pathToRoot,
        "view(MainView.self).anyView().group().text(1).background().button().labelView().text()")
        XCTAssertEqual(try testView.inspect().find(
            textWhere: { _, attr -> Bool in
                try attr.font() == .footnote
            }).string(), "123")
        XCTAssertThrows(try testView.inspect().find(text: "unknown"),
                        "Search did not find a match")
        XCTAssertThrows(try testView.inspect().find(ViewType.Text.self, relation: .parent),
                        "Search did not find a match")
    }
    
    func testFindButton() throws {
        let testView = Test.MainView()
        XCTAssertNoThrow(try testView.inspect().find(button: "Btn"))
        XCTAssertNoThrow(try testView.inspect().find(button: "xyz"))
        XCTAssertThrows(try testView.inspect().find(button: "unknown"),
                        "Search did not find a match")
    }
    
    func testFindViewWithId() throws {
        let testView = Test.MainView()
        XCTAssertNoThrow(try testView.inspect().find(viewWithId: "5").emptyView())
        XCTAssertNoThrow(try testView.inspect().find(viewWithId: 7).text())
        XCTAssertThrows(try testView.inspect().find(viewWithId: 0),
                        "Search did not find a match")
    }
    
    func testFindViewWithTag() throws {
        let testView = Test.MainView()
        XCTAssertNoThrow(try testView.inspect().find(viewWithTag: 4).text())
        XCTAssertNoThrow(try testView.inspect().find(viewWithTag: 9).view(Test.InnerView.self))
        XCTAssertThrows(try testView.inspect().find(viewWithTag: 0),
                        "Search did not find a match")
    }
    
    func testFindCustomView() throws {
        let testView = Test.MainView()
        XCTAssertNoThrow(try testView.inspect().find(Test.InnerView.self))
        XCTAssertNoThrow(try testView.inspect().find(Test.InnerView.self, containing: "Btn"))
        XCTAssertThrows(try testView.inspect().find(Test.InnerView.self, containing: "123"),
                        "Search did not find a match")
    }
}
