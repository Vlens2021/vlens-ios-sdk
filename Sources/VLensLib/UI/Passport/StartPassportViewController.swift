import UIKit

/// Intro screen shown before the passport camera capture.
/// Mirrors StartPassportPage (React Native) and StartPassport (Flutter).
class StartPassportViewController: UIViewController {

    static func instance() -> StartPassportViewController {
        StartPassportViewController()
    }

    var delegate: ValidationMainViewControllerDelegate?

    // MARK: - UI

    private let scrollView   = UIScrollView()
    private let contentStack = UIStackView()
    private let footerStack  = UIStackView()
    private let startButton  = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        applyColors()
    }

    // MARK: - Layout

    private func buildLayout() {
        let colors = CachedData.shared.colors.current(for: traitCollection)
        view.backgroundColor = colors.backgroundColor

        // ── Footer ──────────────────────────────────────────────────────────
        footerStack.axis         = .horizontal
        footerStack.distribution = .fillEqually
        footerStack.spacing      = 12
        footerStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(footerStack)

        [cancelButton, startButton].forEach { btn in
            btn.layer.cornerRadius = 8
            btn.titleLabel?.font   = .systemFont(ofSize: 15, weight: .semibold)
            footerStack.addArrangedSubview(btn)
        }

        cancelButton.setTitle("close".localized,          for: .normal)
        startButton.setTitle("start_scanning".localized,  for: .normal)
        startButton.addTarget(self, action: #selector(startTapped),  for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        // ── Scroll + content stack ──────────────────────────────────────────
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        contentStack.axis      = .vertical
        contentStack.alignment = .fill
        contentStack.spacing   = 20
        contentStack.layoutMargins = UIEdgeInsets(top: 24, left: 20, bottom: 24, right: 20)
        contentStack.isLayoutMarginsRelativeArrangement = true

        NSLayoutConstraint.activate([
            footerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            footerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            footerStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            footerStack.heightAnchor.constraint(equalToConstant: 50),

            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: footerStack.topAnchor, constant: -8),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        // ── Content ─────────────────────────────────────────────────────────

        // Logo
        if let logo = CachedData.shared.clientLogoImage {
            let iv = UIImageView(image: logo)
            iv.contentMode = .scaleAspectFit
            iv.heightAnchor.constraint(equalToConstant: 52).isActive = true
            contentStack.addArrangedSubview(iv)
        }

        // Title
        contentStack.addArrangedSubview(
            makeLabel("scanning_your_passport_title".localized, size: 22, weight: .bold, align: .center))

        // Subtitle
        contentStack.addArrangedSubview(
            makeLabel("passport_instructions".localized, size: 14, align: .center))

        // Instructions section
        contentStack.addArrangedSubview(
            makeSectionHeader("instructions".localized))
        for (i, key) in ["passport_instruction_1",
                          "passport_instruction_2",
                          "passport_instruction_3",
                          "passport_instruction_4"].enumerated() {
            contentStack.addArrangedSubview(makeNumberedRow(number: i + 1, text: key.localized))
        }

        // Tips section
        contentStack.addArrangedSubview(
            makeSectionHeader("tip_title".localized))
        for key in ["passport_tip_1", "passport_tip_2"] {
            contentStack.addArrangedSubview(makeTipRow(text: key.localized))
        }
    }

    private func applyColors() {
        let colors = CachedData.shared.colors.current(for: traitCollection)
        startButton.backgroundColor  = colors.accentColor
        startButton.setTitleColor(.white, for: .normal)
        cancelButton.backgroundColor = colors.backgroundColor
        cancelButton.setTitleColor(colors.primaryColor, for: .normal)
        cancelButton.layer.borderColor = colors.primaryColor.withAlphaComponent(0.3).cgColor
        cancelButton.layer.borderWidth = 1
    }

    // MARK: - Actions

    @objc private func startTapped() {
        Task { await delegate?.didFinishValidationStepNumber(0) }
    }

    @objc private func cancelTapped() {
        Task { await delegate?.didCancel() }
    }

    // MARK: - Helpers

    private func makeLabel(_ text: String, size: CGFloat, weight: UIFont.Weight = .regular,
                            align: NSTextAlignment = .left) -> UILabel {
        let l = UILabel()
        l.text          = text
        l.font          = .systemFont(ofSize: size, weight: weight)
        l.numberOfLines = 0
        l.textAlignment = align
        let colors = CachedData.shared.colors.current(for: traitCollection)
        l.textColor     = weight == .bold ? colors.primaryColor : colors.secondaryColor
        return l
    }

    private func makeSectionHeader(_ text: String) -> UILabel {
        let l = UILabel()
        l.text      = text
        l.font      = .systemFont(ofSize: 16, weight: .semibold)
        l.numberOfLines = 0
        let colors  = CachedData.shared.colors.current(for: traitCollection)
        l.textColor = colors.primaryColor
        return l
    }

    private func makeNumberedRow(number: Int, text: String) -> UIView {
        let colors  = CachedData.shared.colors.current(for: traitCollection)
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let badge = UIView()
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.layer.cornerRadius  = 14
        badge.backgroundColor     = colors.accentColor
        badge.widthAnchor.constraint(equalToConstant: 28).isActive  = true
        badge.heightAnchor.constraint(equalToConstant: 28).isActive = true

        let numLabel = UILabel()
        numLabel.translatesAutoresizingMaskIntoConstraints = false
        numLabel.text      = "\(number)"
        numLabel.font      = .systemFont(ofSize: 12, weight: .semibold)
        numLabel.textColor = .white
        numLabel.textAlignment = .center
        badge.addSubview(numLabel)
        NSLayoutConstraint.activate([
            numLabel.centerXAnchor.constraint(equalTo: badge.centerXAnchor),
            numLabel.centerYAnchor.constraint(equalTo: badge.centerYAnchor),
        ])

        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.text          = text
        textLabel.font          = .systemFont(ofSize: 13)
        textLabel.textColor     = colors.secondaryColor
        textLabel.numberOfLines = 0

        let row = UIStackView(arrangedSubviews: [badge, textLabel])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis      = .horizontal
        row.alignment = .top
        row.spacing   = 12
        container.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: container.topAnchor),
            row.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            row.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        return container
    }

    private func makeTipRow(text: String) -> UIView {
        let colors = CachedData.shared.colors.current(for: traitCollection)
        let card   = UIView()
        card.backgroundColor    = colors.accentColor.withAlphaComponent(0.06)
        card.layer.cornerRadius = 8
        card.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text          = text
        label.font          = .systemFont(ofSize: 13)
        label.textColor     = colors.secondaryColor
        label.numberOfLines = 0
        card.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            label.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
        ])
        return card
    }
}
