//
//  ContentView.swift
//  Detecting
//
//  Created by Joel Huggett on 2024-01-27.
//

import ARKit
import RealityKit
import SwiftUI
import SceneKit
import Combine

class ScannedIndicator: Entity, HasModel, HasCollision {
    var hits = 1.0
    var mat: UnlitMaterial
    
    var boundAnchor: AnchorEntity?
    func setAnchor(anchor: AnchorEntity) {
        self.boundAnchor = anchor
        anchor.addChild(self)
    }
    func removeAnchor() {
        self.anchor?.removeFromParent()
    }
    
    func hit() {
        print("HIT")
        self.hits += 1
        
        var mat = UnlitMaterial(color: UIColor(red: 0, green: self.hits / 5, blue: 1 / self.hits, alpha: 1))
        mat.blending = .transparent(opacity: PhysicallyBasedMaterial.Opacity(floatLiteral: Float(0.1 * self.hits)))
        
        self.components[ModelComponent] = ModelComponent(
            mesh: .generatePlane(width: 0.25, depth: 0.25, cornerRadius: 3.14),
            materials: [mat]
        )
    }
    
    required init() {
        var mat = UnlitMaterial(color: UIColor(red: 0, green: 0, blue: 1, alpha: 1))
        mat.blending = .transparent(opacity: 0.1)
        self.mat = mat
        super.init()
        self.components[ModelComponent] = ModelComponent(
            mesh: .generatePlane(width: 0.25, depth: 0.25, cornerRadius: 3.14),
            materials: [mat]
        )
        
        self.generateCollisionShapes(recursive: true)
    }
}

struct RealityKitView: UIViewRepresentable {
    @Binding var arView: ARView
    
    
    
    func makeUIView(context: Context) -> ARView {
        
        let session = arView.session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        
        // config.initialWorldMap =
        
        session.run(config)
        
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = session
        coachingOverlay.goal = .horizontalPlane
        arView.addSubview(coachingOverlay)
    
        
        
        
        #if DEBUG
        arView.debugOptions = [.showStatistics]
        #endif
        
        return arView
    }
    
    
    
    
    func updateUIView(_ uiView: ARView, context: Context) {
        print("updateUIView")
        
        
        
        
        
    }
}

struct ContentView: View {
    var locationManager = LocationDataManager()
    
    @State private var arView = ARView(frame: .zero)
    
    
    @State private var lastHitScannedSpot: ScannedIndicator? = nil
    
    @State private var scannedIndicators: [ScannedIndicator] = []
    
