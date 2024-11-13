import Foundation

class UserSettings: ObservableObject {
    @Published var dailyGoal: Int {
        didSet {
            UserDefaults.standard.set(dailyGoal, forKey: "DailyGoal")
        }
    }
    
    init() {
        self.dailyGoal = UserDefaults.standard.integer(forKey: "DailyGoal")
    }
    
    func resetData() {
        dailyGoal = 0
    }
}
