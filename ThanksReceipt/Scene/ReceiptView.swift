//
//  ReceiptView.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/08.
//

import SwiftUI

struct ReceiptView: View {
    @StateObject var model = ReceiptModel()
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.background.ignoresSafeArea()
                
                VStack {
                    ToolBar(didTapSave: model.didTapSave,
                            didTapAdd: model.addItem)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    
                    ReceiptContentView()
                        .padding(.horizontal, 7)
                        .padding(.bottom, 10)
                }
                .toast(message: $model.message)
                
                if let viewState = model.viewState {
                    switch viewState {
                    case .monthPicker:
                        MonthPicker(
                            dependency: MonthPickerModelComponents(
                                currentDate: model.selectedMonth
                            ),
                            listener: model
                        )
                        .backgroundBlur(onTapBackground: model.didTapBackgroundView)
                        .transition(.opacity.animation(.easeInOut))
                    case .input(let inputMode):
                        ReceiptInputView(
                            dependency: ReceiptInputModelComponents(
                                mode: inputMode,
                                date: model.selectedMonth
                            ),
                            listener: model
                        )
                        .backgroundBlur(onTapBackground: model.didTapBackgroundView)
                        .transition(.opacity.animation(.easeInOut))
                    case .snapshotPreview:
                        ReceiptSnapshotPreview(
                            dependency: ReceiptSnapshotPreviewModelComponent(
                                scrollToId: model.scrollToId,
                                monthText: model.monthText,
                                totalCount: model.totalCount,
                                receiptItems: model.receiptItems
                            ),
                            closeSnapshotPreview: model.didTapBackgroundView
                        )
                    case .bottomSheet:
                        EmptyView()
                    }
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
