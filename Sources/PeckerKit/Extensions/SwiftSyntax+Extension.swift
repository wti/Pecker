import Foundation
import SwiftSyntax

protocol InheritableSyntax {
    var inheritanceClause: TypeInheritanceClauseSyntax? { get }
    func isInherited(from string: String) -> Bool
}

extension InheritableSyntax {
    func isInherited(from string: String) -> Bool {
        inheritanceClause?.inheritedTypeCollection.contains(where: { $0.lastToken?.text == string }) ?? false
    }
}

extension ClassDeclSyntax: InheritableSyntax {}
extension StructDeclSyntax: InheritableSyntax {}
extension EnumDeclSyntax: InheritableSyntax {}
extension ProtocolDeclSyntax: InheritableSyntax {}

protocol ModifierSyntax: SyntaxProtocol {
  // 1: ModifierListSyntax typealiased to DeclModifierListSyntax
  // 2: generated implementations not being seen - wrong type or spelling?
  // - both go to same declaration in the same file:
  // - SwiftSyntax.ModifierListSyntax
  // - in SwiftSyntax/generated/../SyntaxCollections.swift

  // actual: `public var modifiers: ModifierListSyntax?`
  //var modifiers: SwiftSyntax.DeclModifierListSyntax? { get }
  var modifiers: SwiftSyntax.ModifierListSyntax? { get }
    func isPublic() -> Bool
}

extension ModifierSyntax {
//  func searchParent<T: ModifierSyntax>() -> T? {
  func searchParent<T: ModifierSyntax>() -> T? {
        var currentParent: SyntaxProtocol? = parent
        
        while currentParent != nil {
          if let decl = currentParent as? T {
            return decl
          }
          currentParent = currentParent?.parent
        }
        return nil
    }
}

extension ModifierSyntax {
    func isPublic() -> Bool {
        if let modifiers = modifiers {
            if modifiers.contains(where: {
              $0.name.tokenKind == .keyword(.public)
            }) {
                return true
            }
            if modifiers.contains(where: {
              $0.name.tokenKind == .keyword(.private) ||
              $0.name.tokenKind == .keyword(.internal) ||
              $0.name.tokenKind == .keyword(.fileprivate)
            }) {
                return false
            }
        }
        
        guard let extDel: ExtensionDeclSyntax = searchParent() else {
          return false
        }
        let modifiers = extDel.modifiers
        return modifiers.contains { $0.name.tokenKind == .keyword(.public) }
    }
}

// TODO: P0 restore
//
// Error: does not conform to ModifierSyntax
// But have `public var modifiers:` in generated files, in
// `var modifiers: SwiftSyntax.DeclModifierListSyntax?`
// SwiftSyntax/generated/syntaxNodes/:
//  1 in Declaration.swift
// ?? in RawSyntaxNodes.swift
// 21 in SyntaxDeclNodes.swift
//  3 in SyntaxNodes.swift
//  2 in SyntaxTraits.swift
// types:
// RawModifierListSyntax

// SyntaxDeclNodes.swift `var modifiers: ModifierListSyntax?`:
// ClassDeclSyntax
// EnumDeclSyntax
// FunctionDeclSyntax
// OperatorDeclSyntax
// ProtocolDeclSyntax
//
// Implementations use SwiftSyntax.ModifierListSyntax
// in SwiftSyntax/generated/../SyntaxCollections.swift

extension StructDeclSyntax: ModifierSyntax {}
extension EnumDeclSyntax: ModifierSyntax {}
extension ProtocolDeclSyntax: ModifierSyntax {}
extension FunctionDeclSyntax: ModifierSyntax {}
extension TypealiasDeclSyntax: ModifierSyntax {}
extension OperatorDeclSyntax: ModifierSyntax {}
extension ExtensionDeclSyntax: ModifierSyntax {}


protocol IdentifierSyntax: SyntaxProtocol {
    var identifier: TokenSyntax { get }
}

extension ClassDeclSyntax: IdentifierSyntax {}
extension StructDeclSyntax: IdentifierSyntax {}
extension EnumDeclSyntax: IdentifierSyntax {}
extension ProtocolDeclSyntax: IdentifierSyntax {}
extension FunctionDeclSyntax: IdentifierSyntax {}
extension TypeAliasDeclSyntax: IdentifierSyntax {}
extension OperatorDeclSyntax: IdentifierSyntax {}

extension TriviaPiece {
    public var comment: String? {
        switch self {
        case .spaces,
             .tabs,
             .verticalTabs,
             .formfeeds,
             .newlines,
             .carriageReturns,
             .carriageReturnLineFeeds,
             .backslashes,
             .pounds,
             .unexpectedText:
//             .backticks:
            return nil
        case .lineComment(let comment),
             .blockComment(let comment),
             .docLineComment(let comment),
             .docBlockComment(let comment):
            return comment
        }
    }
}
