#include <Wire.h>
#include <ZumoShield.h>

ZumoMotors motors;

const byte charLimit = 10;
char inputs[charLimit];

boolean newInput = false;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  Serial.println("<Bluno is ready>");
}

void loop() {
    // put your main code here, to run repeatedly:
    delay(5);
    readValuesFromSerial();
    setMotorsFromValues();
}

void readValuesFromSerial() {
    // read the transmitted throttle values
    static boolean readInProgress = false;
    static byte index = 0;
    char startMarker = '<';
    char endMarker = '>';
    char currentChar;

  // parse the string to find the values
    while (Serial.available() > 0 && newInput == false) {
        currentChar = Serial.read();

        if (readInProgress == true) {
            if (currentChar != endMarker) {
                inputs[index] = currentChar;
                index += 1;    
                if (index >= charLimit) {
                    index = charLimit - 1;
                }
            } else {                
                inputs[index] = '\0';
                readInProgress = false;
                index = 0;
                newInput = true;
            }
        } else if (currentChar == startMarker) {
          readInProgress = true;
        }
    }
}

void setMotorsFromValues() {
    if (newInput == true) {
        int leftSpeed = 0;
        leftSpeed += 100 * (inputs[1] - '0');
        leftSpeed += 10 * (inputs[2] - '0');
        leftSpeed += 1 * (inputs[3]- '0');
        if(inputs[0] == 'n') {
            leftSpeed = -1 * leftSpeed;
        }

        int rightSpeed = 0;
        rightSpeed += 100 * (inputs[5] - '0');
        rightSpeed += 10 * (inputs[6] - '0');
        rightSpeed += 1 * (inputs[7]- '0');
        if(inputs[4] == 'n') {
            rightSpeed = -1 * rightSpeed;
        }

        Serial.println("Left: " + String(leftSpeed) + "\nRight: " + String(rightSpeed));
        motors.setSpeeds(leftSpeed, rightSpeed);
        newInput = false;
    }
}
