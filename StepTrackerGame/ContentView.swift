import SwiftUI

struct ContentView: View {
    @StateObject private var healthManager = HealthManager()
    @ObservedObject private var userSettings = UserSettings()
    @State private var dailyGoalInput: String = ""
    @State private var showGameUnlockedAlert = false

 
    private var activityColor: Color {
        switch healthManager.currentActivity {
        case "Walking":
            return .green
        case "Running":
            return .orange
        case "Cycling":
            return .blue
        case "Driving":
            return .purple
        case "Still":
            return .gray
        default:
            return .red
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
               
                HStack(alignment: .top, spacing: 4) {
                    Text("Step")
                        .font(Font.custom("Inter", size: 52).weight(.semibold))
                        .foregroundColor(.red)
                    Text("Tracker")
                        .font(Font.custom("Inter", size: 52).weight(.semibold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    Text("v1.0")
                        .font(Font.custom("Inter", size: 14))
                        .foregroundColor(.gray)
                        .padding(.top, 14)
                        .opacity(0.8)
                }
                .padding(.horizontal)

                
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.1)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 200, height: 200)
                        .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 10)
                    
                    VStack {
                        let percentage = (userSettings.dailyGoal != 0) ? Double(healthManager.stepsToday) / Double(userSettings.dailyGoal) * 100 : 0
                        Text("\(Int(percentage))%")
                            .font(Font.custom("Inter", size: 72).weight(.bold))
                            .foregroundColor(.black)
                            .transition(.scale)
                        Text("Goal")
                            .font(Font.custom("Inter", size: 28))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 10)

                
                HStack(spacing: 25) {
                    MetricCardView(title: "Today", value: "\(healthManager.stepsToday)", unit: "Steps")
                    MetricCardView(title: "Yesterday", value: "\(healthManager.stepsYesterday)", unit: "Steps")
                }
                
                HStack(spacing: 25) {
                    MetricCardView(title: "Daily Goal", value: "\(userSettings.dailyGoal)", unit: "Steps")
                    
                    
                    VStack {
                        Text("Current Activity")
                            .font(Font.custom("Inter", size: 24))
                            .foregroundColor(.black)
                        Text(healthManager.currentActivity)
                            .font(Font.custom("Inter", size: 40))
                            .foregroundColor(activityColor)
                            .shadow(color: activityColor.opacity(0.4), radius: 4, x: 0, y: 3)
                    }
                    .frame(width: 180, height: 120)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 8)
                }

                
                HStack {
                    TextField("Enter Goal", text: $dailyGoalInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 120)
                        .keyboardType(.numberPad)
                        .onTapGesture {
                            hideKeyboardOnTapOutside()
                        }
                    
                    Button(action: {
                        if let goal = Int(dailyGoalInput) {
                            userSettings.dailyGoal = goal
                            dailyGoalInput = ""
                            hideKeyboard()
                        }
                    }) {
                        Text("Set Goal")
                            .padding(12)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.gray.opacity(0.15)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(10)
                            .foregroundColor(.blue)
                            .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 3)
                            .scaleEffect(dailyGoalInput.isEmpty ? 1.0 : 1.05)
                    }
                    
                    Button(action: {
                        healthManager.resetAllData()
                        userSettings.resetData()
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .padding(12)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(10)
                            .shadow(color: Color.red.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                }
                
                Spacer()
                
                
                if healthManager.stepsToday >= userSettings.dailyGoal && userSettings.dailyGoal != 0 {
                    Button(action: {
                        showGameUnlockedAlert = true
                    }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                            Text("Play Game")
                                .font(.title3)
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(25)
                        .shadow(color: Color.green.opacity(0.4), radius: 8, x: 0, y: 5)
                    }
                    .scaleEffect(1.1)
                    .offset(y: -50)
                    .alert(isPresented: $showGameUnlockedAlert) {
                        Alert(
                            title: Text("Goal Reached!"),
                            message: Text("You've reached your step goal! Tap to play the game."),
                            primaryButton: .default(Text("Play")) {
                                
                                let gameView = MazeRunnerGameView()
                                UIApplication.shared.windows.first?.rootViewController?.present(UIHostingController(rootView: gameView), animated: true, completion: nil)
                            },
                            secondaryButton: .cancel(Text("Later"))
                        )
                    }
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .navigationBarHidden(true)
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
}


struct MetricCardView: View {
    var title: String
    var value: String
    var unit: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(Font.custom("Inter", size: 24))
                .foregroundColor(.black)
            Text(value)
                .font(Font.custom("Inter", size: 40))
                .bold()
            Text(unit)
                .font(Font.custom("Inter", size: 14))
                .foregroundColor(.gray)
        }
        .frame(width: 180, height: 120)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}


extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func hideKeyboardOnTapOutside() {
        DispatchQueue.main.async {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
