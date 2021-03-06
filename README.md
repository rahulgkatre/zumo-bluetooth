# Zumo Bluetooth

This is the code I wrote for both the DFRobot Bluno in the Polulu Zumo robot and the iOS app that controls the robot over Bluetooth. In order to upload the code to the Bluno, you must download Pololu's Zumo Shield library, which can be found here: https://github.com/pololu/zumo-shield-arduino-library. The Bluno is connected to the robot via the shield, and this library allows the motors to be controlled, as well as other components built into the shield. 

The iOS app uses virtual joysticks to control the robot, and has an interface for connecting to the robot over Bluetooth. There are no external dependencies in the app, but I did base the underlying communication code for pairing and establishing serial connection on this example demo from DFRobot: https://github.com/DFRobot/BlunoBasicDemo. From here, I developed a method of formatting the inputs from the virtual joysticks as a sort of vector with the notation "<L,R>", and wrote code to digest the serial values on the robot side. 

Parts list:

- [Pololu Zumo Robot for Arduino](https://www.pololu.com/category/169/zumo-robot-for-arduino)

- [DFRobot Bluno](https://www.dfrobot.com/product-1044.html)
