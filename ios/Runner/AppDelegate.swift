import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let batteryChannel = FlutterEventChannel(name: "com.example.queue_manager/sensor",
                                              binaryMessenger: controller.binaryMessenger)
    batteryChannel.setStreamHandler(TemperatureStreamHandler())
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

class TemperatureStreamHandler: NSObject, FlutterStreamHandler {
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
            self?.sendTemperature()
        }
    }
    
    private func stopReporting() {
        timer?.invalidate()
        timer = nil
    }
    
    private func sendTemperature() {
        // Map thermal state to mock temperature values
        let state = ProcessInfo.processInfo.thermalState
        var temp = 30.0
        
        switch state {
        case .nominal:
            temp = 35.0
        case .fair:
            temp = 45.0
        case .serious:
            temp = 65.0
        case .critical:
            temp = 85.0
        @unknown default:
            temp = 30.0
        }
        
        // Add a bit of jitter to make it look alive
        temp += Double.random(in: -1.0...1.0)
        
        eventSink?(temp)
    }
}
