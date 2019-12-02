//
//  ViewController.swift
//  ItauChallenge
//
//  Created by Eduardo Façanha on 30/11/19.
//  Copyright © 2019 Eduardo Façanha. All rights reserved.
//

import UIKit

class AgencysTableViewController: UITableViewController {
  var viewModel: AgencyViewModel!
  
  override func viewDidLoad() {
    viewModel = AgencyViewModel()
    viewModel.setDelegate(self)
    super.viewDidLoad()
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.identifier, for: indexPath)
    let agency = viewModel.agency(indexPath: indexPath)
    cell.textLabel?.text = agency.name
    return cell
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.numberOfRows
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let agencyViewController = segue.destination as? AgencyViewController,
      let indexPath = self.tableView.indexPathForSelectedRow else { return }
    agencyViewController.viewModel.setAgency(viewModel.agency(indexPath: indexPath))
    super.prepare(for: segue, sender: sender)
  }
}

extension AgencysTableViewController: AgencyViewModelDelegate {
  func reload() {
    tableView.reloadData()
  }
  func connectionError() {
    let alertController = UIAlertController.init(title: "Network connection failed",
                                                 message: "Check your connection and try again", preferredStyle: .alert)
    alertController.addAction(.init(title: "ok", style: .default, handler: nil))
    DispatchQueue.main.async {
      self.present(alertController, animated: true, completion: nil)
    }
  }
}
