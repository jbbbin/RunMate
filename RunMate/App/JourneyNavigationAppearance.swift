import UIKit

enum JourneyNavigationAppearance {
    @MainActor
    static func configure() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.largeTitleTextAttributes = [
            .font: UIFontMetrics(forTextStyle: .largeTitle).scaledFont(
                for: UIFont(name: "Pretendard-Bold", size: 28) ?? .preferredFont(forTextStyle: .largeTitle)
            )
        ]
        appearance.titleTextAttributes = [
            .font: UIFont(name: "Pretendard-Bold", size: 17) ?? .preferredFont(forTextStyle: .headline)
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
}
