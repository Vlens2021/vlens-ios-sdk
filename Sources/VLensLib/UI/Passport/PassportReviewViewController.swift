import UIKit

/// Shows the OCR-extracted passport fields for user confirmation before NFC.
/// Mirrors PassportReviewPage (React Native) and PassportReviewScreen (Flutter).
class PassportReviewViewController: UIViewController {

    static func instance() -> PassportReviewViewController {
        PassportReviewViewController()
    }

    var delegate: ValidationMainViewControllerDelegate?

    // MARK: - UI

    private let scrollView    = UIScrollView()
    private let contentStack  = UIStackView()
    private let footerStack   = UIStackView()
    private let backButton    = UIButton(type: .system)
    private let continueButton = UIButton(type: .system)

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

        [backButton, continueButton].forEach { btn in
            btn.layer.cornerRadius = 8
            btn.titleLabel?.font   = .systemFont(ofSize: 15, weight: .semibold)
            footerStack.addArrangedSubview(btn)
        }

        backButton.setTitle("retake_id".localized,      for: .normal)
        continueButton.setTitle("continue_button".localized, for: .normal)
        backButton.addTarget(self, action: #selector(backTapped),     for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)

        // ── Scroll + content ────────────────────────────────────────────────
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        contentStack.axis      = .vertical
        contentStack.alignment = .fill
        contentStack.spacing   = 16
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

        // ── Header ──────────────────────────────────────────────────────────
        contentStack.addArrangedSubview(
            makeLabel("review_passport_title".localized, size: 22, weight: .bold, align: .center))
        contentStack.addArrangedSubview(
            makeLabel("review_passport_description".localized, size: 14, align: .center))

        // ── Passport data card ───────────────────────────────────────────────
        let card = buildDataCard()
        contentStack.addArrangedSubview(card)
    }

    private func buildDataCard() -> UIView {
        let colors = CachedData.shared.colors.current(for: traitCollection)
        let data   = CachedData.shared.passportOcrData

        let card = UIView()
        card.backgroundColor    = UIColor.systemGray6
        card.layer.cornerRadius = 12
        card.layer.borderWidth  = 2
        card.layer.borderColor  = colors.primaryColor.cgColor
        card.translatesAutoresizingMaskIntoConstraints = false

        // Header bar
        let header = UIView()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor    = colors.primaryColor
        header.layer.cornerRadius = 10
        header.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        card.addSubview(header)

        let headerLabel = UILabel()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.text      = "passport".localized
        headerLabel.font      = .systemFont(ofSize: 16, weight: .bold)
        headerLabel.textColor = .white
        headerLabel.textAlignment = .center
        header.addSubview(headerLabel)

        // Rows stack
        let rowsStack = UIStackView()
        rowsStack.translatesAutoresizingMaskIntoConstraints = false
        rowsStack.axis      = .vertical
        rowsStack.spacing   = 0
        card.addSubview(rowsStack)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: card.topAnchor),
            header.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 52),
            headerLabel.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            headerLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            rowsStack.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 12),
            rowsStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            rowsStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            rowsStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
        ])

        // Add rows for each available field
        let fields: [(label: String, value: String?)] = [
            ("name".localized,               data?.name),
            ("passport_number_label".localized, data?.passportNumber ?? CachedData.shared.passportDocumentNumber),
            ("nationality_label".localized,  data?.nationality),
            ("country_code_label".localized, data?.countryCode),
            ("date_of_birth".localized,      data?.dateOfBirth ?? CachedData.shared.passportDateOfBirth),
            ("expiry_date".localized,        data?.expiryDate  ?? CachedData.shared.passportExpiryDate),
            ("gender".localized,             data?.gender),
        ]

        fields.compactMap { field -> (String, String)? in
            guard let value = field.value, !value.isEmpty else { return nil }
            return (field.label, value)
        }.forEach { label, value in
            rowsStack.addArrangedSubview(makeDataRow(label: label, value: value))
        }

        return card
    }

    private func applyColors() {
        let colors = CachedData.shared.colors.current(for: traitCollection)
        continueButton.backgroundColor  = colors.accentColor
        continueButton.setTitleColor(.white, for: .normal)
        backButton.backgroundColor = colors.backgroundColor
        backButton.setTitleColor(colors.primaryColor, for: .normal)
        backButton.layer.borderColor = colors.primaryColor.withAlphaComponent(0.3).cgColor
        backButton.layer.borderWidth = 1
    }

    // MARK: - Actions

    @objc private func continueTapped() {
        Task { await delegate?.didFinishValidationStepNumber(0) }
    }

    @objc private func backTapped() {
        Task { await delegate?.didBackToPreviousStep() }
    }

    // MARK: - Helpers

    private func makeLabel(_ text: String, size: CGFloat, weight: UIFont.Weight = .regular,
                            align: NSTextAlignment = .left) -> UILabel {
        let l = UILabel()
        l.text          = text
        l.font          = .systemFont(ofSize: size, weight: weight)
        l.numberOfLines = 0
        l.textAlignment = align
        let colors      = CachedData.shared.colors.current(for: traitCollection)
        l.textColor     = weight == .bold ? colors.primaryColor : colors.secondaryColor
        return l
    }

    private func makeDataRow(label: String, value: String) -> UIView {
        let colors = CachedData.shared.colors.current(for: traitCollection)

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let labelL = UILabel()
        labelL.translatesAutoresizingMaskIntoConstraints = false
        labelL.text      = label
        labelL.font      = .systemFont(ofSize: 12, weight: .medium)
        labelL.textColor = colors.secondaryColor.withAlphaComponent(0.7)

        let valueL = UILabel()
        valueL.translatesAutoresizingMaskIntoConstraints = false
        valueL.text      = value
        valueL.font      = .systemFont(ofSize: 15, weight: .semibold)
        valueL.textColor = colors.primaryColor
        valueL.textAlignment = .right
        valueL.numberOfLines = 0

        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = colors.secondaryColor.withAlphaComponent(0.15)

        [labelL, valueL, divider].forEach { container.addSubview($0) }

        NSLayoutConstraint.activate([
            labelL.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            labelL.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            labelL.trailingAnchor.constraint(equalTo: valueL.leadingAnchor, constant: -8),

            valueL.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            valueL.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            valueL.widthAnchor.constraint(lessThanOrEqualTo: container.widthAnchor, multiplier: 0.6),

            divider.topAnchor.constraint(equalTo: labelL.bottomAnchor, constant: 10),
            divider.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1),
            divider.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        return container
    }
}
