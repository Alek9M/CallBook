//
//  CategoryPickerMenu.swift
//  CallBook
//
//  Created by M on 14/03/2024.
//

import SwiftUI
import SwiftData

struct FilterMenus: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Query private var cities: [Callee]
    @Query private var categories: [Callee]
    
    @Binding private var city: String
    @Binding private var category: String
    
    init(city: Binding<String>, category: Binding<String>) {
        
        _city = city
        _category = category
        
        var citiesDescriptor = FetchDescriptor<Callee>(sortBy: [SortDescriptor(\.city, order: .forward)])
        citiesDescriptor.propertiesToFetch = [\.city]
        _cities = Query(citiesDescriptor)
        
        var categoriesDescriptor = FetchDescriptor<Callee>(sortBy: [SortDescriptor(\.origText, order: .forward)])
        categoriesDescriptor.propertiesToFetch = [\.origText]
        _categories = Query(categoriesDescriptor)
    }
    
    var body: some View {
        Menu(content: {
            if categories.count > 0 {
                Picker("Category", selection: $category) {
                    ForEach(categories) { category in
                        Text(category.title)
                            .tag(category)
                    }
                }
                .pickerStyle(.menu)

            }
            
            if cities.count > 0 {
                Picker("City", selection: $city) {
                    ForEach(cities) { city in
                        Text(city.title)
                            .tag(city)
                    }
                }
                .pickerStyle(.menu)
            }
        }) {
            Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
        }
        .onAppear {
//            deleteEmptyCities()
//            deleteEmptyCategories()
//            city = cities.first
//            category = categories.first
        }
        
    }
    
//    private func deleteEmptyCategories() {
//        let categoryStrings = Set(categories.map(\.title)).sorted()
//        for categoryString in categoryStrings {
//            var categoriesFiltered = categories.filter { $0.title == categoryString }
//            for cat in categoriesFiltered {
//                if cat.callees?.count == 0 {
//                    modelContext.delete(cat)
//                }
//            }
//        }
//    }
//    
//    private func deleteEmptyCities() {
//        let cityStrings = Set(cities.map(\.title)).sorted()
//        for cityString in cityStrings {
//            var citiesFiltered = cities.filter { $0.title == cityString }
//            for cat in citiesFiltered {
//                if cat.callees?.count == 0 {
//                    modelContext.delete(cat)
//                }
//            }
//        }
//    }
}

//#Preview {
//    FilterMenus(city: .constant(City(title: "London")), category: .constant(LawCategory(title: "Asylum", columnNumber: 3)))
//}
