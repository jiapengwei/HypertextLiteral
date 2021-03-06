#if !SKIP_DEFAULT_HYPER_TEXT_CONVERTIBLE_CONFORMANCES

extension Array: HypertextLiteralConvertible where Element: HypertextLiteralConvertible {
    public var html: HTML {
        return HTML(map { $0.html.description }.joined(separator: "\n"))
    }
}

extension Array: HypertextAttributesInterpolatable where Element: HypertextAttributesInterpolatable {
    public func html(in element: String) -> HTML {
        return HTML(map { $0.html(in: element).description }.joined(separator: " "))
    }
}

extension Array: HypertextAttributeValueInterpolatable where Element: StringProtocol {
    public func html(for attribute: String, in element: String) -> HTML? {
        switch attribute {
        case "class":
            return HTML(map { String($0) }.joined(separator: " "))
        default:
            return nil
        }
    }
}

extension Bool: HypertextAttributeValueInterpolatable {
    public func html(for attribute: String, in element: String) -> HTML? {
        switch attribute {
        case // Global Attributes
             "contenteditable",
             "hidden",
             "spellcheck",
             // Media Attributes
             "autoplay",
             "controls",
             "loop",
             "muted",
             "preload",
             // Input Attributes
             "autofocus",
             "disabled",
             "multiple",
             "readonly",
             "required",
             "selected",
             "wrap",
             // Script Attributes
             "async",
             "defer":
            return HTML(attribute)
        case "translate":
            return HTML(self ? "yes" : "no")
        case "autocomplete":
            return HTML(self ? "on" : "off")
        default:
            return HTML(self ? "true" : "false")
        }
    }
}

extension Dictionary: HypertextAttributesInterpolatable where Key: StringProtocol {
    public func html(in element: String) -> HTML {
        var attributes: [(name: String, value: String)] = []

        func attribute(for key: String, value: Any) -> (name: String, value: String) {
            if let html = (value as? HypertextAttributeValueInterpolatable)?.html(for: key, in: element) {
                return (key, html.description)
            } else {
                return (key, "\(value)")
            }
        }

        for (key, value) in self {
            switch key {
            case "aria", "data":
                guard let value = value as? [String: Any] else { fallthrough }
                for (nestedKey, nestedValue) in value {
                    attributes.append(attribute(for: "\(key)-\(nestedKey)", value: nestedValue))
                }
            default:
                attributes.append(attribute(for: "\(key)", value: value))
            }
        }

        return HTML(attributes.sorted(by: { $0.0 < $1.0 }).map { #"\#($0.0)="\#($0.1)""# }.joined(separator: " "))
    }
}

extension Dictionary: HypertextAttributeValueInterpolatable where Key: StringProtocol {
    public func html(for attribute: String, in element: String) -> HTML? {
        switch attribute {
        case "style":
            return HTML(map { "\($0.key): \($0.value);" }.sorted().joined(separator: " "))
        default:
            return nil
        }
    }
}

#endif
