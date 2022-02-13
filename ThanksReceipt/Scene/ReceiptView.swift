//
//  ReceiptView.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/08.
//

import SwiftUI

struct ReceiptView: View {
    @StateObject var model = ReceiptModel()
    // TODO: - Loading, Alert, Toast
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                VStack {
                    ToolBar(model: model)
                        .padding(.horizontal, 20)
                    
                    VStack {
                        ReceiptHeader(model: model)
                            .padding(.horizontal, 20)
                        
                        List {
                            ForEach(Array(model.receiptItems.enumerated()), id: \.offset) { offset, item in
                                ReceiptItemRow(item: item)
                                    .padding(.top, item.topPadding)
                                    .padding(.horizontal, 5)
                                    .listRowBackground(Color.background)
                                    .onAppear { model.didAppearRow(offset) }
                                    .onTapGesture { model.didTapRow(item.id) }
                            }
                            .listRowSeparatorTint(.clear)
                        }
                        .listStyle(.plain)
                        
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
                        
                        ReceiptInputView(dependency: ReceiptInputModelComponents(mode: model.inputMode!),
                                         listener: model)
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

extension UIView {
    var renderedImage: UIImage {
        // rect of capure
        let rect = self.bounds
        // create the context of bitmap
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        self.layer.render(in: context)
        // get a image from current context bitmap
        let capturedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return capturedImage
    }
}

extension View {
    func takeScreenshot(origin: CGPoint, size: CGSize) -> UIImage {
        let window = UIWindow(frame: CGRect(origin: origin, size: size))
        let hosting = UIHostingController(rootView: self)
        hosting.view.frame = window.frame
        window.addSubview(hosting.view)
        window.makeKeyAndVisible()
        return hosting.view.renderedImage
    }
}
