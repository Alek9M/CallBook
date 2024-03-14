//
//  SearchView.swift
//  CallBook
//
//  Created by M on 12/03/2024.
//

import SwiftUI
import SwiftSoup

struct SearchView: View {
    
    @State var postCode = ""
    @State var category = LegalAidSearch.Category.immigration
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Parametrs") {
                    TextField("UK PostCode", text: $postCode)
                    Picker(selection: $category, label: Text("Category")) {
                        ForEach(LegalAidSearch.Category.allCases) { category in
                            Text(category.title)
                                .tag(category)
                        }
                    }
                }
                
            }
            .navigationTitle("Legal Aid")
#if os(macOS)
            .padding()
#endif
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        DispatchQueue.global(qos: .userInitiated).async {
                            do {
                                let html = try String(contentsOf: LegalAidSearch.url(for: postCode, in: category))
//                                let task = URLSession.shared.dataTask(with: try LegalAidSearch.url(for: postCode, in: category)) { (data, response, error) in
//                                    if let error = error {
//                                        print("Error: \(error)")
//                                    } else if let data = data,
//                                              let html = String(data: data, encoding: .utf8) {
//                                        do {
                                            let doc = try SwiftSoup.parse(html)
                                            let cards = try doc.select("li.org-list-item")
                                            
                                            for card in cards {
                                                
                                                let title = try card.select("span.fn.org").first()?.text()
                                                
                                                let distance = Float(try card.select("div.distance").first()?.ownText().trimmingPrefix(" miles") ?? "0")
                                                
                                                let address = try card.select("span.street-address").first()?.text()
                                                
//                                                let city = try card.select("span.city").first()?.text()
                                                
                                                let postalCode = try card.select("span.postal-code").first()?.text()
                                                
                                                let helpline = try card.select("span.tel").first()?.text()
                                                
                                                let website = URL(string: try card.select("a.govuk-link").first()?.attr("href") ?? "404")
                                                
                                                let categories = try card.select("ul.govuk-list li")
                                                var categoryList = [String]()
                                                for category in categories {
                                                    categoryList.append(try category.text())
                                                }
                                                
//                                                let callee = Callee(title: title ?? "404", phoneNumber: helpline, web: website, postcode: postalCode, address: address, origText: categoryList.joined(separator: "\n"), city: <#City#>, distance: distance)
                                            }
//                                        } catch {
//                                            print(error.localizedDescription.lowercased())
//                                        }
//                                    }
//                                }
//                                task.resume()
                                
                                
                            } catch {
                                print(error.localizedDescription.lowercased())
                            }
                        }
                    }) {
                        Label("Search", systemImage: "magnifyingglass")
                            .labelStyle(.titleOnly)
                    }
                    //                    .disabled(LegalAidSearch.isPostCode(postCode))
                }
            }
        }
    }
}

#Preview {
    SearchView()
}
