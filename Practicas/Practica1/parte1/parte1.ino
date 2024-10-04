// Definir el pin donde está conectado el potenciómetro
const int potPin = A0;

void setup() {
  // Iniciar la comunicación serial
  Serial.begin(115200);
}

void loop() {

  /* 
  //Tarea 1 

  // Leer el valor analógico del potenciómetro
  int potValue = analogRead(potPin);

  // Imprimir el valor en el monitor serial
  Serial.println(potValue);

  */

 /*
  //Tarea 2 

  // Leer el valor analógico del potenciómetro
  int potValue = analogRead(potPin);

  // Imprimir el valor en el monitor serial

  int angle = map(potValue, 0, 1023, 0, 285);
  Serial.println(angle);

*/


  // Tarea 3

  // Marcar el inicio del ciclo
  unsigned long startTime = micros();

  // Leer el valor analógico del potenciómetro
  float potValue = analogRead(potPin);

  // Mapear el valor del potenciómetro de 0-1023 a 0-270 grados
  float angle = potValue * 285/1023;

  // Imprimir el valor en grados en el monitor serial
  Serial.print("Grados: ");
  Serial.println(angle);  
  // Calcular el tiempo que ha transcurrido en este ciclo
  unsigned long elapsedTime = (micros() - startTime);
  delayMicroseconds(10000 - elapsedTime);
}
