//
//  NeckLIfeWidget.swift
//  NeckLIfeWidget
//
//  Created by 안유성 on 10/23/24.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), score: 0, slouch: "0", turtle: "0", tilt: "0")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry: SimpleEntry
        if context.isPreview{
            entry = placeholder(in: context)
        }
        else{
            //      Get the data from the user defaults to display
            let userDefaults = UserDefaults(suiteName: "group.necklifewidget")
          let score = userDefaults?.integer(forKey: "score") ?? 0
            let slouch = userDefaults?.string(forKey: "slouch") ?? "0"
            let turtle = userDefaults?.string(forKey: "turtle") ?? "0"
            let tilt = userDefaults?.string(forKey: "tilt") ?? "0"
            
            
            
            entry = SimpleEntry(date: Date(), score: score, slouch: slouch, turtle: turtle, tilt: tilt)
          }
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    //      This just uses the snapshot function you defined earlier
          getSnapshot(in: context) { (entry) in
    // atEnd policy tells widgetkit to request a new entry after the date has passed
            let timeline = Timeline(entries: [entry], policy: .atEnd)
                      completion(timeline)
                  }
        }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let score: Int
    let slouch: String
    let turtle: String
    let tilt: String
}

extension Color {
    init(hex: Int, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: opacity
        )
    }
}

struct NeckLIfeWidgetEntryView : View {
    var entry: Provider.Entry
    

    var body: some View {
        VStack {
            Text(String(entry.score)).foregroundColor(Color(hex: 0x236EF3))
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: 0x236EF3))
                    .frame(width: CGFloat(100*entry.score/100), height: 5)
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: 0xD9D9D9))
                    .frame(width: CGFloat(100*entry.score/100), height: 5)
            }
        }
    }
}

struct NeckLIfeWidget: Widget {
    let kind: String = "NeckLIfeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                NeckLIfeWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                NeckLIfeWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    NeckLIfeWidget()
} timeline: {
    SimpleEntry(date: .now, score: 0, slouch: "0", turtle: "0", tilt: "0")
    SimpleEntry(date: .now, score: 0, slouch: "0", turtle: "0", tilt: "0")
}
