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
        SimpleEntry(date: Date(), score: 82, slouch: "5", turtle: "2", tilt: "7")
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
        VStack (alignment: .leading) {
            Text(String(entry.score)).foregroundColor(Color(hex: 0x236EF3))
                .font(.system(size: 35, weight: .bold))
                .offset(y: 10)
            ZStack (alignment: .leading) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: 0xD9D9D9))
                    .frame(width: CGFloat(110), height: 5)
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: 0x236EF3))
                    .frame(width: CGFloat(110*entry.score/100), height: 5)
            }.offset(y: -12)
            HStack {
                VStack {
                    Image("SlouchImg")
                        .resizable()
                          .frame(width: 35, height: 35)
                    Text(entry.slouch)
                        .foregroundColor(Color(hex: 0xF25959))
                        .font(.system(size: 20))
                }
                VStack {
                    Image("TurtleImg")
                        .resizable()
                          .frame(width: 35, height: 35)
                    Text(entry.turtle)
                        .foregroundColor(Color(hex: 0xF25959))
                        .font(.system(size: 20))
                }
                VStack {
                    Image("TiltImg")
                        .resizable()
                          .frame(width: 35, height: 35)
                    Text(entry.tilt)
                        .foregroundColor(Color(hex: 0xF25959))
                        .font(.system(size: 20))
                }
            }.offset(y: -10)
        }
        Text("Start")
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color(hex: 0x236EF3))
            .cornerRadius(10)
            .foregroundColor(Color.white)
            .font(.system(size: 12))
            .widgetURL(URL(string: "com.googleusercontent.apps.1055838194336-oobg73q1mtdons2sf5f1l8k13macdv7f://start"))
            .offset(y: -10)
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
        .configurationDisplayName("NeckLife Widget")
        .description("This shows basic your today posture stats.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    NeckLIfeWidget()
} timeline: {
    SimpleEntry(date: .now, score: 0, slouch: "0", turtle: "0", tilt: "0")
//    SimpleEntry(date: .now, score: 0, slouch: "0", turtle: "0", tilt: "0")
}
