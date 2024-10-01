
void setup() {
  Serial.begin(115200);

}
// Parámetros del controlador
double T = 1
double p = 0.00237
double k = -2.4378
double K1 = k*(1+p*T);   // Coeficiente para e[n]
double K2 = -k*p*T;   // Coeficiente para e[n-1]

double previousError = 0; // e[n-1]
double previousOutput = 0; // u[n-1]

void loop() {
   
  double reference = analogRead(A0); // 
  double output = analogRead(A1); 
  
  // Calcular el error actual
  double currentError = reference - output;

  // Calcular la salida del controlador
  double currentOutput = K1 * currentError + K2 * previousError + previousOutput;

  // Aplicar la salida (por ejemplo, a un actuador)
  applyOutput(currentOutput); // Implementa esta función para enviar la salida al actuador

  
  previousError = currentError;
  previousOutput = currentOutput;

  
  delay(1000);
}



// Función para aplicar la salida al actuador
void applyOutput(double output) {
  // Asegúrate de que la salida esté en el rango correcto
  output = constrain(output, 0, 255); // Suponiendo que estás usando PWM en el rango 0-255
  analogWrite(9, output); // Cambia 9 por el pin que estás utilizando para la salida
}
