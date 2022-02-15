//
//  ToolBar.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/13.
//

import SwiftUI

struct ToolBar: View {
    var didTapSave: (() -> Void)
    var didTapAdd: (() -> Void)
    
    var body: some View {
        HStack {
            Button(action: didTapSave) {
                Image(systemName: "printer")
            }
            
            Spacer()
            
            Button(action: didTapAdd) {
                Image(systemName: "pencil")
            }
        }
        .font(.title2)
        .foregroundColor(Color.text)
    }
}

struct ToolBar_Previews: PreviewProvider {
    static var previews: some View {
        ToolBar(didTapSave: { }, didTapAdd: { })
    }
}
