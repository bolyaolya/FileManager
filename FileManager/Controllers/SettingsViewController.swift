//
//  SettingsViewController.swift
//  FileManager
//
//  Created by Ольга Бойко on 25.07.2023.
//

import UIKit
import Foundation

final class SettingsViewController: UIViewController {
    
    var sortMethod : Bool {
        get {
            return UserDefaults.standard.bool(forKey: "sortStatus")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "sortStatus")
        }
    }
    
    // MARK: - Properties
    
    private lazy var sortLabel : UILabel = {
        let label = UILabel()
        label.text = "Сортировка в алфавитном порядке"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var sortSwitcher : UISwitch = {
        let switcher = UISwitch()
        switcher.addTarget(self, action: #selector(alphabetSwitching), for: .valueChanged)
        switcher.translatesAutoresizingMaskIntoConstraints = false
        return switcher
    }()
    
    private lazy var changePasswordButton : UIButton = {
        let button = UIButton()
        button.setTitle("Изменить пароль", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.8224570155, green: 0.8772378564, blue: 1, alpha: 1)
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(changePassword), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        title = "Настройки"
        setupUI()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if sortMethod == true {
            sortSwitcher.isOn = true
            print("Сортировка включена")
        } else {
            sortSwitcher.isOn = false
            print("Сортировка выключена")
        }
    }
    
    private func setupUI() {
        view.addSubview(sortLabel)
        view.addSubview(sortSwitcher)
        view.addSubview(changePasswordButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            sortLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            sortLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            sortSwitcher.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            sortSwitcher.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            changePasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            changePasswordButton.topAnchor.constraint(equalTo: sortLabel.bottomAnchor, constant: 40)
        ])
    }
    
    @objc private func alphabetSwitching() {
        if sortSwitcher.isOn {
            sortMethod = true
            print("Файлы отсортированы в алфавитном порядке")
        } else {
            sortMethod = false
            print("Файлы отсортированы не в алфавитном порядке")
        }
    }
    
    @objc private func changePassword() {
        let vc = LoginViewController(isPasswordChangeState: true)
        present(vc, animated: true)
    }
}












