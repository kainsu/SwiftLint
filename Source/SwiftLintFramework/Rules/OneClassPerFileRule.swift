//
//  OneClassPerFileRule.swift
//  SwiftLint
//
//  Created by Andrey Kopnin on 05/04/17.
//  Copyright © 2017 Realm. All rights reserved.
//

import SourceKittenFramework

public struct OneClassPerFileRule: OptInRule, ConfigurationProviderRule {
    
    public var configuration = SeverityConfiguration(.warning);
    
    public init() { }
    
    public static let description = RuleDescription(
        identifier: "one_class_per_file",
        name: "One Class Per File",
        description: "Only one class, structure, extension or protocol declartion per file is allowed.",
        nonTriggeringExamples: [
            // One class per file
            "class X {\n" +
            "}\n",
            
            // Nested classes are allowed.
            "class X {\n" +
            "   class Y {\n" +
            "   }\n" +
            "}\n"
        ],
        triggeringExamples: [
            "class X {\n" +
            "}\n" +
            "class Y {\n" +
            "}\n"
        ]
    )
    
    
    public func validate(file: File) -> [StyleViolation] {
        let structure = Structure(file: file);
        
        var results: [StyleViolation] = [];
        structure.dictionary.substructure.forEach { substructure in
            if ((substructure.kind == SwiftDeclarationKind.class.rawValue) ||
                    (substructure.kind == SwiftDeclarationKind.protocol.rawValue) ||
                    (substructure.kind == SwiftDeclarationKind.extension.rawValue) ||
                    (substructure.kind == SwiftDeclarationKind.struct.rawValue) ||
                    (substructure.kind == SwiftDeclarationKind.enum.rawValue)) {
                
                results.append(StyleViolation(
                    ruleDescription: OneClassPerFileRule.description,
                    location: Location(file: file, byteOffset: substructure.offset!)))
            }
        }

        if results.count == 1 {
            results.removeAll()
        }
        
        return results;
    }
}
