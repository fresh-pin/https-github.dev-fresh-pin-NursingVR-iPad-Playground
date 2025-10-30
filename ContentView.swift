import SwiftUI
import SceneKit
import CoreMotion
import UIKit

struct ContentView: View {
    @State private var motion = CMMotionManager()
    @State private var cameraNode = SCNNode()
    @State private var scene: SCNScene = SCNScene()

    var body: some View {
        SceneView(
            scene: scene,
            pointOfView: cameraNode,
            options: [.allowsCameraControl]
        )
        .ignoresSafeArea()
        .onAppear {
            setupScene()
            startMotion()
        }
    }

    private func setupScene() {
        scene = SCNScene()

        // โหลดภาพ 360° จาก Resources
        if let img = UIImage(named: "hospital_room.jpg") {
            let sphere = SCNSphere(radius: 10)
            let mat = SCNMaterial()
            mat.diffuse.contents = img
            mat.isDoubleSided = true
            sphere.firstMaterial = mat

            let node = SCNNode(geometry: sphere)
            scene.rootNode.addChildNode(node)
        } else {
            // ถ้าไม่เจอภาพ ใช้สีเทาแทน
            let sphere = SCNSphere(radius: 10)
            sphere.firstMaterial?.diffuse.contents = UIColor.darkGray
            sphere.firstMaterial?.isDoubleSided = true
            scene.rootNode.addChildNode(SCNNode(geometry: sphere))
        }

        // กล้อง
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Zero
        scene.rootNode.addChildNode(cameraNode)
    }

    private func startMotion() {
        motion.deviceMotionUpdateInterval = 1.0 / 60.0
        if motion.isDeviceMotionAvailable {
            motion.startDeviceMotionUpdates(to: .main) { data, _ in
                guard let attitude = data?.attitude else { return }
                cameraNode.eulerAngles = SCNVector3(
                    Float(-attitude.pitch),
                    Float(attitude.yaw),
                    Float(attitude.roll)
                )
            }
        }
    }
}

#Preview {
    ContentView()
}