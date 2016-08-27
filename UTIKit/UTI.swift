//  The MIT License (MIT)
//
//  Copyright (c) 2015 Hiroki Kato
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


import Foundation
#if os(iOS)
import MobileCoreServices
#endif

public struct UTI: CustomStringConvertible, CustomDebugStringConvertible, Equatable {

    public let UTIString: String

    // MARK: - Initialize

    public init(_ UTIString: String) {
        self.UTIString = UTIString
    }

    public init?(filenameExtension: String, conformingToUTI: UTI? = nil) {
        let conformingToUTIString: CFString? = conformingToUTI?.UTIString as CFString?
        guard let rawUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, filenameExtension as CFString, conformingToUTIString)?.takeRetainedValue() else { return nil }
        self.UTIString = rawUTI as String
    }

    public init?(MIMEType: String, conformingToUTI: UTI? = nil) {
        let conformingToUTIString: CFString? = conformingToUTI?.UTIString as CFString?
        guard let rawUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, MIMEType as CFString, conformingToUTIString)?.takeRetainedValue() else { return nil }
        self.UTIString = rawUTI as String
    }

    #if os(macOS)
    public init?(pasteBoardType: String, conformingToUTI: UTI? = nil) {
        let conformingToUTIString: CFString? = conformingToUTI?.UTIString as CFString?
        guard let rawUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassNSPboardType, pasteBoardType as CFString, conformingToUTIString)?.takeRetainedValue() else { return nil }
        self.UTIString = rawUTI as String
    }

    public init?(OSType: String, conformingToUTI: UTI? = nil) {
        let conformingToUTIString: CFString? = conformingToUTI?.UTIString as CFString?
        guard let rawUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassOSType, OSType as CFString, conformingToUTIString)?.takeRetainedValue() else { return nil }
        self.UTIString = rawUTI as String
    }
    #endif

    // MARK: -

    private static func UTIsForTagClass(_ tagClass: String, tag: String, conformingToUTI: UTI?) -> [UTI] {
        let conformingToUTIString: CFString? = conformingToUTI?.UTIString as CFString?
        guard let rawUTIs = UTTypeCreateAllIdentifiersForTag(tagClass as CFString, tag as CFString, conformingToUTIString)?.takeRetainedValue() else { return [] }
        return (rawUTIs as NSArray as? [String] ?? []).map { UTI($0) }
    }

    public static func UTIsFromFilenameExtension(_ filenameExtension: String, conformingToUTI: UTI? = nil) -> [UTI] {
        return UTIsForTagClass(kUTTagClassFilenameExtension as String, tag: filenameExtension, conformingToUTI: conformingToUTI)
    }

    public static func UTIsFromMIMEType(_ MIMEType: String, conformingToUTI: UTI? = nil) -> [UTI] {
        return UTIsForTagClass(kUTTagClassMIMEType as String, tag: MIMEType, conformingToUTI: conformingToUTI)
    }

    #if os(macOS)
    public static func UTIsFromPasteBoardType(pasteBoardType: String, conformingToUTI: UTI? = nil) -> [UTI] {
        return UTIsForTagClass(kUTTagClassNSPboardType as String, tag: pasteBoardType, conformingToUTI: conformingToUTI)
    }

    public static func UTIsFromOSType(OSType: String, conformingToUTI: UTI? = nil) -> [UTI] {
        return UTIsForTagClass(kUTTagClassOSType as String, tag: OSType, conformingToUTI: conformingToUTI)
    }
    #endif

    // MARK: - Tags

    private func tagWithClass(_ tagClass: String) -> String? {
        return UTTypeCopyPreferredTagWithClass(UTIString as CFString, tagClass as CFString)?.takeRetainedValue() as String?
    }

    @available(macOS, introduced:10.10)
    @available(iOS, introduced:8.0)
    private func tagsWithClass(_ tagClass: String) -> [String] {
        guard let tags = UTTypeCopyAllTagsWithClass(UTIString as CFString, tagClass as CFString)?.takeRetainedValue() else { return [] }
        return tags as NSArray as? [String] ?? []
    }

    public var filenameExtension: String? {
        return tagWithClass(kUTTagClassFilenameExtension as String)
    }

    @available(macOS, introduced:10.10)
    @available(iOS, introduced:8.0)
    public var filenameExtensions: [String] {
        return tagsWithClass(kUTTagClassFilenameExtension as String)
    }

    public var MIMEType: String? {
        return tagWithClass(kUTTagClassMIMEType as String)
    }

    @available(macOS, introduced:10.10)
    @available(iOS, introduced:8.0)
    public var MIMETypes: [String] {
        return tagsWithClass(kUTTagClassMIMEType as String)
    }

    #if os(macOS)
    public var pasteBoardType: String? {
        return tagWithClass(kUTTagClassNSPboardType as String)
    }

    @available(macOS, introduced:10.10)
    public var pasteBoardTypes: [String] {
        return tagsWithClass(kUTTagClassNSPboardType as String)
    }

    public var OSType: String? {
        return tagWithClass(kUTTagClassOSType as String)
    }

    @available(macOS, introduced:10.10)
    public var OSTypes: [String] {
        return tagsWithClass(kUTTagClassOSType as String)
    }
    #endif

    // MARK: - Status

    @available(macOS, introduced:10.10)
    @available(iOS, introduced:8.0)
    public var isDeclared: Bool {
        return UTTypeIsDeclared(UTIString as CFString)
    }

    @available(macOS, introduced:10.10)
    @available(iOS, introduced:8.0)
    public var isDynamic: Bool {
        return UTTypeIsDynamic(UTIString as CFString)
    }

    // MARK: - Declaration

    public struct Declaration: CustomStringConvertible, CustomDebugStringConvertible {
        private let raw: [ NSObject: AnyObject ]

        public var exportedTypeDeclarations: [Declaration] {
            return (raw[kUTExportedTypeDeclarationsKey] as? [[ NSObject : AnyObject ]] ?? []).map { Declaration(declaration: $0) }
        }

        public var importedTypeDeclarations: [Declaration] {
            return (raw[kUTImportedTypeDeclarationsKey] as? [[ NSObject : AnyObject ]] ?? []).map { Declaration(declaration: $0) }
        }

        public var identifier: String? {
            return raw[kUTTypeIdentifierKey] as? String
        }

        public var tagSpecification: [ NSObject : AnyObject ] {
            return raw[kUTTypeTagSpecificationKey] as? [ NSObject : AnyObject ] ?? [:]
        }

        public var conformsTo: [UTI] {
            switch raw[kUTTypeConformsToKey] {
            case let array as [String]:
                return array.map { UTI($0) }
            case let string as String:
                return [ UTI(string) ]
            default:
                return []
            }
        }

        public var iconFile: String? {
            return raw[kUTTypeIconFileKey] as? String
        }

        public var referenceURL: URL? {
            if let reference = raw[kUTTypeReferenceURLKey] as? String {
                return URL(string: reference)
            }
            return nil
        }

        public var version: String? {
            return raw[kUTTypeIconFileKey] as? String
        }

        init(declaration: [ NSObject : AnyObject ]) {
            self.raw = declaration
        }

        public var description: String {
            return raw.description
        }

        public var debugDescription: String {
            return raw.debugDescription
        }

    }

    public var declaration: Declaration {
        return Declaration(declaration: UTTypeCopyDeclaration(self.UTIString as CFString)?.takeRetainedValue() as [NSObject: AnyObject]? ?? [:])
    }

    public var declaringBundle: Bundle? {
        if let url = UTTypeCopyDeclaringBundleURL(UTIString as CFString)?.takeRetainedValue() {
            return Bundle(url: url as URL)
        }
        return nil
    }

    public var iconFileURL: URL? {
        if let iconFile = declaration.iconFile {
            return self.declaringBundle?.url(forResource: iconFile, withExtension: nil) ??
                   self.declaringBundle?.url(forResource: iconFile, withExtension: "icns")
        }
        return nil
    }

    // MARK: - Printable, DebugPrintable

    public var description: String {
        return UTTypeCopyDescription(UTIString as CFString)?.takeRetainedValue() as? String ?? UTIString
    }

    public var debugDescription: String {
        return UTIString
    }

}

public func ==(lhs: UTI, rhs: UTI) -> Bool {
    return UTTypeEqual(lhs.UTIString as CFString, rhs.UTIString as CFString)
}

public func ~=(pattern: UTI, value: UTI) -> Bool {
    return UTTypeConformsTo(value.UTIString as CFString, pattern.UTIString as CFString)
}
