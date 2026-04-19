import SwiftUI

struct FloatingScrollButtons: ViewModifier {
    let topID: String
    let bottomID: String

    @EnvironmentObject var audioPlayerViewModel: AudioPlayerViewModel

    @State private var opacity: Double = 0.7
    @State private var isScrolling = false
    @State private var fadeWorkItem: DispatchWorkItem?
    @State private var floatOffset: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var viewHeight: CGFloat = 0
    @State private var scrollViewRef: UIScrollView?
    @State private var anchorView: UIView?

    /// Bottom padding: sit above mini player when it's showing
    private var buttonBottomPadding: CGFloat {
        audioPlayerViewModel.showMiniPlayer ? 74 : 14
    }

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    Color.clear
                        .preference(key: ScrollOffsetKey.self, value: geo.frame(in: .global).minY)
                        .onAppear {
                            viewHeight = geo.size.height
                        }
                        .onChange(of: geo.size.height) { _, newHeight in
                            viewHeight = newHeight
                        }
                }
            )
            .onPreferenceChange(ScrollOffsetKey.self) { value in
                scrollOffset = value
                onScrollActivity()
            }
            .overlay(alignment: .bottomTrailing) {
                // Invisible anchor to find the UIScrollView
                ScrollViewFinder { view, sv in
                    anchorView = view
                    scrollViewRef = sv
                }
                .frame(width: 1, height: 1)
                .allowsHitTesting(false)
                .opacity(0)

                // Visible scroll buttons — no .offset() to avoid hit-test issues
                VStack(spacing: 0) {
                    Button {
                        scrollPageUp()
                    } label: {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 14, weight: .semibold))
                            .frame(width: 42, height: 34)
                    }

                    Divider()
                        .frame(width: 22)

                    Button {
                        scrollPageDown()
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .semibold))
                            .frame(width: 42, height: 34)
                    }
                }
                .contentShape(RoundedRectangle(cornerRadius: 14))
                .foregroundColor(.primaryGreen)
                .background(.ultraThinMaterial)
                .cornerRadius(14)
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
                .opacity(opacity)
                .padding(.trailing, 14)
                .padding(.bottom, buttonBottomPadding)
                .animation(.easeInOut(duration: 0.25), value: audioPlayerViewModel.showMiniPlayer)
            }
    }

    // MARK: - Scroll Actions

    private func findScrollViewIfNeeded() -> UIScrollView? {
        // Return existing ref if still valid
        if let sv = scrollViewRef, sv.window != nil {
            return sv
        }
        // Try to re-find using the anchor view
        if let anchor = anchorView {
            if let sv = ScrollViewIntrospection.findScrollView(from: anchor) {
                scrollViewRef = sv
                return sv
            }
        }
        return nil
    }

    private func scrollPageUp() {
        guard let scrollView = findScrollViewIfNeeded() else { return }
        let pageHeight = max(viewHeight * 0.85, 200)
        let newY = max(scrollView.contentOffset.y - pageHeight, 0)
        scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: newY), animated: true)
    }

    private func scrollPageDown() {
        guard let scrollView = findScrollViewIfNeeded() else { return }
        let insets = scrollView.adjustedContentInset
        let maxOffset = scrollView.contentSize.height - scrollView.bounds.height + insets.bottom
        let pageHeight = max(viewHeight * 0.85, 200)
        let newY = min(scrollView.contentOffset.y + pageHeight, max(maxOffset, 0))
        scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: newY), animated: true)
    }

    private func onScrollActivity() {
        if !isScrolling {
            isScrolling = true
            withAnimation(.easeOut(duration: 0.25)) {
                opacity = 0.15
            }
        }

        fadeWorkItem?.cancel()

        let workItem = DispatchWorkItem {
            isScrolling = false
            withAnimation(.easeIn(duration: 0.5)) {
                opacity = 0.7
            }
        }
        fadeWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: workItem)
    }
}

// MARK: - UIScrollView Introspection

private enum ScrollViewIntrospection {
    /// Find the nearest UIScrollView from a given UIView by checking ancestors then siblings
    static func findScrollView(from view: UIView) -> UIScrollView? {
        // Strategy 1: Walk up ancestors — handles overlay-inside-scrollview case
        var ancestor: UIView? = view.superview
        while let current = ancestor {
            if let sv = current as? UIScrollView, isContentScrollView(sv) {
                return sv
            }
            ancestor = current.superview
        }

        // Strategy 2: Walk up and search siblings at each level
        var currentView: UIView? = view
        while let v = currentView {
            if let parent = v.superview {
                if let sv = findScrollViewInChildren(of: parent, excluding: v) {
                    return sv
                }
            }
            currentView = currentView?.superview
        }

        return nil
    }

    /// Check if a UIScrollView is a real content scroll view (not a navigation/system one)
    private static func isContentScrollView(_ sv: UIScrollView) -> Bool {
        sv.isUserInteractionEnabled &&
        !sv.isHidden &&
        sv.frame.height > 100 &&
        sv.contentSize.height > 0
    }

    private static func findScrollViewInChildren(of parent: UIView, excluding: UIView) -> UIScrollView? {
        for child in parent.subviews {
            if child === excluding { continue }
            if let sv = child as? UIScrollView, isContentScrollView(sv) {
                return sv
            }
            if let sv = findScrollViewDeep(in: child) {
                return sv
            }
        }
        return nil
    }

    private static func findScrollViewDeep(in view: UIView) -> UIScrollView? {
        if let sv = view as? UIScrollView, isContentScrollView(sv) {
            return sv
        }
        for child in view.subviews {
            if let sv = findScrollViewDeep(in: child) {
                return sv
            }
        }
        return nil
    }
}

// MARK: - UIViewRepresentable that finds the UIScrollView with retry logic

private struct ScrollViewFinder: UIViewRepresentable {
    let onFound: (UIView, UIScrollView) -> Void

    func makeUIView(context: Context) -> ScrollViewAnchorView {
        let view = ScrollViewAnchorView()
        view.onFound = onFound
        return view
    }

    func updateUIView(_ uiView: ScrollViewAnchorView, context: Context) {}
}

private class ScrollViewAnchorView: UIView {
    var onFound: ((UIView, UIScrollView) -> Void)?
    private var hasFound = false
    private var retryCount = 0
    private let maxRetries = 10

    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard window != nil else { return }
        hasFound = false
        retryCount = 0
        attemptFind()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if !hasFound, window != nil {
            attemptFind()
        }
    }

    private func attemptFind() {
        guard !hasFound else { return }

        if let sv = ScrollViewIntrospection.findScrollView(from: self) {
            hasFound = true
            onFound?(self, sv)
            return
        }

        retryCount += 1
        guard retryCount <= maxRetries else { return }

        let delay = min(0.05 * Double(retryCount), 0.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.attemptFind()
        }
    }
}

// MARK: - Preference Key

private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - ScrollView Extension

extension ScrollView {
    func withScrollButtons(topID: String = "scrollTop", bottomID: String = "scrollBottom") -> some View {
        modifier(FloatingScrollButtons(topID: topID, bottomID: bottomID))
    }
}
