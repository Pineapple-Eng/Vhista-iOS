//  Created by Juan David Cruz Serrano on 8/18/19. Copyright © 2019 juandavidcruz. All rights reserved.

import Foundation
import UIKit
import AVFoundation

class VhistaSoundManager: NSObject {

    // Setup player for loading sounds
    var player: AVAudioPlayer?

    // MARK: - Initialization Method
    override init() {
        super.init()
    }

    static let shared: VhistaSoundManager = {
        let instance = VhistaSoundManager()
        return instance
    }()
}

extension VhistaSoundManager {
    func playLoadingSound() {
        let url = Bundle.main.url(forResource: "loading_beep", withExtension: "wav")!
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            player.volume = 0.5
            player.prepareToPlay()
            player.numberOfLoops = -1
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func pauseLoadingSound() {
        if player != nil {
            if player!.isPlaying {
                player!.stop()
            }
        }
    }
}
