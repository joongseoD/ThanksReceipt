//
//  ReceiptView.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/08.
//

import SwiftUI
import Combine

struct ReceiptView: View {
    @StateObject var model = ReceiptModel()
    @State private var showMonthPicker = false
    @State private var showPreview = false
    // TODO: - Loading, Alert
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.background.ignoresSafeArea()
                
                VStack {
                    ToolBar(didTapSave: { showPreview = true },
                            didTapAdd: model.addItem)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    
                    ReceiptContentView(showMonthPicker: $showMonthPicker)
                        .padding(.horizontal, 7)
                        .padding(.bottom, 10)
                }
                .toast(message: $model.message)
                
                if let inputMode = model.inputMode {
                    ReceiptInputView(
                        dependency: ReceiptInputModelComponents(
                            mode: inputMode,
                            date: model.selectedMonth
                        ),
                        listener: model
                    )
                    .backgroundBlur(onTapBackground: model.didTapBackgroundView)
                    .transition(.opacity.animation(.easeInOut))
                }
                
                if showMonthPicker {
                    DatePickerView(
                        selection: $model.selectedMonth,
                        pickerStyle: WheelDatePickerStyle(),
                        components: [.date]
                    ) { date in
                        showMonthPicker = false
                        model.didChangeMonth(date)
                    }
                    .backgroundBlur(onTapBackground: model.didTapBackgroundView)
                    .transition(.opacity.animation(.easeInOut))
                }
                
                if showPreview {
                    ReceiptSnapshotPreview(showPreview: $showPreview)
                }
            }
            .environmentObject(model)
        }
    }
}

struct ReceiptView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptView()
    }
}
