//
//  LegalAidSearch.swift
//  CallBook
//
//  Created by M on 12/03/2024.
//

import Foundation

class LegalAidSearch {
    enum Category: String, CaseIterable, Identifiable {
        var id: String {
            rawValue
        }
        
        case immigration = "immigration"
        case housing = "housing"
        case mental = "mentalhealth"
        
        var title: String {
            switch self {
            case .immigration:
                return "Immigration or asylum"
            case .housing:
                return "Housing"
            case .mental:
                return "Mental health"
            }
            
        }
        
        var description: String {
            switch self {
            case .immigration:
                return "Applying for asylum or permission to stay in the UK, including for victims of human trafficking"
            case .housing:
                return "Eviction, homelessness, losing your rented home, rent arrears, harassment by a landlord or neighbour, health and safety issues with your home"
            case .mental:
                return "Help with mental health and mental capacity legal issues"
            }
        }
    }
    
    enum URLError: Error {
        case compose
    }
    
    static private let base = "https://checklegalaid.service.gov.uk/find-a-legal-adviser?postcode="
    
    static func isPostCode(_ postcode: String) -> Bool {
        return postcode.ranges(of: /([Gg][Ii][Rr] 0[Aa]{2})|((([A-Za-z][0-9]{1,2})|(([A-Za-z][A-Ha-hJ-Yj-y][0-9]{1,2})|(([A-Za-z][0-9][A-Za-z])|([A-Za-z][A-Ha-hJ-Yj-y][0-9][A-Za-z]?))))\s?[0-9][A-Za-z]{2})/).count == 1
    }
    
    static func url(for postcode: String, in category: Category) throws -> URL {
        guard let url = URL(string: base + postcode + "&category=" + category.rawValue + "/") else {
            throw URLError.compose
        }
        return url
    }
    
    
}
