//
//  ReceiptModel.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/08.
//

import Foundation
import Combine

protocol ReceiptModelDependency {
    var provider: DataProviding { get }
}

struct ReceiptModelComponents: ReceiptModelDependency {
    var provider: DataProviding = DataProvider()
}

final class ReceiptModel: ObservableObject {
    @Published var receiptItems: [ReceiptItemModel] = []
    @Published var totalCount: String = "0.00"
    
    private var provider: DataProviding
    
    init(dependency: ReceiptModelDependency = ReceiptModelComponents()) {
        self.provider = dependency.provider
        
        setup()
    }
    
    private func setup() {
        let items = [ReceiptItem(text: "0", date: Date()),
                     ReceiptItem(text: "0", date: Date())]
        
        receiptItems = items
            .map { ReceiptItemModel(model: $0)}
        
        totalCount = "\(items.count).00"
    }
}

extension ReceiptModel {
    func saveAsImage() {
        
    }
    
    func addItem() {
        
    }
}

// TODO: - add section model
struct ReceiptItemModel {
    var date: String
    var text: String
    var count: String = ""
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d (E)"
        dateFormatter.locale = Locale(identifier: "ko")
        return dateFormatter
    }()
    
    init(date: String, text: String, count: String) {
        self.date = date
        self.text = text
        self.count = count
    }
    
    init(model: ReceiptItem) {
        self.text = model.text
        self.count = ""
        self.date = dateFormatter.string(from: model.date)
    }
    
    func setup() {
        
    }
}
