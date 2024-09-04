
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <Wire.h>

#define SCALER_DATA 4

Adafruit_MPU6050 mpu;


void setup() {
  Serial.begin(115200);
  delay(10); // will pause Zero, Leonardo, etc until serial console opens

  Serial.println("Adafruit MPU6050 test!");

  // Try to initialize!
  if (!mpu.begin()) {
    Serial.println("Failed to find MPU6050 chip");
    while (1) {
      delay(10);
    }
  }
  mpu.setAccelerometerRange(MPU6050_RANGE_8_G);

  mpu.setGyroRange(MPU6050_RANGE_500_DEG);

  mpu.setFilterBandwidth(MPU6050_BAND_44_HZ);
 
  delay(100);

 
}


int contadorData = 10;
float elapsedTime = 0;
void loop() {
  
  unsigned long startTime = micros();
  /* Get new sensor events with the readings */ 
  sensors_event_t a, g, temp;
  mpu.getEvent(&a, &g, &temp);

  if(contadorData == 0){
    //matlab_send6(a.acceleration.x,a.acceleration.y,a.acceleration.z,g.gyro.x,g.gyro.y,g.gyro.z);
    matlab_send7(a.acceleration.x,a.acceleration.y,a.acceleration.z,g.gyro.x,g.gyro.y,g.gyro.z,elapsedTime);
    contadorData = SCALER_DATA;
  }
  contadorData--;
  elapsedTime = micros() - startTime;
  delayMicroseconds(10000- elapsedTime);
}


void matlab_send6(float dato1, float dato2, float dato3,float dato4, float dato5, float dato6){
  Serial.write("abcd");
  byte * b = (byte *) &dato1;
  Serial.write(b,4);
  b = (byte *) &dato2;
  Serial.write(b,4);
  b = (byte *) &dato3;
  Serial.write(b,4);
  b = (byte *) &dato4;
  Serial.write(b,4);
  b = (byte *) &dato5;
  Serial.write(b,4);
  b = (byte *) &dato6;
  Serial.write(b,4);
  
  //etc con mas datos tipo float. Tambien podría pasarse como parámetro a esta funcion un array de floats.
}

void matlab_send7(float dato1, float dato2, float dato3,float dato4, float dato5, float dato6, float dato7){
  Serial.write("abcd");
  byte * b = (byte *) &dato1;
  Serial.write(b,4);
  b = (byte *) &dato2;
  Serial.write(b,4);
  b = (byte *) &dato3;
  Serial.write(b,4);
  b = (byte *) &dato4;
  Serial.write(b,4);
  b = (byte *) &dato5;
  Serial.write(b,4);
  b = (byte *) &dato6;
  Serial.write(b,4);
  b = (byte *) &dato7;
  Serial.write(b,4);
  
  //etc con mas datos tipo float. Tambien podría pasarse como parámetro a esta funcion un array de floats.
}
