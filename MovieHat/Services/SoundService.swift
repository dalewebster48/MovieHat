import AVFoundation

protocol SoundService: AnyObject {
    func playDrumroll()
}

final class SoundServiceImpl: SoundService {
    private var player: AVAudioPlayer?

    func playDrumroll() {
        guard let url = Bundle.main.url(forResource: "drumroll-trimmed", withExtension: "mp3") else { return }
        player = try? AVAudioPlayer(contentsOf: url)
        player?.play()
    }
}
