
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
float theta_0 = 0;
float theta = theta_0;
int esPrimeraMedicion = 0;
float theta3 = 0;
float alpha = 0.5;
float theta2 = 0;
void loop() {
  
  unsigned long startTime = micros();
  /* Get new sensor events with the readings */ 
  sensors_event_t a, g, temp;
  mpu.getEvent(&a, &g, &temp);

  
  if (esPrimeraMedicion == 0){
    theta = theta_0 + g.gyro.x * 0.01;
    esPrimeraMedicion = 0;
  }
  else{
    theta += theta3 + g.gyro.x * 0.01;
  }
  
  theta2 = atan2(a.acceleration.y,a.acceleration.z);
  
  theta3 = theta *(1-alpha) + theta*alpha;
  float data_send[3]={theta , theta2, theta3};
  serial_sendN(data_send,3);

  

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


void serial_sendN(float datos[], int N) {
  /*
  Envía N floats a través del puerto serie
  */
  Serial.write("abcd");  // Etiqueta o cabecera para indicar inicio de la transmisión
  
  for (int i = 0; i < N; i++) {
    byte * b = (byte *) &datos[i];  // Convierte el float actual en una secuencia de bytes
    Serial.write(b, 4);  // Envía los 4 bytes que componen el float
  }
}
