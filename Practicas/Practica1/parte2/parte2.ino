#include <Servo.h>  // Incluir la librería Servo

Servo myServo;  // Crear un objeto Servo para controlar el servo


void setup() {
  myServo.attach(9);  // Conectar el servo al pin digital 9
}

/*
// Tarea 1
void loop() {
  // Mover el servo a 0 grados
  myServo.writeMicroseconds(500);
  delay(3000);  // Esperar 3 segundo

  // Mover el servo a 90 grados
  myServo.writeMicroseconds(1500);
  delay(3000);  // Esperar 3 segundo

  // Mover el servo a 180 grados
  myServo.writeMicroseconds(2500);
  delay(3000);  // Esperar 3 segundo
}
*/

// Tarea 2
void loop() {
  // Mover el servo a 0 grados
  myServo.write(0);
  delay(3000);  // Esperar 1 segundo

  // Mover el servo a 90 grados
  myServo.write(90);
  delay(3000);  // Esperar 1 segundo

  // Mover el servo a 180 grados
  myServo.write(180);
  delay(3000);  // Esperar 1 segundo
}

