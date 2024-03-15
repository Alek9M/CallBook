//
//  CallRowView.swift
//  CallBook
//
//  Created by M on 15/03/2024.
//

import SwiftUI

struct CallRowView: View {
    
    @ObservedObject var call: Call
    
    var body: some View {
//        HStack {
            Text(call.on.formatted(date: .abbreviated, time: .shortened))
//            Spacer()
//            Picker("", selection: $call.reached) {
//                Text("􀉿")
//                    .tag(true)
//                Text("􀊁")
//                    .tag(false)
//            }
//            .pickerStyle(.menu)
//        }
    }
}

//#Preview {
//    CallRowView()
//}
