import SwiftUI
import UIKit

struct PassageTextView: UIViewRepresentable {
    let text: String
    let onNext: () -> Void
    let onPrevious: () -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.delegate = context.coordinator
        view.isEditable = false
        view.isSelectable = false
        view.isScrollEnabled = true
        view.backgroundColor = .clear
        view.textColor = UIColor(red: 0.99, green: 0.97, blue: 0.92, alpha: 1)
        view.font = UIFontMetrics(forTextStyle: .title1).scaledFont(for: UIFont(name: "Georgia", size: 25)!)
        view.adjustsFontForContentSizeCategory = true
        view.textAlignment = .center
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceVertical = true
        view.accessibilityLabel = text
        return view
    }

    func updateUIView(_ view: UITextView, context: Context) {
        context.coordinator.parent = self
        if view.text != text {
            view.text = text
            view.contentOffset = .zero
        }
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: PassageTextView
        private var startingOffset: CGFloat = 0

        init(_ parent: PassageTextView) { self.parent = parent }

        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            startingOffset = max(0, scrollView.contentOffset.y)
        }

        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            let translation = scrollView.panGestureRecognizer.translation(in: scrollView).y
            let maxOffset = max(0, scrollView.contentSize.height - scrollView.bounds.height)
            let threshold: CGFloat = 66
            if translation < 0 {
                let beyondBottom = -translation - max(0, maxOffset - startingOffset)
                if beyondBottom > threshold { parent.onNext() }
            } else {
                let beyondTop = translation - startingOffset
                if beyondTop > threshold { parent.onPrevious() }
            }
        }
    }
}
