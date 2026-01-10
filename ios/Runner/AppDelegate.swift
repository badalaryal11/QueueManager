import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let resourceChannel = FlutterEventChannel(name: "com.example.queue_manager/resources",
                                              binaryMessenger: controller.binaryMessenger)
    resourceChannel.setStreamHandler(ResourceStreamHandler())
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

class ResourceStreamHandler: NSObject, FlutterStreamHandler {
    private var timer: Timer?
    private var eventSink: FlutterEventSink?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        startReporting()
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        stopReporting()
        return nil
    }
    
    private func startReporting() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.sendResources()
        }
    }
    
    private func stopReporting() {
        timer?.invalidate()
        timer = nil
    }
    
    private func sendResources() {
        let cpu = getCpuUsage()
        let ram = getMemoryUsage()
        
        let data: [String: Double] = [
            "cpu": cpu,
            "ram": ram
        ]
        
        eventSink?(data)
    }
    
    // --- Helper Methods ---
    
    private func getMemoryUsage() -> Double {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            // Memory used by this app in bytes
            let usedBytes = Double(taskInfo.resident_size)
            // Total physical memory
            let totalBytes = Double(ProcessInfo.processInfo.physicalMemory)
            // Return % of total system memory used by app (approximation for 'Load')
            // Or we could return absolute % if we want System Load?
            // iOS sandboxes system load. Let's return App Memory Usage relative to Total to show *some* metric.
            return (usedBytes / totalBytes) * 100.0
        }
        return 0.0
    }
    
    private func getCpuUsage() -> Double {
        var totalUsageOfCPU: Double = 0.0
        var threadsList: thread_act_array_t?
        var threadsCount = mach_msg_type_number_t(0)
        let threadsResult = task_threads(mach_task_self_, &threadsList, &threadsCount)
        
        if threadsResult == KERN_SUCCESS {
            if let threadsList = threadsList {
                for i in 0..<threadsCount {
                    var threadInfo = thread_basic_info()
                    var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
                    let infoResult = withUnsafeMutablePointer(to: &threadInfo) {
                        $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                            thread_info(threadsList[Int(i)], thread_flavor_t(THREAD_BASIC_INFO), $0, &threadInfoCount)
                        }
                    }
                    
                    if infoResult == KERN_SUCCESS {
                        let threadBasicInfo = threadInfo as thread_basic_info
                        if (threadBasicInfo.flags & TH_FLAGS_IDLE) == 0 {
                            totalUsageOfCPU = totalUsageOfCPU + Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE) * 100.0
                        }
                    }
                }
            }
            
            // Deallocate threads list
             vm_deallocate(mach_task_self_, vm_address_t(UInt(bitPattern: threadsList)), vm_size_t(Int(threadsCount) * MemoryLayout<thread_t>.stride))
        }
        
        return totalUsageOfCPU
    }
}
