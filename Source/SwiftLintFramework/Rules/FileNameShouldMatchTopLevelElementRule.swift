//
//  FileNameShouldMatchTopLevelElement.swift
//  SwiftLint
//
//  Created by Andrey Kopnin on 05/04/17.
//  Copyright © 2017 Realm. All rights reserved.
//

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
            let fileName = fileUrl.lastPathComponent
            if fileName != topLevelDeclaration.name {
                results.append(StyleViolation(
                    ruleDescription: FileNameShouldMatchTopLevelElementRule.description,
                    location: Location(file: file, byteOffset: topLevelDeclaration.offset!)))
            }
        }
        
        return [];
    }
}
