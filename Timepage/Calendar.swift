import SwiftUI

fileprivate extension DateFormatter {
    static var month: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter
    }
    
    static var monthAndYear: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
}

fileprivate extension Calendar {
    func generateDates(
        inside interval: DateInterval,
        matching components: DateComponents
    ) -> [Date] {
        var dates: [Date] = []
        dates.append(interval.start)
        
        enumerateDates(
            startingAfter: interval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            if let date = date {
                if date < interval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }
        
        return dates
    }
}

struct WeekView<DateView>: View where DateView: View {
    @Environment(\.calendar) var calendar
    
    let week: Date
    let content: (Date) -> DateView
    
    
    init(week: Date, @ViewBuilder content: @escaping (Date) -> DateView) {
        self.week = week
        self.content = content
    }
    
    private var days: [Date] {
        guard
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: week)
        else { return [] }
        return calendar.generateDates(
            inside: weekInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
    }
    
    var body: some View {
        HStack {
            ForEach(days, id: \.self) { date in
                HStack {
                    if self.calendar.isDate(self.week, equalTo: date, toGranularity: .month) {
                        self.content(date)
                    } else {
                        self.content(date).opacity(0.1)
                    }
                }
            }
        }
    }
}

struct MonthView<DateView>: View where DateView: View {
    @Environment(\.calendar) var calendar
    @EnvironmentObject var parameters: appParameters
    
    
    
    let month: Date
    let showHeader: Bool
    let content: (Date) -> DateView
    
    
    init(
        month: Date,
        showHeader: Bool = true,
        @ViewBuilder content: @escaping (Date) -> DateView
    ) {
        self.month = month
        self.content = content
        self.showHeader = showHeader
    }
    
    private var weeks: [Date] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: month)
        else { return [] }
        return calendar.generateDates(
            inside: monthInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0, weekday: calendar.firstWeekday)
        )
    }
    
    private var header: some View {
        let component = calendar.component(.month, from: month)
        let formatter = component == 1 ? DateFormatter.monthAndYear : .month
        return Text(formatter.string(from: month))
            .font(.title)
            .padding()
    }
    
    var body: some View {
        
        
        VStack(alignment: .leading) {
            HStack{
                VStack(alignment: .leading){
                    Text("\(month.format("MMMM").uppercased())").font(.largeTitle).fontWeight(.medium)
                        .kerning(3)
                    Text("\(month.format("yyyy"))").font(.title3).fontWeight(.light)
                        .opacity(0.4)
                }.foregroundColor(isCurrentMonth() ? parameters.highlightColor : .white)
                //                Image(systemName: "arrow.uturn.backward").foregroundColor(parameters.highlightColor)
            }
            
            HStack{
                self.content(Date()).hidden().overlay(Text("S"))
                self.content(Date()).hidden().overlay(Text("M"))
                self.content(Date()).hidden().overlay(Text("T"))
                self.content(Date()).hidden().overlay(Text("W"))
                self.content(Date()).hidden().overlay(Text("T"))
                self.content(Date()).hidden().overlay(Text("F"))
                self.content(Date()).hidden().overlay(Text("S"))
            }.foregroundColor(.white)
            ForEach(weeks, id: \.self) { week in
                WeekView(week: week, content: self.content)
            }
            
            ZStack{
                if parameters.selectedDate != nil{
                    DayOverView(underMonth: month)
                        .transition(.asymmetric(insertion: .offset(x: 0, y: 10), removal: .opacity))
                }
            }.animation(.easeInOut(duration: 0.2)).frame(minHeight: 200, alignment: .top)
        }
        
        
    }
    func isCurrentMonth()-> Bool{
        return self.calendar.isDate(month, equalTo: Date(), toGranularity: .month)
    }
    
    
}

struct CalendarView<DateView>: View where DateView: View {
    @Environment(\.calendar) var calendar
    
    let interval: DateInterval
    let content: (Date) -> DateView
    
    init(interval: DateInterval, @ViewBuilder content: @escaping (Date) -> DateView) {
        self.interval = interval
        self.content = content
    }
    
    private var months: [Date] {
        calendar.generateDates(
            inside: interval,
            matching: DateComponents(day: 1, hour: 0, minute: 0, second: 0)
        )
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                ForEach(months, id: \.self) { month in
                    MonthView(month: month, content: self.content)
                }
            }
        }
    }
}

struct RootView: View {
    @Environment(\.calendar) var calendar
    
    private var year: DateInterval {
        calendar.dateInterval(of: .year, for: Date())!
    }
    
    var body: some View {
        CalendarView(interval: year) { date in
            Text("30")
                .hidden()
                .padding(8)
                .background(Color.blue)
                .clipShape(Circle())
                .padding(.vertical, 4)
                .overlay(
                    Text(String(self.calendar.component(.day, from: date)))
                )
        }
    }
}
