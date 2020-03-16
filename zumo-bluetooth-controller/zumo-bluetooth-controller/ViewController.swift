//
//  ViewController.swift
//  bluno-robot
//
//  Created by Rahul Katre on 9/14/18.
//  Copyright © 2018 Rahul Katre. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var peripherals:[CBPeripheral] = []
    var peripheralConnected = false
    var confirmDisconnection = false
    
    var manager:CBCentralManager? = nil
    var mainPeripheral:CBPeripheral? = nil
    var mainCharacteristic:CBCharacteristic? = nil
    
    let BLEService = "DFB0"
    let BLECharacteristic = "DFB1"
    
    @IBOutlet weak var peripheralList: UITableView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var leftSpeedLabel: UILabel!
    @IBOutlet weak var rightSpeedLabel: UILabel!
    
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    
    var leftThrottle = UIPanGestureRecognizer()
    var rightThrottle = UIPanGestureRecognizer()
    
    var leftThrottleInitial = CGPoint()
    var leftThrottleCurrent = CGPoint()
    var leftThrottleChange = CGPoint()
    var rightThrottleInitial = CGPoint()
    var rightThrottleCurrent = CGPoint()
    var rightThrottleChange = CGPoint()
    
    var leftThrottleValue = 0
    var rightThrottleValue = 0
    
    let red = UIColor(red:1.00, green:0.23, blue:0.19, alpha:1.0)
    let green = UIColor(red:0.30, green:0.85, blue:0.39, alpha:1.0)
    let blue = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
    
    var leftThrottlePath = UIBezierPath()
    var leftThrottleLayer = CAShapeLayer()
    var rightThrottlePath = UIBezierPath()
    var rightThrottleLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        manager = CBCentralManager(delegate: self, queue: nil)
        
        leftThrottle = UIPanGestureRecognizer(target: self, action: #selector(getThrottleValue(sender:)))
        leftView.addGestureRecognizer(leftThrottle)
        leftThrottle.isEnabled = false
        
        rightThrottle = UIPanGestureRecognizer(target: self, action: #selector(getThrottleValue(sender:)))
        rightView.addGestureRecognizer(rightThrottle)
        rightThrottle.isEnabled = false
    }
    
    func startPeripheralScan() {
        manager?.scanForPeripherals(withServices: [CBUUID.init(string: BLEService)], options: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.stopPeripheralScan()
        }
    }
    
    func stopPeripheralScan() {
        manager?.stopScan()
    }
    
    // User Interface Methods
    @IBAction func actionButtonPressed(_ sender: AnyObject) {
        // Scan for devices
        actionButton.setTitle("Close", for: [])
        leftSpeedLabel.text = "Left Motor Speed"
        rightSpeedLabel.text = "Right Motor Speed"

        if peripheralConnected == false {
            if peripheralList.isHidden == false {
                peripheralList.isHidden = true
                leftSpeedLabel.isHidden = false
                rightSpeedLabel.isHidden = false
                actionButton.setTitle("Connect", for: [])
            } else {
                leftSpeedLabel.isHidden = true
                rightSpeedLabel.isHidden = true
                peripheralList.isHidden = false
                startPeripheralScan()
            }
        } else if peripheralConnected == true {
            if confirmDisconnection == false {
                actionButton.setTitle("Disconnect", for: [])
                actionButton.setTitleColor(UIColor(red:1.00, green:0.23, blue:0.19, alpha:1.0), for: [])
                confirmDisconnection = true
            } else if confirmDisconnection == true {
                leftThrottle.isEnabled = false
                rightThrottle.isEnabled = false
                manager?.cancelPeripheralConnection(mainPeripheral!)
            }
        }
    }

    @objc func getThrottleValue(sender: UIPanGestureRecognizer) {
        if sender.view == leftView {
            if sender.state == .began {
                leftThrottleInitial = sender.location(in: leftView)
                leftThrottleValue = 0
                leftThrottleLayer.removeFromSuperlayer()
                leftThrottleLayer = CAShapeLayer()
            } else if sender.state == .changed {
                leftThrottleCurrent = sender.location(in: leftView)
                leftThrottleChange = sender.translation(in: leftView)
                leftThrottleValue = -1 * Int(Float(leftThrottleChange.y))
                
                if leftThrottleValue > 100 {
                    leftThrottleValue = 100
                } else if leftThrottleValue < -100 {
                    leftThrottleValue = -100
                }
                
                leftThrottlePath = UIBezierPath()
                leftThrottlePath.move(to: leftThrottleInitial)
                leftThrottlePath.addLine(to: CGPoint(x: leftThrottleInitial.x, y: leftThrottleCurrent.y))
                leftThrottlePath.close()
                leftThrottleLayer.path = leftThrottlePath.cgPath
                
                if leftThrottleValue < 0 {
                    leftThrottleLayer.strokeColor = self.red.cgColor
                } else if leftThrottleValue > 0 {
                    leftThrottleLayer.strokeColor = self.green.cgColor
                } else {
                    leftThrottleLayer.strokeColor = UIColor.clear.cgColor
                }
                
                leftThrottleLayer.lineJoin = .round
                leftThrottleLayer.lineWidth = 20
                leftView.layer.addSublayer(leftThrottleLayer)
            } else if sender.state == .ended {
                leftThrottleValue = 0
                leftThrottlePath.removeAllPoints()
                leftThrottleLayer.removeFromSuperlayer()
                leftThrottleLayer = CAShapeLayer()
                leftSpeedLabel.text = "Left Motor: 0"
            }
        } else if sender.view == rightView {
            if sender.state == .began {
                rightThrottleInitial = sender.location(in: rightView)
                rightThrottleValue = 0
                rightThrottleLayer.removeFromSuperlayer()
                rightThrottleLayer = CAShapeLayer()
            } else if sender.state == .changed {
                rightThrottleCurrent = sender.location(in: rightView)
                rightThrottleChange = sender.translation(in: rightView)
                rightThrottleValue = -1 * Int(Float(rightThrottleChange.y))
                
                if rightThrottleValue > 100 {
                    rightThrottleValue = 100
                } else if rightThrottleValue < -100 {
                    rightThrottleValue = -100
                }
                
                rightThrottlePath = UIBezierPath()
                rightThrottlePath.move(to: rightThrottleInitial)
                rightThrottlePath.addLine(to: CGPoint(x: rightThrottleInitial.x, y: rightThrottleCurrent.y))
                rightThrottlePath.close()
                rightThrottleLayer.path = rightThrottlePath.cgPath
                
                if rightThrottleValue < 0 {
                    rightThrottleLayer.strokeColor = self.red.cgColor
                } else if rightThrottleValue > 0 {
                    rightThrottleLayer.strokeColor = self.green.cgColor
                } else {
                    rightThrottleLayer.strokeColor = UIColor.clear.cgColor
                }
                
                rightThrottleLayer.lineJoin = .round
                rightThrottleLayer.lineWidth = 20
                rightView.layer.addSublayer(rightThrottleLayer)
            } else if sender.state == .ended {
                rightThrottleValue = 0
                rightThrottlePath.removeAllPoints()
                rightThrottleLayer.removeFromSuperlayer()
                rightThrottleLayer = CAShapeLayer()
                rightSpeedLabel.text = "Right Motor: 0"
            }
        }
        
        sendThrottleValues()
    }
    
    func sendThrottleValues() {
        let leftData = 4 * leftThrottleValue
        let rightData = 4 * rightThrottleValue
        
        leftSpeedLabel.text = "Left Motor: " + String(leftData)
        rightSpeedLabel.text = "Right Motor: " + String(rightData)
        
        var leftSign = "p"
        if leftData < 0 {
            leftSign = "n"
        }
        
        var rightSign = "p"
        if rightData < 0 {
            rightSign = "n"
        }
        
        var leftString = String(abs(leftData))
        if leftString.count == 2 {
            leftString = "0" + leftString
        } else if leftString.count == 1 {
            leftString = "00" + leftString
        }
        
        var rightString = String(abs(rightData))
        if rightString.count == 2 {
            rightString = "0" + rightString
        } else if rightString.count == 1 {
            rightString = "00" + rightString
        }
        
        let message = "<" + leftSign + leftString + rightSign + rightString + ">"
        let encoded = message.data(using: String.Encoding.utf8)
        if mainCharacteristic != nil {
            mainPeripheral?.writeValue(encoded!, for: mainCharacteristic!, type: CBCharacteristicWriteType.withoutResponse)
        } else {
            print("Device characteristics not read")
        }
    }
    
    // TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "List Item", for: indexPath)
        let peripheral = peripherals[indexPath.row]
        cell.textLabel?.text = peripheral.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheral = peripherals[indexPath.row]
        manager?.connect(peripheral, options: nil)
    }
    
    // CBCentralManagerDelegate Methods
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if(!peripherals.contains(peripheral)) {
            peripherals.append(peripheral)
        }
        
        peripheral.delegate = self
        peripheralList.reloadData()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central.state)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Change the appearance of the connect button to read "connected"
        actionButton.setTitle("Connected", for: [])
        actionButton.setTitleColor(UIColor(red:0.30, green:0.85, blue:0.39, alpha:1.0), for: [])
        confirmDisconnection = false
        
        mainPeripheral = peripheral
        peripheral.discoverServices(nil)
        
        peripheralConnected = true
        peripheralList.isHidden = true
        leftSpeedLabel.isHidden = false
        rightSpeedLabel.isHidden = false
        leftThrottle.isEnabled = true
        rightThrottle.isEnabled = true
        
        print("Connected to " + peripheral.name!)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        // Display an alert saying that there was an error connecting
        let alertController = UIAlertController(title: "Connection Error", message: "Unable to connect, please retry.", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
        print(error!)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        // Change the appearance of the connect button to read "connect"
        actionButton.setTitle("Connect", for: [])
        actionButton.setTitleColor(UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0), for: [])
        
        mainPeripheral = nil
        peripheralConnected = false
        leftSpeedLabel.text = "Left Motor Speed"
        rightSpeedLabel.text = "Right Motor Speed"
        print("Disconnected from " + peripheral.name!)
    }
    
    // CBPeripheralDelegate Methods
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            print("Service found with UUID: " + service.uuid.uuidString)
            
            // Access the device information service
            if (service.uuid.uuidString == "180A") {
                peripheral.discoverCharacteristics(nil, for: service)
            }
            // Access the GAP (Generic Access Profile) for the device name
            if (service.uuid.uuidString == "1800") {
                peripheral.discoverCharacteristics(nil, for: service)
            }
            // Access the Bluno service
            if (service.uuid.uuidString == BLEService) {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // Get the device name
        if (service.uuid.uuidString == "1800") {
            for characteristic in service.characteristics! {
                if (characteristic.uuid.uuidString == "2A00") {
                    peripheral.readValue(for: characteristic)
                    print("Found Device Name Characteristic")
                }
            }
        }
        // Get the device manufacturer name
        if (service.uuid.uuidString == "180A") {
            for characteristic in service.characteristics! {
                if (characteristic.uuid.uuidString == "2A29") {
                    peripheral.readValue(for: characteristic)
                    print("Found a Device Manufacturer Name Characteristic")
                } else if (characteristic.uuid.uuidString == "2A23") {
                    peripheral.readValue(for: characteristic)
                    print("Found System ID")
                }
            }
        }
        // Get the device characteristic
        if (service.uuid.uuidString == BLEService) {
            for characteristic in service.characteristics! {
                if (characteristic.uuid.uuidString == BLECharacteristic) {
                    // Save the reference in order to write data
                    mainCharacteristic = characteristic
                    print("Found Bluno Data Characteristic")
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if (characteristic.uuid.uuidString == "2A00") {
            // Receive the device name
            let deviceName = characteristic.value
            print(deviceName ?? "No Device Name")
        } else if (characteristic.uuid.uuidString == "2A29") {
            // Receive the manufacturer name
            let manufacturerName = characteristic.value
            print(manufacturerName ?? "No Manufacturer Name")
        } else if (characteristic.uuid.uuidString == "2A23") {
            // Receive the system ID
            let systemID = characteristic.value
            print(systemID ?? "No System ID")
        }
    }
}
