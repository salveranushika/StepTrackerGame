import Foundation
import HealthKit
import CoreMotion

class HealthManager: ObservableObject {
    @Published var stepsToday: Int = 0
    @Published var stepsYesterday: Int = 0
    @Published var currentActivity: String = "Unknown"
    @Published var goalMet: Bool = false
    
    private let healthStore = HKHealthStore()
    private let pedometer = CMPedometer()
    private let activityManager = CMMotionActivityManager()
    private var dailyGoal: Int = 100
    
    init() {
        requestAuthorization()
        startRealTimeUpdates()
        startActivityTracking()
        fetchYesterdayStepsData()
    }
    
    func setDailyGoal(_ goal: Int) {
        dailyGoal = goal
        checkGoalStatus()
    }
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data is not available on this device.")
            return
        }
        
        let typesToShare: Set = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
        ]
        
        let typesToRead: Set = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
        ]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            if success {
                self.fetchStepsData()
            } else {
                print("Authorization failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func fetchStepsData() {
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let startOfDay = Calendar.current.startOfDay(for: Date())
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                DispatchQueue.main.async {
                    self.stepsToday = 0
                    self.goalMet = false
                }
                return
            }
            
            DispatchQueue.main.async {
                self.stepsToday = Int(sum.doubleValue(for: HKUnit.count()))
                self.checkGoalStatus()
            }
        }
        
        healthStore.execute(query)
    }

    func fetchYesterdayStepsData() {
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let startOfYesterday = Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.startOfDay(for: Date()))!
        let endOfYesterday = Calendar.current.startOfDay(for: Date())
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfYesterday, end: endOfYesterday, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                DispatchQueue.main.async {
                    self.stepsYesterday = 0
                }
                return
            }
            
            DispatchQueue.main.async {
                self.stepsYesterday = Int(sum.doubleValue(for: HKUnit.count()))
            }
        }
        
        healthStore.execute(query)
    }
    
    func startRealTimeUpdates() {
        guard CMPedometer.isStepCountingAvailable() else { return }
        
        pedometer.startUpdates(from: Date()) { data, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                self.stepsToday = data.numberOfSteps.intValue
                self.checkGoalStatus()
            }
        }
    }
    
    func startActivityTracking() {
        guard CMMotionActivityManager.isActivityAvailable() else { return }
        
        activityManager.startActivityUpdates(to: .main) { activity in
            DispatchQueue.main.async {
                if let activity = activity {
                    if activity.walking {
                        self.currentActivity = "Walking"
                    } else if activity.running {
                        self.currentActivity = "Running"
                    } else if activity.cycling {
                        self.currentActivity = "Cycling"
                    } else if activity.automotive {
                        self.currentActivity = "Driving"
                    } else if activity.stationary {
                        self.currentActivity = "Still"
                    } else {
                        self.currentActivity = "Unknown"
                    }
                } else {
                    self.currentActivity = "Unknown"
                }
            }
        }
    }
    
   
    private func checkGoalStatus() {
        goalMet = stepsToday >= dailyGoal
    }
    
    func resetAllData() {
        stepsToday = 0
        stepsYesterday = 0
        currentActivity = "Unknown"
        goalMet = false 
    }
}
