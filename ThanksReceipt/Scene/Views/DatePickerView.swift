//
//  DatePickerView.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/14.
//

import SwiftUI

struct DatePickerView<Style: DatePickerStyle>: View {
    @Binding var selection: Date
    var pickerStyle: Style
    var components: DatePickerComponents
    var onChange: ((Date) -> Void)
    
    var body: some View {
        DatePicker("", selection: $selection, in: ...Date(), displayedComponents: components)
            .datePickerStyle(pickerStyle)
            .environment(\.locale, Locale(identifier: "Ko"))
            .labelsHidden()
            .accentColor(.black)
            .frame(maxHeight: 300)
            .onChange(of: selection, perform: onChange)
    }
}

struct DatePickerView_Previews: PreviewProvider {
    static var previews: some View {
        DatePickerView(selection: .constant(Date()),
                       pickerStyle: DefaultDatePickerStyle(),
                       components: [.date],
                       onChange: { _ in })
    }
}
