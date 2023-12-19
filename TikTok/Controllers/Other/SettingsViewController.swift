//
//  SettingsViewController.swift
//  TikTok
//
//  Created by mnash29 on 10/9/23.
//

import StoreKit
import UIKit
import SafariServices

class SettingsViewController: UIViewController {

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.register(SwitchTableViewCell.self, forCellReuseIdentifier: SwitchTableViewCell.identifier)

        return table
    }()

    var sections = [SettingsSection]()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        sections = [
            SettingsSection(
                title: "Preferences",
                options: [
                    SettingsOption(
                        title: "Save Videos",
                        handler: { }
                    )
                ]
            ),
            SettingsSection(
                title: "Enjoying TikTok?",
                options: [
                    SettingsOption(
                        title: "Rate App",
                        handler: {
                            DispatchQueue.main.async {
//                                Appirater.tryToShowPrompt()
//                                UIApplication.shared.open(
//                                    URL(string: "https://apps.apple.com/us/app/apple-store/id835599320")!,
//                                    options: [:],
//                                    completionHandler: nil
//                                )
                                let skView = SKStoreProductViewController()
                                skView.loadProduct(
                                    withParameters: [SKStoreProductParameterITunesItemIdentifier: 835599320]) { [weak self] success, error in
                                        if success {
                                            self?.present(skView, animated: true, completion: nil)
                                        } else {
                                            // Some error occurred
                                            let alert = UIAlertController(title: "Woops", message: "Something went wrong.", preferredStyle: .alert)
                                            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                                            self?.present(alert, animated: true)
                                        }
                                    }
                            }
                        }
                    ),
                    SettingsOption(
                        title: "Share App",
                        handler: { [weak self] in
                            DispatchQueue.main.async {
                                guard let url = URL(string: "https://apps.apple.com/us/app/apple-store/id835599320") else { return }

                                let vc = UIActivityViewController(
                                    activityItems: [url],
                                    applicationActivities: []
                                )
                                self?.present(vc, animated: true)
                            }
                        }
                    )
                ]
            ),
            SettingsSection(
                title: "Information",
                options: [
                    SettingsOption(
                        title: "Terms of Service",
                        handler: { [weak self] in
                            DispatchQueue.main.async {
                                guard let url = URL(string: "https://www.tiktok.com/legal/terms-of-service") else {
                                    return
                                }
                                let vc = SFSafariViewController(url: url)
                                self?.present(vc, animated: true)
                            }
                        }
                    ),
                    SettingsOption(
                        title: "Privacy Policy",
                        handler: { [weak self] in
                            DispatchQueue.main.async {
                                guard let url = URL(string: "https://www.tiktok.com/legal/privacy-policy") else {
                                    return
                                }
                                let vc = SFSafariViewController(url: url)
                                self?.present(vc, animated: true)
                            }
                        }
                    )
                ]
            )
        ]

        title = "Settings"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        createFooter()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    func createFooter() {
        let footer = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: view.width,
            height: 100
        ))

        let button = UIButton(frame: CGRect(
            x: (view.width - 200) / 2,
            y: 25,
            width: 200,
            height: 50
        ))

        button.setTitle("Sign Out", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.addTarget(self, action: #selector(didTapSignOut), for: .touchUpInside)
        footer.addSubview(button)

        tableView.tableFooterView = footer
    }

    @objc func didTapSignOut() {
        let actionSheet = UIAlertController(
            title: "Sign Out",
            message: "Would you like to sign out?",
            preferredStyle: .actionSheet
        )
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        actionSheet.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            AuthManager.shared.signOut { [weak self] success in
                DispatchQueue.main.async {
                    if success {
                        UserDefaults.standard.setValue(nil, forKey: "username")
                        UserDefaults.standard.setValue(nil, forKey: "profile_image_url")

                        let navVC = UINavigationController(rootViewController: SignInViewController())
                        navVC.modalPresentationStyle = .fullScreen

                        self?.present(navVC, animated: true)
                        self?.navigationController?.popToRootViewController(animated: true)
                        self?.tabBarController?.selectedIndex = 0
                    } else {
                        let alert = UIAlertController(title: "Woops", message: "Something went wrong while signing out. Please try again.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                        self?.present(alert, animated: true)
                    }
                }
            }
        }))

        present(actionSheet, animated: true)
    }

}

// MARK: - UITableViewDelegate methods

extension SettingsViewController: UITableViewDelegate {

}

// MARK: - UITableViewDataSource methods

extension SettingsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = sections[indexPath.section].options[indexPath.row]

        if model.title == "Save Videos" {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SwitchTableViewCell.identifier,
                for: indexPath
            ) as? SwitchTableViewCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.configure(
                with: SwitchCellViewModel(
                    title: model.title,
                    isOn: UserDefaults.standard.bool(forKey: "save_video")
                )
            )

            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = model.title

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = sections[indexPath.section].options[indexPath.row]
        model.handler()
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}

// MARK: - SwitchTableVieCellDelegate methods

extension SettingsViewController: SwitchTableViewCellDelegate {
    func switchTableViewCell(_ cell: SwitchTableViewCell, didUpdateSwitchTo isOn: Bool) {
        HapticsManager.shared.vibrateForSeletion()
        UserDefaults.standard.setValue(isOn, forKey: "save_video")
    }
}

// MARK: - SKStoreProductViewControllerDelegate methods

extension SettingsViewController: SKStoreProductViewControllerDelegate {
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.presentingViewController?.dismiss(animated: true)
    }
}
