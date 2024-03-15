//
//  CityPickerView.swift
//  CallBook
//
//  Created by M on 15/03/2024.
//

import SwiftUI

struct CityPickerView: View {
    
    @Environment(\.dismiss) private var dissmiss
    
    @State private var citySearch = ""
    
    @Binding var city: String?
    
    var cities: [String]
    
    var filtered: [String] {
        if citySearch.isEmpty {
            return cities
        } else {
            return cities.filter { citySearch.isEmpty ? true : $0.localizedCaseInsensitiveContains(citySearch) }
        }
    }
    
    var body: some View {
        NavigationStack {
#if os(macOS)
            TextField("Search", text: $citySearch)
            Button(action: {
                city = ""
                dissmiss()
            }) {
                Label("All (will take much longer)", systemImage: "list.triangle")
            }
            .buttonStyle(BorderlessButtonStyle.borderless)
#endif
                
            List(filtered, id: \.self) { choice in
                Button(action: {
                    self.city = choice
//                    self.cities = nil
                    dissmiss()
                }) {
                    Text(choice)
                }
                
#if os(macOS)
                .buttonStyle(BorderlessButtonStyle.borderless)
#else
                .searchable(text: $citySearch)
#endif
            }
#if os(macOS)
            .frame(width: 200, height: 200, alignment: .leading)
//            .padding()
#else
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        city = ""
                        dissmiss()
                    }) {
                        Label("All", systemImage: "list.triangle")
                            .labelStyle(.titleOnly)
                    }
                }
            }
#endif
            .navigationTitle("Select city to save")
            .interactiveDismissDisabled()
            
        }
    }
}

//#Preview {
//    CityPickerView(city: .constant(""), cities: ["London", "Brighton"])
//}
