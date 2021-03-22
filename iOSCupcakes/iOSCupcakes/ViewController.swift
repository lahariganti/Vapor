//
//  ViewController.swift
//  iOSCupcakes
//
//  Created by Lahari Ganti on 8/9/19.
//  Copyright © 2019 Lahari Ganti. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    private let reuseIdentifier = "CupcakeCell"
    var cupcakes = [Cupcake]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.dataSource = self
        fetchCupcakes()
    }



    private func fetchCupcakes() {
        let url = URL(string: "http://localhost:8888/cupcakes")!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print(error?.localizedDescription ?? "unknown error")
                return
            }

            let decoder = JSONDecoder()
            if let cupcakes = try? decoder.decode([Cupcake].self, from: data) {
                DispatchQueue.main.async {
                    self.cupcakes = cupcakes
                    self.tableView.reloadData()
                }
            }
        }.resume()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cupcakes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
        cell.textLabel?.text = cupcakes[indexPath.row].name
        cell.detailTextLabel?.text = "\(cupcakes[indexPath.row].description) | \(cupcakes[indexPath.row].price)"
        return cell
    }

    private func order(_ cake: Cupcake, name: String) {
        let order = Order(cakeName: cake.name, buyerName: name)
        let url = URL(string: "http://localhost:8888/order")!

        let encoder = JSONEncoder()

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? encoder.encode(order)

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            if let error = error {
                print(error.localizedDescription)
                return
            }

            let decoder = JSONDecoder()
            if let item = try? decoder.decode(Order.self, from: data) {
                print(item.buyerName)
            }
        }.resume()

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cake = cupcakes[indexPath.row]
        let ac = UIAlertController(title: "Order this \(cake.name)?", message: "Please enter your name", preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Order it!", style: .default, handler: { (action) in
            guard let name = ac.textFields?[0].text else { return }
            self.order(cake, name: name)
        }))

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
}

