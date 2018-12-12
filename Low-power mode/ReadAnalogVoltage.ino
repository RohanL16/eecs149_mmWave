/*
  ReadAnalogVoltage
  Reads an analog input on pin A3, converts it to voltage, and prints the result to the serial monitor.
  Attach the center pin of a potentiometer to pin A3, and the outside pins to +3V and ground.
  
  Hardware Required:
  * MSP-EXP430G2 LaunchPad
  * Potentiometer
 
  This example code is in the public domain.
*/
const int numReadings = 5;

int readings[numReadings]; // the readings from the analog input
int index = 0; // the index of the current reading
int maximum = 0;
int val;
bool state = false;


// the setup routine runs once when you press reset:
void setup() {
  // initialize serial communication at 9600 bits per second:
  Serial.begin(9600); // msp430g2231 must use 4800
  for (int thisReading = 0; thisReading < numReadings; thisReading++) {
    readings[thisReading] = 0;
  }
  pinMode(31, OUTPUT);
  
}

// the loop routine runs over and over again forever:
void loop() {
  // read the input on analog pin A3:
  int sensorValue = analogRead(A3);
  Serial.println(sensorValue);
  
  // read from the sensor:
  readings[index] = sensorValue;
  if (sensorValue > maximum) {
    maximum = sensorValue;
  }
  index = index + 1;
  

  // if we're at the end of the array...
  if (index >= numReadings) {
    // ...wrap around to the beginning:
    index = 0;
    Serial.println(maximum);
    if (maximum > 3000) {
       if (state == false) {
        digitalWrite(31, HIGH);
        delay(500);
        digitalWrite(31, LOW); 
        state = true;
       }
    } else {
       if (state == true) {
        digitalWrite(31, HIGH);
        delay(500);
        digitalWrite(31, LOW);
        state = false;
       }
    }
    maximum = 0;
    val = digitalRead(31);
    Serial.println(val);
    Serial.println(00000000000000);
  }
  
  delay(1000);

 

}
