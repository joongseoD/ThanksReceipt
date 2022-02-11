//
//  ReceiptInputModel.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/08.
//

import SwiftUI
import Combine

protocol ReceiptInputModelDependency {
    var provider: DataProviding { get }
}

struct ReceiptInputModelComponents: ReceiptInputModelDependency {
    var provider: DataProviding = DataProvider()
    // TODO: - Scheduler
}

protocol ReceiptInputModelListener: AnyObject {
    func didSaveRecipt(_ item: ReceiptItem)
}

final class ReceiptInputModel: ObservableObject {
    @Published private(set) var errorMessage: String = ""
    @Published private(set) var textCount: String = ""
    @Published private(set) var dateString: String = ""
    @Published var date: Date = Date() {
        didSet {
            dateString = dateFormatter.string(from: date)
        }
    }
    @Published var text: String = "" {
        didSet {
            if text.count > maxCount {
                DispatchQueue.main.async {
                    self.text = String(self.text.prefix(self.maxCount))
                }
                Haptic.trigger(.medium)
            } else {
                Haptic.trigger(.soft)
            }

            textCount = "\(text.count)/\(maxCount)"
        }
    }
    
    private var provider: DataProviding
    private let maxCount: Int = 20
    private var cancellables = Set<AnyCancellable>()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 (E)"
        formatter.locale = Locale(identifier: "Ko")
        return formatter
    }()
    
    private weak var listener: ReceiptInputModelListener?
    
    init(dependency: ReceiptInputModelDependency = ReceiptInputModelComponents(), listener: ReceiptInputModelListener?) {
        self.provider = dependency.provider
        self.listener = listener
        textCount = "\(text.count)/\(maxCount)"
        dateString = dateFormatter.string(from: date)
    }
    
    deinit {
        print("\(String(describing: self)) deinit")
    }
    
    func saveReceipt() -> Bool {
        guard text.isEmpty == false else { return false }
        let receiptItem = ReceiptItem(text: text, date: date)
        do {
            try provider.create(receiptItem: receiptItem)
            listener?.didSaveRecipt(receiptItem)
        } catch {
            errorMessage = "생성 에러\n\(error.localizedDescription)"
        }
        return true
    }
    
}
