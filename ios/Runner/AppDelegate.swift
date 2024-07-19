import Flutter
import UIKit
import flutter_local_notifications
import CoreMotion

struct DeviceMotionDataCodable: Codable {
    let readable: Double
    let quaternionX: Double
    let quaternionY: Double
    let quaternionZ: Double
    let quaternionW: Double
    let pitch: Double
    let roll: Double
    let yaw: Double
    let gravityX: Double
    let gravityY: Double
    let gravityZ: Double
    let rotationRateX: Double
    let rotationRateY: Double
    let rotationRateZ: Double
    let accelerationX: Double
    let accelerationY: Double
    let accelerationZ: Double

    init(deviceMotion: CMDeviceMotion) {
        readable = 1;
        quaternionX = deviceMotion.attitude.quaternion.x
        quaternionY = deviceMotion.attitude.quaternion.y
        quaternionZ = deviceMotion.attitude.quaternion.z
        quaternionW = deviceMotion.attitude.quaternion.w
        pitch = deviceMotion.attitude.pitch
        roll = deviceMotion.attitude.roll
        yaw = deviceMotion.attitude.yaw
        gravityX = deviceMotion.gravity.x
        gravityY = deviceMotion.gravity.y
        gravityZ = deviceMotion.gravity.z
        rotationRateX = deviceMotion.rotationRate.x
        rotationRateY = deviceMotion.rotationRate.y
        rotationRateZ = deviceMotion.rotationRate.z
        accelerationX = deviceMotion.userAcceleration.x
        accelerationY = deviceMotion.userAcceleration.y
        accelerationZ = deviceMotion.userAcceleration.z
    }

    init() {
        readable = 0;
        quaternionX = 0
        quaternionY = 0
        quaternionZ = 0
        quaternionW = 0
        pitch = 0
        roll = 0
        yaw = 0
        gravityX = 0
        gravityY = 0
        gravityZ = 0
        rotationRateX = 0
        rotationRateY = 0
        rotationRateZ = 0
        accelerationX = 0
        accelerationY = 0
        accelerationZ = 0
    }
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
//  let airpods = CMHeadphoneMotionManager()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
        GeneratedPluginRegistrant.register(with: registry)
    }
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
    GeneratedPluginRegistrant.register(with: self)

//    let controller = window?.rootViewController as! FlutterViewController
//          let channel: FlutterMethodChannel = FlutterMethodChannel(
//            name: "flutter.airpods.sensor",
//            binaryMessenger: controller.binaryMessenger)
//
//    channel.setMethodCallHandler({
//          [weak self] (methodCall: FlutterMethodCall, result: FlutterResult) -> Void in
//          if (methodCall.method == "getAirpodsSensorData") {
//              result(self?.getAirpodsSensorData())
//              return
//          }
//          result(FlutterMethodNotImplemented)
//      })
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

//  private func getAirpodsSensorData() -> Any {
////    airpods.delegate = self
//    if (airpods.isDeviceMotionAvailable) {
//        let motion = airpods.deviceMotion;
//        if (!airpods.isDeviceMotionActive) {
//            return 3
//        }
//        if (motion == nil) {
//            return 1
//        }
//        let encoder = JSONEncoder()
//        let deviceMotionData = DeviceMotionDataCodable(deviceMotion: motion!)
//        let jsonData = try? encoder.encode(deviceMotionData)
//
//        return jsonData;
//    } else {
//        return 2
//    }
//  }
}
