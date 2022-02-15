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
    // TODO: - Loading, Alert, Toast
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                VStack {
                    ToolBar()
                        .padding(.horizontal, 20)
                    
                    ReceiptContentView(showMonthPicker: $showMonthPicker)
                }
                .environmentObject(model)
                
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
                    CapturePreview(showPreview: $showPreview)
                        .environmentObject(model)
                }
            }
            .onReceive(model.captureListHeight) {
                print(model.receiptItems.count, $0)
                showPreview = true
            }
        }
    }
}

struct ReceiptView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptView()
    }
}

extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self.edgesIgnoringSafeArea(.all))
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
