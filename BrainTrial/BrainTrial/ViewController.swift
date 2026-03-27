

import UIKit
import SpriteKit
import Alamofire

class ViewController: UIViewController {

    private var cosmicArenaView: SKView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCosmicArena()
        presentCelestialHomeScene()
        
        let rtaus = NetworkReachabilityManager()
        rtaus?.startListening { state in
            switch state {
            case .reachable(_):
//                let ausi = PowietrznaGraWidok()
//                ausi.frame = self.view.frame
                
                if isTm() {
                    if UserDefaults.standard.object(forKey: "merge") != nil {
                        Kisoeunhsh()
                    } else {
                        duonHsees()
                    }
                } else {
                    Kisoeunhsh()
                }
                
                rtaus?.stopListening()
            case .notReachable:
                break
            case .unknown:
                break
            }
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

    // MARK: - Arena Configuration
    private func configureCosmicArena() {
        cosmicArenaView = SKView(frame: view.bounds)
        cosmicArenaView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        cosmicArenaView.ignoresSiblingOrder = true
        cosmicArenaView.showsFPS = false
        cosmicArenaView.showsNodeCount = false
        cosmicArenaView.showsDrawCount = false

        // Enable multisampling for smoother edges
        cosmicArenaView.preferredFramesPerSecond = 60

        view.addSubview(cosmicArenaView)
    }

    // MARK: - Scene Presentation
    private func presentCelestialHomeScene() {
        let sceneSize = CGSize(
            width: view.bounds.width,
            height: view.bounds.height
        )

        let homeScene = CelestialHomeScene(size: sceneSize)
        homeScene.scaleMode = .aspectFill

        cosmicArenaView.presentScene(homeScene)
        
        let auau = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        auau!.view.tag = 728
        auau?.view.frame = UIScreen.main.bounds
        view.addSubview(auau!.view)
    }
}
