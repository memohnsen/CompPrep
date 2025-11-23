//
//  CompPrepLiveActionLiveActivity.swift
//  CompPrepLiveAction
//
//  Created by Maddisen Mohnsen on 11/23/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

func formatTime(_ seconds: Int) -> String {
    let minutes = seconds / 60
    let secs = seconds % 60
    return String(format: "%d:%02d", minutes, secs)
}

struct CompPrepLiveActionAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var currentSetNumber: Int
        var currentRestTime: Int
        var totalRestTime: Int
        var nextRestTime: Int?
    }

    // Fixed non-changing properties about your activity go here!
    var totalSets: Int
}

struct CompPrepLiveActionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CompPrepLiveActionAttributes.self) { context in
            // Lock screen/banner UI
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 6)
                    Circle()
                        .trim(from: 0, to: CGFloat(context.state.currentRestTime) / CGFloat(context.state.totalRestTime))
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    
                    Text(formatTime(context.state.currentRestTime))
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .monospacedDigit()
                }
                .frame(width: 70, height: 70)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("REST TIME")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .opacity(0.7)
                    
                    Text("Set \(context.state.currentSetNumber) of \(context.attributes.totalSets)")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                            let remaining = context.attributes.totalSets - context.state.currentSetNumber
                            if remaining == 0 {
                                Text("Final set!")
                                    .font(.caption)
                            } else {
                                Text("\(remaining) \(remaining == 1 ? "set" : "sets") remaining")
                                    .font(.caption)
                            }
                        }
                        
                        if context.state.currentSetNumber < context.attributes.totalSets {
                            HStack(spacing: 4) {
                                Text("Up Next:")
                                    .font(.caption)
                                    .opacity(0.7)
                                Text(formatTime(context.state.nextRestTime ?? 0))
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .opacity(0.8)
                }
                
                Spacer()
            }
            .foregroundStyle(.white)
            .padding()
            .activityBackgroundTint(Color.blue)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("SET")
                            .font(.caption2)
                            .opacity(0.7)
                        Text("\(context.state.currentSetNumber)/\(context.attributes.totalSets)")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .padding(.leading, 4)
                    .padding(.top)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("REMAINING")
                            .font(.caption2)
                            .opacity(0.7)
                        Text(formatTime(context.state.currentRestTime))
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .monospacedDigit()
                    }
                    .padding(.trailing, 4)
                    .padding(.top)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
                        ProgressView(value: Float(context.state.currentRestTime), total: Float(context.state.totalRestTime))
                            .tint(.white)
                        
                        HStack {
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .foregroundStyle(.orange)
                                let remaining = context.attributes.totalSets - context.state.currentSetNumber
                                if remaining == 0 {
                                    Text("Final set!")
                                        .font(.caption)
                                        .opacity(0.8)
                                } else {
                                    Text("\(remaining) \(remaining == 1 ? "set" : "sets") remaining")
                                        .font(.caption)
                                        .opacity(0.8)
                                }
                            }
                            
                            Spacer()
                            
                            if context.state.currentSetNumber < context.attributes.totalSets {
                                HStack(spacing: 4) {
                                    Text("Up Next:")
                                        .font(.caption)
                                        .opacity(0.7)
                                    Text(formatTime(context.state.nextRestTime ?? 0))
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                    .padding(.top, 4)
                }
            } compactLeading: {
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .foregroundStyle(.blue)
                    Text("\(context.state.currentSetNumber)/\(context.attributes.totalSets)")
                        .fontWeight(.semibold)
                }
            } compactTrailing: {
                Text(formatTime(context.state.currentRestTime))
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(.blue)
            } minimal: {
                ZStack {
                    Circle()
                        .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                    Circle()
                        .trim(from: 0, to: CGFloat(context.state.currentRestTime) / CGFloat(context.state.totalRestTime))
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                }
            }
        }
    }
}

extension CompPrepLiveActionAttributes {
    fileprivate static var preview: CompPrepLiveActionAttributes {
        CompPrepLiveActionAttributes(totalSets: 5)
    }
}

extension CompPrepLiveActionAttributes.ContentState {
    fileprivate static var sample: CompPrepLiveActionAttributes.ContentState {
        CompPrepLiveActionAttributes.ContentState(
            currentSetNumber: 5,
            currentRestTime: 70,
            totalRestTime: 180,
            nextRestTime: 60
        )
    }
}

#Preview("Notification", as: .content, using: CompPrepLiveActionAttributes.preview) {
   CompPrepLiveActionLiveActivity()
} contentStates: {
    CompPrepLiveActionAttributes.ContentState.sample
}
