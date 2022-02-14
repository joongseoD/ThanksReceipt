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
                    ToolBar(model: model)
                        .padding(.horizontal, 20)
                    
                    VStack {
                        ReceiptHeader(model: model, showMonthPicker: $showMonthPicker)
                            .padding(.horizontal, 20)
                        
                        ScrollViewReader { scrollProxy in
                            ScrollView {
                                LazyVStack {
                                    ForEach(Array(model.receiptItems.enumerated()), id: \.offset) { offset, section in
                                        Section(
                                            header: ReceiptItemRow(sectionModel: section)
                                                .frame(height: 20)
                                                .padding(.horizontal, 20)
                                                .id(section.header)
                                                .onAppear { model.didAppearRow(offset) }
                                                .onTapGesture { model.didTapRow(section.header.id) },
                                            footer: LineStroke().foregroundColor(.gray).opacity(0.3)
                                        ) {
                                            ForEach(Array(section.items.enumerated()), id: \.offset) { offset, item in
                                                ReceiptItemRow(text: item.text)
                                                    .frame(height: 20)
                                                    .padding(.horizontal, 20)
                                                    .id(item)
                                                    .onAppear { model.didAppearRow(offset) }
                                                    .onTapGesture { model.didTapRow(item.id) }
                                            }
                                        }
                                    }
                                }
                                .transition(.move(edge: .bottom))
                            }
                            .onChange(of: model.scrollFocusItem, perform: { newValue in
                                guard let focusItem = newValue else { return }
                                scrollProxy.scrollTo(focusItem, anchor: .bottom)
                            })
                        }
                        
                        ReceiptFooter(model: model)
                            .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 15)
                    .background(Color.background)
                    .clipShape(ZigZag())
                }
                
                if model.inputMode != nil {
                    ZStack {
                        LinearGradient(colors: [.white.opacity(0.8), .gray.opacity(0.8)],
                                       startPoint: .top,
                                       endPoint: .bottom)
                            .background(Blur(style: .systemUltraThinMaterial).opacity(0.8))
                            .ignoresSafeArea()
                            .onTapGesture(perform: model.didTapBackgroundView)
                        
                        ReceiptInputView(dependency: ReceiptInputModelComponents(mode: model.inputMode!,
                                                                                 date: model.selectedMonth),
                                         listener: model)
                    }
                    .transition(.opacity.animation(.easeInOut))
                }
                
                if showMonthPicker {
                    DatePickerView(selection: $model.selectedMonth,
                                   pickerStyle: WheelDatePickerStyle(),
                                   components: [.date]) { date in
                        showMonthPicker = false
                        model.didChangeMonth(date)
                    }
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
