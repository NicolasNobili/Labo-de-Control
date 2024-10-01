#include "TimerOne.h"

typedef union{
  float number;
  uint8_t bytes[4];
} FLOATUNION_t;

void setup()
{
  Serial.begin(115200);
}


// Parámetros del controlador Tustin
//double K1 = -2.441;   // Coeficiente para e[n]
//double K2 = 2.4355;   // Coeficiente para e[n-1]


// Parámetros del controlador Forward
double T = 1;
double p = 0.00237;
double k = -2.4378;
//double K1 = k*(1+p*T);   // Coeficiente para e[n]
//double K2 = -k*p*T;   // Coeficiente para e[n-1]

// Parámetros del controlador Backward
double K1 = k*(1+p*T);   // Coeficiente para e[n]
double K2 = -k;   // Coeficiente para e[n-1]



double previousError = 0; // e[n-1]
double previousOutput = 0; // u[n-1]

void loop()
{
  // Ajustar condiciones iniciales de trabajo
  static float u0=0.5, h_ref=0.4, h=0.45, u;
  static float Ts=1;
  FLOATUNION_t aux;
  static float sampling_period_ms = 1000*Ts;
  //=========================
  // Definir parametros y variables del control

  //=========================

  if (Serial.available() >= 4) {
    aux.number = getFloat();
    h = aux.number;
  }
  //=========================
  //CONTROL

  // Calcular el error actual
  float currentError = h_ref - h;
  
  // Calcular la salida del controlador
  float currentOutput = K1 * currentError + K2 * previousError + previousOutput;
  u = u0 + currentOutput;
    
  previousError = currentError;
  previousOutput = currentOutput;
  
  //=========================
    
  matlab_send(u);
  delay(sampling_period_ms);
}

void matlab_send(float u){
  Serial.write("abcd");
  byte * b = (byte *) &u;
  Serial.write(b,4);
}

float getFloat(){
    int cont = 0;
    FLOATUNION_t f;
    while (cont < 4 ){
        f.bytes[cont] = Serial.read() ;
        cont = cont +1;
    }
    return f.number;
}
