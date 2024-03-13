//
//  LegalAidSearch.swift
//  CallBook
//
//  Created by M on 12/03/2024.
//

import Foundation
import SwiftSoup
import CoreXLSX

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
    
    enum Columns: Int, CaseIterable {
        case firmName
        case addressLine1
        case addressLine2
        case addressLine3
        case city
        case postcode
        case telephoneNumber
        case crime
        case prisonLaw
        case claimsAgainstAuthorities
        case clinicalNegligence
        case communityCare
        case debt
        case discrimination
        case education
        case mediation
        case housing
        case housingLossPreventionService
        case immigrationAsylum
        case family
        case mentalHealth
        case modernSlavery
        case publicLaw
        case welfareBenefits
        
        var desc: String {
            switch self {
            case .firmName:
                return "Firm Name"
            case .addressLine1:
                return "Address Line 1"
            case .addressLine2:
                return "Address Line 2"
            case .addressLine3:
                return "Address Line 3"
            case .city:
                return "City"
            case .postcode:
                return "Postcode"
            case .telephoneNumber:
                return "Telephone Number"
            case .crime:
                return "Crime"
            case .prisonLaw:
                return "Prison Law"
            case .claimsAgainstAuthorities:
                return "Claims Against Public Authorities"
            case .clinicalNegligence:
                return "Clinical Negligence"
            case .communityCare:
                return "Community Care"
            case .debt:
                return "Debt"
            case .discrimination:
                return "Discrimination"
            case .education:
                return "Education"
            case .mediation:
                return "Mediation"
            case .housing:
                return "Housing"
            case .housingLossPreventionService:
                return "Housing Loss Prevention Advice Service"
            case .immigrationAsylum:
                return "Immigration Asylum"
            case .family:
                return "Family"
            case .mentalHealth:
                return "Mental Health"
            case .modernSlavery:
                return "Modern Slavery"
            case .publicLaw:
                return "Public Law"
            case .welfareBenefits:
                return "Welfare Benefits"
            }
        }
    }
    
    enum LoadingError: Error {
        case xlsx
        case href
    }
    
    private static func getRefreshDate(from worksheet: Worksheet, with sharedStrings: SharedStrings) throws -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        let rowCells = worksheet.cells(atRows: [1])
        let rowStrings = rowCells.map { $0.stringValue(sharedStrings) }
        let first = rowStrings.first
        
        // does not have non empty cells above row 9 🤷🏼‍♂️
        // TODO: maybe get rom Soup?
        guard let row = worksheet.cells(atRows: [0])
            .map { $0.stringValue(sharedStrings) }.first,
        let sureRow = row,
            let date = dateFormatter.date(from: String(sureRow.split(separator: " ")[2])) else { throw LoadingError.xlsx }
        
        return date
    }
    
    static private func process(_ row: [String?]) -> Callee {
        //            row = Array(row[1 ..< row.count])
        
        let allColumns = Columns.allCases
        
        //                for column in allColumns[0 ..< 7] {
        //                }
        
        let address = row[Columns.addressLine1.rawValue].orEmpty + row[Columns.addressLine2.rawValue].orEmpty + row[Columns.addressLine3.rawValue].orEmpty
        
        let callee = Callee(title: row[Columns.firmName.rawValue].orNotFound, phoneNumber: row[Columns.telephoneNumber.rawValue], postcode: row[Columns.postcode.rawValue], address: address, city: row[Columns.city.rawValue])
        
        for column in allColumns[7 ..< allColumns.count] {
            if let _ = row[column.rawValue] {
                callee.addCategory(category: column.desc)
            }
        }
        
        return callee
    }
    
    static func load() async throws -> [Callee] {
        
        //            TODO: uncomment for online
                let html = try String(contentsOf: URL(string: "https://www.gov.uk/government/publications/directory-of-legal-aid-providers")!)
                let doc: Document = try SwiftSoup.parse(html)
                let linkElements: Elements = try doc.select("a.govuk-link.gem-c-attachment__link")
                guard let fileLink = try linkElements.first()?.attr("href") else { throw LoadingError.href }
                guard let url = URL(string: fileLink) else { throw URLError.compose }
        
                let (tmpUrl, response) = try await URLSession.shared.download(for: URLRequest(url: url))
        
        // TODO: comment for online
//        let rel = "/Users/m/Library/Containers/com.akrp9.CallBook/Data/tmp/CFNetworkDownload_B1Y9vv.tmp"
        
        guard let file = XLSXFile(filepath: tmpUrl.relativePath) else {
            throw LoadingError.xlsx
            //            fatalError("XLSX file at \(rel) is corrupted or does not exist")
        }
        
        let worksheet = try file.parseWorksheet(at: "xl/worksheets/sheet1.xml")
        
        guard let sharedStrings = try file.parseSharedStrings() else {
            throw LoadingError.xlsx
        }
        
        let rowsCount = worksheet.cells(atColumns: [ColumnReference("B")!]).count
        
//        print(try getRefreshDate(from: worksheet, with: sharedStrings))
        
        var db: [Callee] = []
        
        let firstRowNumber = 9
        
        for rowNumber in firstRowNumber ..< rowsCount {
            
            let row = worksheet.cells(atRows: [UInt(rowNumber)])
                .map { $0.stringValue(sharedStrings) }
            
            let callee = process(row)
            
            db.append(callee)
            print(rowNumber)
            
        }
        
        return db
    }
}
