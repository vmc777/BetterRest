//
//  ContentView.swift
//  BetterRest
//
//  Created by VerDel on 5/4/22.
//
import CoreML
import SwiftUI

struct ContentView: View {
  @State private var wakeUp = ContentView.defaultWakeTime
  @State private var desiredSleepDuration = 8.0
  @State private var coffeeAmount = 1
  @State private var alertTitle = ""
  @State private var alertMessage = ""
  @State private var showingAlert = false

  static private var defaultWakeTime: Date {
    var components = DateComponents()
    components.hour = 7
    components.minute = 0 
    return Calendar.current.date(from: components) ?? Date.now
  }

  var calculatedBedtime: String {
    do {
      let sleepTime = try calculateBedtime()
      return sleepTime.formatted(date: .omitted, time: .shortened)
    } catch {
      alertTitle = "Error"
      alertMessage = "Sorry, there was a problem calculating your bedtime."
      showingAlert = true
    }
    return "unknown"
  }

  var body: some View {
    NavigationView {
      Form {
        Section {
          DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
            .labelsHidden()
        } header: {
          Text("When do you want to wake up?")
            .font(.headline)
        }
        Section {
          Stepper("\(desiredSleepDuration.formatted()) hours", value: $desiredSleepDuration, in: 4 ... 12, step: 0.25)
        } header: {
          Text("Desired amount of sleep")
            .font(.headline)
        }
        Section {
          Picker("Cup(s)", selection: $coffeeAmount) {
            ForEach(1 ..< 21) {
              Text("\($0)")
            }
          }
        } header: {
          Text("Daily coffee intake")
            .font(.headline)
        }
        
        Section {
          Text(calculatedBedtime)
            .font(.title)
        } header: {
          Text("You're ideal bedtime")
        }
      }
      .navigationTitle("BetterRest")
//      .toolbar {
//        Button("Calculate", action: calculateBedtime)
//      }
      .alert(alertTitle, isPresented: $showingAlert) {
        Button("OK") {}
      } message: {
        Text(alertMessage)
      }
    }
  }

  func calculateBedtime() throws -> Date {
    // do {
    let model = try SleepCalculator(configuration: MLModelConfiguration())
    let prediction = try model.prediction(
      wake: getSecondsUntilWakeUp(),
      estimatedSleep: desiredSleepDuration,
      coffee: Double(coffeeAmount)
    )
    return wakeUp - prediction.actualSleep
  }

  func getSecondsUntilWakeUp() -> Double {
    let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
    let hourSeconds = (components.hour ?? 0) * 60 * 60
    let minuteSeconds = (components.minute ?? 0) * 60
    return Double(hourSeconds + minuteSeconds)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
