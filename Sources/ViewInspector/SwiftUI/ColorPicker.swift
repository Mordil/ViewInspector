import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct ColorPicker: KnownViewType {
        public static var typePrefix: String = "ColorPicker"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
public extension InspectableView where View: SingleViewContent {
    
    func colorPicker() throws -> InspectableView<ViewType.ColorPicker> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
public extension InspectableView where View: MultipleViewContent {
    
    func colorPicker(_ index: Int) throws -> InspectableView<ViewType.ColorPicker> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.ColorPicker: SupplementaryChildren {
    static func supplementaryChildren(_ parent: UnwrappedView) throws -> LazyGroup<SupplementaryView> {
        return try .labelView(parent)
    }
}

// MARK: - Custom Attributes

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
public extension InspectableView where View == ViewType.ColorPicker {
    
    func labelView() throws -> InspectableView<ViewType.ClassifiedView> {
        return try View.supplementaryChildren(self).element(at: 0)
    }
    
    #if os(macOS)
    func select(color: NSColor) throws {
        let binding = try Inspector.attribute(label: "_color", value: content.view, type: Binding<NSColor>.self)
        binding.wrappedValue = color
    }
    
    @available(tvOS 14.0, *)
    func select(color: Color) throws {
        try select(color: NSColor(color))
    }
    
    #else
    
    @available(tvOS 14.0, *)
    func select(color: Color) throws {
        try select(color: UIColor(color))
    }
    
    func select(color: CGColor) throws {
        try select(color: UIColor(cgColor: color))
    }
    
    func select(color: UIColor) throws {
        let binding = try Inspector.attribute(label: "_color", value: content.view, type: Binding<UIColor>.self)
        binding.wrappedValue = color
    }
    
    #endif
}

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
public extension ViewType.ColorPicker {
    /**
     A container for comparing colors in tests. FYI: Color.red != UIColor.red
     */
    struct RGBA: Equatable {
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        #if os(macOS)
        
        init(color: NSColor) {
            let color = color.usingColorSpace(.deviceRGB) ?? color
            red = color.redComponent
            green = color.greenComponent
            blue = color.blueComponent
            alpha = color.alphaComponent
        }
        
        init(color: Color) {
            self.init(color: NSColor(color))
        }
        
        #else
        
        init(color: UIColor) {
            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        }
        
        init(color: CGColor) {
            self.init(color: UIColor(cgColor: color))
        }
        
        @available(tvOS 14.0, *)
        init(color: Color) {
            self.init(color: UIColor(color))
        }
        
        #endif
        
        public static func == (lhs: RGBA, rhs: RGBA) -> Bool {
            let compareComponent: (CGFloat, CGFloat) -> Bool = { value1, value2 in
                return abs(value1 - value2) < 1 / 256
            }
            return compareComponent(lhs.red, rhs.red)
                && compareComponent(lhs.green, rhs.green)
                && compareComponent(lhs.blue, rhs.blue)
                && compareComponent(lhs.alpha, rhs.alpha)
        }
    }
}
