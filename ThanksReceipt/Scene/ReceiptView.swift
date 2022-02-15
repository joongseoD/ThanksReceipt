//
//  ReceiptView.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/08.
//

import SwiftUI

struct ReceiptView: View {
    @StateObject var model = ReceiptModel()
    @State private var showMonthPicker = false
    // TODO: - Loading, Alert, Toast
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                VStack {
                    ToolBar()
                        .padding(.horizontal, 20)
                    
                    VStack {
                        ReceiptHeader(showMonthPicker: $showMonthPicker)
                            .padding(.horizontal, 20)
                        
                        ReceiptList()
                        
                        ReceiptFooter()
                            .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 15)
                    .background(Color.background)
                    .clipShape(ZigZag())
                }
                .environmentObject(model)
                
                if model.inputMode != nil {
                    ZStack {
                        LinearGradient(colors: [.white.opacity(0.8), .gray.opacity(0.8)],
                                       startPoint: .top,
                                       endPoint: .bottom)
                            .background(Blur(style: .systemUltraThinMaterial).opacity(0.8))
                            .ignoresSafeArea()
                            .onTapGesture(perform: model.didTapBackgroundView)
                        
                        ReceiptInputView(
                            dependency: ReceiptInputModelComponents(
                                mode: model.inputMode!,
                                date: model.selectedMonth
                            ),
                            listener: model
                        )
                    }
                    .transition(.opacity.animation(.easeInOut))
                }
                
                if showMonthPicker {
                    ZStack {
                        LinearGradient(colors: [.white.opacity(0.8), .gray.opacity(0.8)],
                                       startPoint: .top,
                                       endPoint: .bottom)
                            .background(Blur(style: .systemUltraThinMaterial).opacity(0.8))
                            .ignoresSafeArea()
                            .onTapGesture(perform: model.didTapBackgroundView)
                        
                        DatePickerView(selection: $model.selectedMonth,
                                       pickerStyle: WheelDatePickerStyle(),
                                       components: [.date]) { date in
                            showMonthPicker = false
                            model.didChangeMonth(date)
                        }
                    }
                    .transition(.opacity.animation(.easeInOut))
                }
            }
            .onReceive(model.captureListHeight) {
                print(model.receiptItems.count, $0)
                let snapshot = takeScreenshot(origin: CGPoint(x: 0, y: 10), size: CGSize(width: proxy.size.width, height: proxy.size.height + $0))
                UIImageWriteToSavedPhotosAlbum(snapshot, nil, nil, nil)
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
