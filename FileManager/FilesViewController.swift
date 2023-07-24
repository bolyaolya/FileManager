//
//  FilesViewController.swift
//  FileManager
//
//  Created by Ольга Бойко on 21.06.2023.
//

import UIKit
import PhotosUI

final class FilesViewController: UIViewController {
    
    //MARK: - Properties
    
    var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    var files : [String] {
        (try? FileManager.default.contentsOfDirectory(atPath: path)) ?? []
        
    }
    
    private lazy var addPhotoButton : UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(imagePickerFunc))
        button.tintColor = .systemCyan
        return button
    }()
    
    private lazy var addFolderButton : UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "folder.badge.plus"), style: .plain, target: self, action: #selector(createFolderFunc))
        button.tintColor = .systemCyan
        return button
    }()
    
    private lazy var folderTitle : UILabel = {
        let title = UILabel()
        title.text = "Documents"
        title.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    private lazy var tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(FilesTableViewCell.self, forCellReuseIdentifier: "CustomCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    //MARK: - Methods
    
    private func setupUI() {
        setupNavBar()
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        view.addSubview(folderTitle)
        view.addSubview(tableView)
    }
    
    private func setupNavBar() {
        navigationItem.title = "File Manager"
        navigationItem.rightBarButtonItems = [addPhotoButton, addFolderButton]
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            folderTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            folderTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            tableView.topAnchor.constraint(equalTo: folderTitle.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func imagePickerFunc() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
//    @objc private func createFolderFunc(folderName : String) {
//        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let dataPath = documentsDirectory.appendingPathComponent(folderName)
//
//        do {
//            try FileManager.default.createDirectory(atPath: dataPath.absoluteString, withIntermediateDirectories: false)
//        } catch let error {
//            print(error.localizedDescription)
//        }
//    }
    
    @objc private func createFolderFunc() {
        
    }
}

extension FilesViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        files.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.estimatedRowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? FilesTableViewCell else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
            return cell
        }
        let fullPath = self.path + "/" + self.files[indexPath.row]
        var isDir : ObjCBool = true
        if FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDir) {
            if isDir.boolValue == true {
                cell.fileLabel.text = "Folder"
            } else {
                cell.fileLabel.text = "File"
            }
        }
        
        cell.descriptionLabel.text = files[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            let fullPath = self.path + self.files[indexPath.row]
            try? FileManager.default.removeItem(atPath: fullPath)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        let config = UISwipeActionsConfiguration(actions: [action])
        return config
    }
}

extension FilesViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        let imageName = UUID().uuidString
        
        guard let imagePath = getPath()?.appending(component: imageName), let jpegData = image.jpegData(compressionQuality: 0.7)
        else { return }
        
        FileManager.default.createFile(atPath: imagePath.relativePath, contents: jpegData)
        tableView.reloadData()
        picker.dismiss(animated: true)
    }
    
    func getPath() -> URL? {
        do {
            let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            return url
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
}

