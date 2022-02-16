//
//  InputBottomToolBar.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/16.
//

import SwiftUI

struct InputBottomToolBar: View {
    var isEditMode: Bool = false
    var didTapDelete: (() -> Void)
    var didTapSave: (() -> Void)
    
    var body: some View {
        HStack {
            if isEditMode {
                Button(action: didTapDelete) {
                    VStack(spacing: 2) {
                        Image(systemName: "trash")
                            .font(.system(size: 18, weight: .bold))
                        
                        Text("Delete?")
                            .customFont(.DungGeunMo, size: 17)
                    }
                }
                .foregroundColor(.black)
                .padding(.leading, 25)
            }
            
            Spacer()
            
            Button(action: didTapSave) {
                VStack(spacing: 2) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .bold))
                    
                    Text("Thanks?")
                        .customFont(.DungGeunMo, size: 17)
                }
            }
            .foregroundColor(.black)
            .padding(.trailing, 25)
        }
        .padding(.bottom, 10)
    }
}

struct InputBottomToolBar_Previews: PreviewProvider {
    static var previews: some View {
        InputBottomToolBar(didTapDelete: { }, didTapSave: { })
    }
}
