//
//  DateFormatter+Extensions.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/25.
//

import Foundation

extension DateFormatter {
    enum FormatType {
        case longMonth
        case shortMonth
        case longMonthDayWeek
        case shortMonthDayWeek
        case year
        case yearMonthDay
        
        var string: String {
            switch self {
            case .longMonth: return "MMMM"
            case .shortMonth: return "MMM"
            case .longMonthDayWeek: return "M월 d일 (E)"
            case .shortMonthDayWeek: return "M/d(E)"
            case .year: return "yyyy"
            case .yearMonthDay: return "yyyy.MM.dd"
            }
        }
        
        var localeIdentifier: String {
            switch self {
            case .longMonth: return "En"
            case .shortMonth: return "En"
            case .longMonthDayWeek: return "Ko"
            case .shortMonthDayWeek: return "Ko"
            case .year: return "En"
            case .yearMonthDay: return "Ko"
            }
        }
    }

    convenience init(format: FormatType, localeIdentifier: String? = nil) {
        self.init()
        self.dateFormat = format.string
        self.locale = Locale(identifier: localeIdentifier ?? format.localeIdentifier)
    }
}
