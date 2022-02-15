//
//  ToolBar.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/13.
//

import SwiftUI

struct ToolBar: View {
    @EnvironmentObject var model: ReceiptModel
    
    var body: some View {
        HStack {
            Button(action: model.saveAsImage) {
                Image(systemName: "printer")
            }
            
            Spacer()
            
            Button(action: model.addItem) {
                Image(systemName: "pencil")
            }
        }
        .font(.title2)
        .foregroundColor(Color.text)
    }
}

struct ToolBar_Previews: PreviewProvider {
    static var previews: some View {
        ToolBar()
    }
}