    var worldMapURL: URL = {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("worldMapURL")
        } catch {
            fatalError("Error getting world map URL from document directory.")
        }
    }()
    
    func archive(worldMap: ARWorldMap) throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
        try data.write(to: self.worldMapURL, options: [.atomic])
    }
    
    var body: some View {
        VStack {
            RealityKitView(arView: $arView)
                .ignoresSafeArea()
            Button(action: toggleCasting) {
                Text(self.timer == nil ? "ON" : "OFF")
            }
            Text("Spots: " + String(scannedIndicators.count))
            HStack {
                Button(action: save) {
                    Text("Save")
                }
                Button(action: load) {
                    Text("Load")
                }
                Button(action: clear) {
                    Text("Clear")
                }
            }
        }
    }
    
    func save() {
        arView.session.getCurrentWorldMap { ARWorldMap, error in
            guard let worldMap = ARWorldMap else {
                print("Failed to get world map")
                print(error?.localizedDescription)
                return
            }
            
//            // Add a snapshot image indicating where the map was captured.
//                guard let snapshotAnchor = SnapshotAnchor(capturing: self.sceneView)
//                    else { fatalError("Can't take snapshot") }
//                map.anchors.append(snapshotAnchor)
//            
//
            
            do {
                print("anchorCount: ", worldMap.anchors.count)
                try self.archive(worldMap: worldMap)
                print("saving map")
            } catch {
                fatalError("Error saving world map: \(error.localizedDescription)")
            }
        }
    }
    
    func retrieveWorldMapData() -> Data? {
        do {
            return try Data(contentsOf: self.worldMapURL)
        } catch {
            print("Error retrieving world map data.")
            return nil
        }
    }
    
    func unarchive(worldMapData data: Data) -> ARWorldMap? {
        do {
            let unarchievedObject = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data)
            
            guard let worldMap = unarchievedObject else { return nil }
            print("unarchived")
            return worldMap
        } catch {
                
            print("failed unarchive")
            return nil
        }
    }
    
    
    func load() {
        guard let data = retrieveWorldMapData() else {
            print("Failed to get world data, not loading")
            return
        }
        print("got data")
        let worldMap = unarchive(worldMapData: data)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        
        config.initialWorldMap = worldMap
        
        arView.session.run(config, options: [.removeExistingAnchors, .resetTracking])
        print("Loaded")
        print("anchorCount: ", worldMap?.anchors.count)
        
        // guard let anchors = worldMap?.anchors else {return}
        guard let anchors = arView.session.currentFrame?.anchors else {return}
        
        
        for anchor in anchors {
            if anchor.name == "Scanned" {
                print("found a scanned archor")
                
                let anchorEntity = AnchorEntity(anchor: anchor)
                
                let scannedSpot = ScannedIndicator()
                
                anchorEntity.name = "Scanned"
                scannedSpot.name = "Scanned"

                arView.session.add(anchor: anchor)
                
                scannedSpot.setAnchor(anchor: anchorEntity)
                arView.scene.addAnchor(anchorEntity)
                
                scannedIndicators.append(scannedSpot)
                
                
//                let scannedSpot = ScannedIndicator()
//                scannedSpot.name = "Scanned"
//                
//                let anchorEntity = AnchorEntity(anchor: anchor)
//                
//                scannedSpot.setAnchor(anchor: anchorEntity)
//                
//                arView.scene.addAnchor(anchorEntity)
//                
//                scannedIndicators.append(scannedSpot)
            } else {
                print("other anchor: ", anchor)
            }
        }
        
        print("Loaded scanned spots: ", scannedIndicators.count)
    }
    
    func clear() {
        for spot in scannedIndicators {
            spot.removeFromParent()
            spot.removeAnchor()
        }
        scannedIndicators = []
        print("Cleared")
    }
    
    @State private var timer: Optional<AnyCancellable> = nil
    func toggleCasting() {
        
        if timer == nil {
            timer = Timer.publish(every: 1 / 30, on: .main, in: .common)
                .autoconnect()
                .sink(receiveValue: { _ in
                    self.raycasting()
                })
        } else {
            timer!.cancel()
            timer = nil
        }
        
        
    }
    
    fileprivate func raycasting() {
        
        // Cast ray
        
        guard let ray = arView.ray(through: arView.center) else {return }
        
        guard let query = arView.makeRaycastQuery(from: arView.center, allowing: .estimatedPlane, alignment: .horizontal) else { return }
        
        let sceneRaycast = arView.scene.raycast(origin: ray.origin, direction: ray.direction, length: 5, query: .nearest)
        
        for item in sceneRaycast {
            if item.entity.name == "Scanned" {
                // Already scanned this spot, just note that it was hit again (if it wasn't hit last)
                
                if let scannedSpot = item.entity as? ScannedIndicator {
                    if let lastSpot = lastHitScannedSpot {
                        if (scannedSpot.id != lastSpot.id) {
                            scannedSpot.hit()
                        }
                    }
                    lastHitScannedSpot = scannedSpot
                }
                
                return
            }
        }
        
        // Create new scanned spot
        
        let raycastResults = arView.session.raycast(query)
        

        guard let first = raycastResults.first else { return }
        
        
        let arAnchor = ARAnchor(name: "Scanned", transform: first.worldTransform)
    
        
        let anchorEntity = AnchorEntity(anchor: arAnchor)
        
        let scannedSpot = ScannedIndicator()
        lastHitScannedSpot = scannedSpot
        
        anchorEntity.name = "Scanned"
        scannedSpot.name = "Scanned"

        arView.session.add(anchor: arAnchor)
        
        scannedSpot.setAnchor(anchor: anchorEntity)
        arView.scene.addAnchor(anchorEntity)
        
        scannedIndicators.append(scannedSpot)
    }
    
    
    func saveAll() {
        //        var modelEntityDetailsDict: [String: [String]] = [:]
        //
        //        if let arAnchors = arView.session.currentFrame?.anchors {
        //            for arAnchor in arAnchors {
        //                if let modelName = arAnchor.name {
        //                    let identifier = arAnchor.identifier
        //
        //                    if let anchorEntity = arView.scene.findEntity(named: identifier.uuidString) as? AnchorEntity,
        //                        let modelEntity = anchorEntity.children.first as? ModelEntity {
        //                        let transformDetails = [
        //                            modelEntity.transform.translation.debugDescription,
        //                            modelEntity.transform.rotation.debugDescription,
        //                            modelEntity.transform.scale.debugDescription
        //                        ]
        //                        modelEntityDetailsDict["\(modelName)@\(identifier.uuidString)"] = transformDetails
        //                    }
        //
        //                }
        //            }
        //        }
        
        //let anchorDataURL = self.wo
    
        arView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap
                else { print("Can't get current world map", error!.localizedDescription); return }
            
            // Add a snapshot image indicating where the map was captured.
//            guard let snapshotAnchor = SnapshotAnchor(capturing: self.sceneView)
//                else { fatalError("Can't take snapshot") }
//            map.anchors.append(snapshotAnchor)
            
        }
        
    }
}
