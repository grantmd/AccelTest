/*
  The simplest possible test code for the ADXL345 accelerometer, specifically as packaged
  in the IMU Digital Combo Board - 6 Degrees of Freedom ITG3200/ADXL345 from Sparkfun:
  http://www.sparkfun.com/products/10121
  
  Created by Myles Grant <myles@mylesgrant.com>
  See also: https://github.com/grantmd/QuadCopter
  
  This program is free software: you can redistribute it and/or modify 
  it under the terms of the GNU General Public License as published by 
  the Free Software Foundation, either version 3 of the License, or 
  (at your option) any later version. 

  This program is distributed in the hope that it will be useful, 
  but WITHOUT ANY WARRANTY; without even the implied warranty of 
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
  GNU General Public License for more details. 

  You should have received a copy of the GNU General Public License 
  along with this program. If not, see <http://www.gnu.org/licenses/>. 
*/

#include <Wire.h>

#define I2C_ADDR 0x53 // The i2c address of the accelerometer

unsigned long previousTime = 0;

void setup(){
  Serial.begin(115200);
  Wire.begin();
  
  accelInit();
  
  previousTime = millis();
}

void loop(){
  if (millis() - previousTime >= 5000){
    readAll();
    
    previousTime = millis();
  }
}

// Verify the accelerometer is present and write some configuration to it
void accelInit(){
  Serial.println("Initing Accel");
  
  if (!getAddressFromDevice()){
    Serial.println("ACCEL NOT CONNECTED!");
  }
  else{
    writeSetting(0x2D, 0x00); // Shut down
    writeSetting(0x2D, 0x16); // Reset
    writeSetting(0x2D, 0x08); // Power up, measure mode
    writeSetting(0x2C, 0x0A); // 100Hz low pass filter
    writeSetting(0x31, 0x00); // ±2 g
  }
}

// Read "all" the data off the accelerometer and print it
void readAll(){
  sendReadRequest(0x32);
  requestBytes(6);

  for (byte axis = 0; axis <= 2; axis++) {
    Serial.print("Axis ");
    Serial.print(axis, DEC);
    Serial.print(": ");
    Serial.println(readNextWordFlip());
  }
}

//
// I2C helper functions
//

// Read the address off of the device
byte getAddressFromDevice(){
  sendReadRequest(0x00);
  return readByte();
}

// Write a setting to the device at register data_address
byte writeSetting(byte data_address, byte data_value){
  Wire.beginTransmission(I2C_ADDR);
  Wire.send(data_address);
  Wire.send(data_value);
  return Wire.endTransmission();
}

// Tell the device that we will be reading from register data_address
byte sendReadRequest(byte data_address){
  Wire.beginTransmission(I2C_ADDR);
  Wire.send(data_address);
  return Wire.endTransmission();
}

// Request 2 bytes and read it
word readWord(){
  requestBytes(2);
  return ((Wire.receive() << 8) | Wire.receive());
}

// Request 2 bytes and read it
word readWordFlip(){
  requestBytes(2);
  byte one = Wire.receive();
  byte two = Wire.receive();
  return ((two << 8) | one);
}

// Request a byte and read it
byte readByte(){
  requestBytes(1);
  return Wire.receive();
}

// Request some number of bytes
void requestBytes(int bytes){
  Wire.beginTransmission(I2C_ADDR);
  Wire.requestFrom(I2C_ADDR, bytes);
}

// Read the next available byte
byte readNextByte(){
  return Wire.receive();
}

// Read the next available 2 bytes
word readNextWord(){
  return ((Wire.receive() << 8) | Wire.receive());
}

// Read the next available 2 bytes
word readNextWordFlip(){
  byte one = Wire.receive();
  byte two = Wire.receive();
  return ((two << 8) | one);
}
