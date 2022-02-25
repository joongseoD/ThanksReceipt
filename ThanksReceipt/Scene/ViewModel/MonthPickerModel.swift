//
//  MonthPickerModel.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/21.
//

import SwiftUI

protocol MonthPickerModelListener: AnyObject {
    func didSelectDate(_ date: Date)
}

protocol MonthPickerModelDependency {
    var currentDate: Date { get }
}

final class MonthPickerModel: ObservableObject {
    enum ViewState {
        case month
        case year
    }
    
    @Published var state: ViewState = .month
    @Published var selectedMonth: String = ""
    @Published var months: [String] = []
    @Published var selectedYear: String = ""
    @Published var years: [String] = []
    
    private var currentDate: Date {
        didSet {
            changeSelectedDate()
        }
    }
    
    private let yearFormatter = DateFormatter(format: .year)
    private let monthFormatter = DateFormatter(format: .shortMonth)
        
    private weak var listener: MonthPickerModelListener?
    
    init(dependency: MonthPickerModelDependency, listener: MonthPickerModelListener?) {
        self.currentDate = dependency.currentDate
        self.listener = listener
    }
    
    deinit {
        print("\(String(describing: self)) deinit")
    }
    
    private func changeSelectedDate() {
        selectedYear = yearFormatter.string(from: currentDate)
        selectedMonth = monthFormatter.string(from: currentDate)
    }
    
    private func setupMonth() {
        months = Array((1...12))
            .map { "\($0)" }
            .compactMap {
                let formatter = DateFormatter()
                formatter.dateFormat = "M"
                return formatter.date(from: $0)
            }
            .compactMap { monthFormatter.string(from: $0) }
    }
    
    private func setupYear() {
        years = Array((0..<12))
            .compactMap { Calendar.current.date(byAdding: .year, value: $0 * -1, to: Date()) }
            .compactMap { yearFormatter.string(from: $0) }
    }
    
    func didSelectMonth(_ month: String) {
        monthFormatter.defaultDate = currentDate
        currentDate = monthFormatter.date(from: month) ?? Date()
    }
    
    func didSelectYear(_ year: String) {
        yearFormatter.defaultDate = currentDate
        currentDate = yearFormatter.date(from: year) ?? Date()
    }
    
    func reset() {
        listener?.didSelectDate(Date())
    }
    
    func didTapComplete() {
        listener?.didSelectDate(currentDate)
    }
    
    func toggleViewState() {
        state = state == .month ? .year : .month
    }
    
    func didAppear() {
        changeSelectedDate()
        setupMonth()
        setupYear()
    }
}
