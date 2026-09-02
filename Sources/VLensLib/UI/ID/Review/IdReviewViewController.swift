//
//  IdReviewViewController.swift
//  VLensLib
//
//  Created by VLens on 08/03/2026.
//

import UIKit

class IdReviewViewController: UIViewController {

    static func instance() -> IdReviewViewController {
        let viewController = IdReviewViewController()
        return viewController
    }
    
    var delegate: ValidationMainViewControllerDelegate? = nil
    let viewModel = IdReviewViewModel()
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "review_data".localized
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "verify_data_subtitle".localized
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // Front Card Section
    private lazy var frontCardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray4.cgColor
        return view
    }()
    
    private lazy var frontCardLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "front_side".localized
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private lazy var frontCardStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()
    
    // Back Card Section
    private lazy var backCardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray4.cgColor
        return view
    }()
    
    private lazy var backCardLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "back_side".localized
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private lazy var backCardStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()
    
    // Verification Status
    private lazy var verificationStatusView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        return view
    }()
    
    private lazy var verificationStatusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    // Button Stack
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var retakeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("retake_id".localized, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(retakeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("continue_button".localized, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        return button
    }()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        DatadogService.shared.rumStartView(key: "id_review", name: "ID Review Screen")
        DatadogService.shared.info("ID review screen displayed")
        DatadogService.shared.rumAddAction("id_review_displayed")
        setupUI()
        setupColors()
        populateData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DatadogService.shared.rumStopView(key: "id_review")
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(frontCardLabel)
        contentView.addSubview(frontCardView)
        contentView.addSubview(backCardLabel)
        contentView.addSubview(backCardView)
        contentView.addSubview(verificationStatusView)
        contentView.addSubview(buttonStackView)
        
        frontCardView.addSubview(frontCardStackView)
        backCardView.addSubview(backCardStackView)
        verificationStatusView.addSubview(verificationStatusLabel)
        
        buttonStackView.addArrangedSubview(retakeButton)
        buttonStackView.addArrangedSubview(continueButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            frontCardLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            frontCardLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            frontCardView.topAnchor.constraint(equalTo: frontCardLabel.bottomAnchor, constant: 8),
            frontCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            frontCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            frontCardStackView.topAnchor.constraint(equalTo: frontCardView.topAnchor, constant: 16),
            frontCardStackView.leadingAnchor.constraint(equalTo: frontCardView.leadingAnchor, constant: 16),
            frontCardStackView.trailingAnchor.constraint(equalTo: frontCardView.trailingAnchor, constant: -16),
            frontCardStackView.bottomAnchor.constraint(equalTo: frontCardView.bottomAnchor, constant: -16),
            
            backCardLabel.topAnchor.constraint(equalTo: frontCardView.bottomAnchor, constant: 20),
            backCardLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            backCardView.topAnchor.constraint(equalTo: backCardLabel.bottomAnchor, constant: 8),
            backCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            backCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            backCardStackView.topAnchor.constraint(equalTo: backCardView.topAnchor, constant: 16),
            backCardStackView.leadingAnchor.constraint(equalTo: backCardView.leadingAnchor, constant: 16),
            backCardStackView.trailingAnchor.constraint(equalTo: backCardView.trailingAnchor, constant: -16),
            backCardStackView.bottomAnchor.constraint(equalTo: backCardView.bottomAnchor, constant: -16),
            
            verificationStatusView.topAnchor.constraint(equalTo: backCardView.bottomAnchor, constant: 20),
            verificationStatusView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            verificationStatusView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            verificationStatusView.heightAnchor.constraint(equalToConstant: 44),
            
            verificationStatusLabel.centerXAnchor.constraint(equalTo: verificationStatusView.centerXAnchor),
            verificationStatusLabel.centerYAnchor.constraint(equalTo: verificationStatusView.centerYAnchor),
            
            buttonStackView.topAnchor.constraint(equalTo: verificationStatusView.bottomAnchor, constant: 24),
            buttonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonStackView.heightAnchor.constraint(equalToConstant: 50),
            buttonStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
        ])
    }
    
    private func setupColors() {
        let colors = CachedData.shared.colors.current(for: traitCollection)
        
        view.backgroundColor = colors.backgroundColor
        headerLabel.textColor = colors.primaryColor
        
        retakeButton.setTitleColor(colors.primaryColor, for: .normal)
        retakeButton.layer.borderColor = colors.primaryColor.cgColor
        retakeButton.backgroundColor = .clear
        
        // Ensure continue button has contrast - use primary color for background and white text
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.backgroundColor = colors.accentColor ?? colors.primaryColor
        continueButton.layer.shadowColor = colors.primaryColor.cgColor
        continueButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        continueButton.layer.shadowRadius = 4
        continueButton.layer.shadowOpacity = 0.2
    }
    
    private func populateData() {
        // Front Card Data
        addDataRow(to: frontCardStackView, label: "name".localized, value: viewModel.name)
        addDataRow(to: frontCardStackView, label: "address".localized, value: viewModel.address)
        addDataRow(to: frontCardStackView, label: "date_of_birth".localized, value: viewModel.dateOfBirth)
        addDataRow(to: frontCardStackView, label: "national_id_number".localized, value: viewModel.idNumber)
        
        // Back Card Data
        addDataRow(to: backCardStackView, label: "gender".localized, value: viewModel.gender)
        addDataRow(to: backCardStackView, label: "marital_status".localized, value: viewModel.maritalStatus)
        addDataRow(to: backCardStackView, label: "job".localized, value: viewModel.job)
        addDataRow(to: backCardStackView, label: "religion".localized, value: viewModel.religion)
        addDataRow(to: backCardStackView, label: "issue_date".localized, value: viewModel.releaseDate)
        addDataRow(to: backCardStackView, label: "expiry_date".localized, value: viewModel.expiryDate)
        
        // Verification Status
        if viewModel.isDigitalIdentityVerified {
            verificationStatusView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
            verificationStatusLabel.text = "✓ " + "verified".localized
            verificationStatusLabel.textColor = .systemGreen
        } else {
            verificationStatusView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.15)
            verificationStatusLabel.text = "pending_verification".localized
            verificationStatusLabel.textColor = .systemOrange
        }
    }
    
    private func addDataRow(to stackView: UIStackView, label: String, value: String) {
        let rowView = UIView()
        rowView.translatesAutoresizingMaskIntoConstraints = false
        
        let labelView = UILabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.text = label
        labelView.font = .systemFont(ofSize: 12, weight: .regular)
        labelView.textColor = .gray
        
        let valueView = UILabel()
        valueView.translatesAutoresizingMaskIntoConstraints = false
        valueView.text = value
        valueView.font = .systemFont(ofSize: 14, weight: .medium)
        valueView.textColor = CachedData.shared.colors.current(for: traitCollection).primaryColor
        valueView.numberOfLines = 0
        
        rowView.addSubview(labelView)
        rowView.addSubview(valueView)
        
        NSLayoutConstraint.activate([
            labelView.topAnchor.constraint(equalTo: rowView.topAnchor),
            labelView.leadingAnchor.constraint(equalTo: rowView.leadingAnchor),
            labelView.trailingAnchor.constraint(equalTo: rowView.trailingAnchor),
            
            valueView.topAnchor.constraint(equalTo: labelView.bottomAnchor, constant: 4),
            valueView.leadingAnchor.constraint(equalTo: rowView.leadingAnchor),
            valueView.trailingAnchor.constraint(equalTo: rowView.trailingAnchor),
            valueView.bottomAnchor.constraint(equalTo: rowView.bottomAnchor),
        ])
        
        stackView.addArrangedSubview(rowView)
    }
    
    @objc private func retakeButtonTapped() {
        DatadogService.shared.info("User retook ID from review")
        DatadogService.shared.rumAddAction("retake_id_from_review")
        Task {
            await delegate?.didBackToPreviousStep()
        }
    }
    
    @objc private func continueButtonTapped() {
        DatadogService.shared.info("User confirmed ID review")
        DatadogService.shared.rumAddAction("confirm_id_review")
        Task {
            await delegate?.didFinishValidationStepNumber(viewModel.getStepIndex())
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
}
