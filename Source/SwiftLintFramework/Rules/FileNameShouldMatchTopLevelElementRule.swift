//
//  FileNameShouldMatchTopLevelElement.swift
//  SwiftLint
//
//  Created by Andrey Kopnin on 05/04/17.
//  Copyright © 2017 Realm. All rights reserved.
//

import Foundation
import SourceKittenFramework

public struct FileNameShouldMatchTopLevelElementRule: OptInRule, ConfigurationProviderRule {
    
    public var configuration = SeverityConfiguration(.warning);
    
    public init() { }
    
    public static let description = RuleDescription(
        identifier: "file_name_should_match_top_level_element",
        name: "File Name Rule",
        description: "Name of the file should be equal to class name declared within that file.",
        nonTriggeringExamples: [ ],
        triggeringExamples: [ ]
    )
    
    public func validate(file: File) -> [StyleViolation] {
        guard  let filePath = file.path else {
            return []
        }
        
        let oneClassPerFileRule = OneClassPerFileRule()
        
        let preCheckresults = oneClassPerFileRule.validate(file: file)
        if preCheckresults.count > 0 {
            return preCheckresults
        }
        
        let structure = Structure(file: file)        
        let topLevelDeclaration = structure.dictionary.substructure.first(where: { substructure in
            return ((substructure.kind == SwiftDeclarationKind.class.rawValue) ||
                (substructure.kind == SwiftDeclarationKind.protocol.rawValue) ||
                (substructure.kind == SwiftDeclarationKind.extension.rawValue) ||
                (substructure.kind == SwiftDeclarationKind.struct.rawValue) ||
                (substructure.kind == SwiftDeclarationKind.enum.rawValue))
        })

        var results: [StyleViolation] = [];
        if let topLevelDeclaration = topLevelDeclaration {
        
            let fileUrl = URL(fileURLWithPath: filePath)
            let fileName = fileUrl.deletingPathExtension().lastPathComponent
           
            if topLevelDeclaration.kind == SwiftDeclarationKind.extension.rawValue {
                
                if !self.validateExtensionName(topLevelDeclaration.name!, fileName) {
                    results.append(StyleViolation(ruleDescription: FileNameShouldMatchTopLevelElementRule.description,
                                                  severity: .warning,
                                                  location: Location(file: file, byteOffset: topLevelDeclaration.offset!),
                                                  reason: "File name should match first type name: '\(topLevelDeclaration.name!).swift'"))
                }
            
            } else {
                if fileName != topLevelDeclaration.name {
                    results.append(StyleViolation(ruleDescription: FileNameShouldMatchTopLevelElementRule.description,
                                                  severity: .warning,
                                                  location: Location(file: file, byteOffset: topLevelDeclaration.offset!),
                                                  reason: "File name should match first type name: '\(topLevelDeclaration.name!).swift'"))
                }
            }
        }
        
        return [];
    }
    
    private static func validateExtensionName(_ className: String, _ fileName: String) -> Bool {
        
        var isValid = false
        
        let fileNamePattern = "(?:\(className))\\+(\\w[\\w\\d]+)"
        let fileNameRegex = try! NSRegularExpression(pattern: fileNamePattern, options: [])
        
        let nsFileName = fileName as NSString
        let range = NSRange(location: 0, length: nsFileName.length)
        
        let matches = fileNameRegex.matches(in: fileName, options: [], range: range)
        if !matches.isEmpty {
            
            // Extension description must be a valid identifer name
            let extensionsDescription = nsFileName.substring(with: matches[0].rangeAt(1))
            isValid = CharacterSet.alphanumerics.isSuperset(ofCharactersIn: extensionsDescription) && !extensionsDescription.isViolatingCase
        }
        
        return isValid
    }
}


fileprivate extension String {
    var isViolatingCase: Bool {
        let secondIndex = characters.index(after: startIndex)
        let firstCharacter = substring(to: secondIndex)
        
        guard firstCharacter.isUppercase() else {
            return true
        }
        guard characters.count > 1 else {
            return true
        }
        let range = secondIndex..<characters.index(after: secondIndex)
        let secondCharacter = substring(with: range)
        return secondCharacter.isLowercase()
    }
}
