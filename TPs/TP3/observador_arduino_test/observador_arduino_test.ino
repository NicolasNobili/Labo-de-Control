//================================================================================
//
//                               BIBLIOTECAS
//
//================================================================================

#include <Arduino.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <Wire.h>


//================================================================================
//
//                           MACROS y CONSTANTES
//
//================================================================================


// MACROS PWM SERVO
#define CLK_FREQUENCY 16000000 // f_clock = 16MHz
#define PWM_PERIOD_US 10000 // T=10ms ^ f=100Hz
#define PWM_MAX_TON_US 2500 // Ton_max = 2.5ms
#define PWM_MIN_TON_US 500 // Ton_min = 0.5ms
#define TOP_PWM ((unsigned long)(CLK_FREQUENCY / 8) / (2 * 100))  // Cálculo del valor TOP para el modo Phase Correct, con un prescaler de 8
#define MAX_OCR1A (TOP_PWM - (TOP_PWM * PWM_MIN_TON_US / PWM_PERIOD_US)) // OCR1A para Ton = 0.5ms
#define MIN_OCR1A (TOP_PWM - (TOP_PWM * PWM_MAX_TON_US / PWM_PERIOD_US)) // OCR1A para Ton = 2.5ms
#define PIN_SERVO 1 // pin PB1 de atmega328p o pin 9 arduino uno/nano

// MACROS/CONSTANTES SENSORES
const int potPin = A0; // PIN POTENCIOMETRO
const float pi = 3.1416; // PI
const int nbias = 200; // Cantidad de iteraciones para estimar el bias
float bias_gyroX = 0; // Bias del giroscopio en X
float bias_accY = 0; // Bias del Acelerometro en Y
float bias_pote = 0;

// MACROS/COSNTANTES LED
const int pinLed = 7;

// MACROS/CONSTANTES CONTROLADOR
#define CTRL_PERIOD 10000.0 // T = 10000us -> f=100Hz
#define CTRL_PERIOD_S 0.01 // T = 0.01s -> f=100Hz
const float u_min = -50*pi/180;
const float u_max = 50*pi/180;
const float k = -0.4;

// MACROS/CONSTANTES OBSERVADOR
const float L[4][2] = {
        {0.9745, -0.1256},
        {18.3409, -6.5490},
        {-0.0355, 0.6620},
        {-1.2690, -1.2647}
    }; 

// MACROS/CONSTANTES PLANTA
const float Ad[4][4] = {
        {0.9969, 0.0100, 0.0099, 0.0012},
        {-0.6172, 0.9938, 1.8783, 0.2377},
        {0.0, 0.0, 0.9878, 0.0085},
        {0.0, 0.0, -2.3071, 0.7081}
    };

const float Bd[4] = {-0.0111, -2.1005, 0.0135, 2.5800};

// MACROS MATLAB/SIMULINK
#define SCALER_SEND_DATA 4 // scaler de la frecuencia de control para enviar datos a SIMULINK



//================================================================================
//
//                                   SETUP
//
//================================================================================

// Creo una instancia de IMU MPU6050
Adafruit_MPU6050 mpu;

void setup() {
  // CONFIGURACION COMUNICACION SERIAL
  Serial.begin(115200);

  // Inicilizo el pin pinLed como output.
  pinMode(pinLed, OUTPUT);

  // CONFIGURACION IMU
  mpu.begin();
  mpu.setAccelerometerRange(MPU6050_RANGE_8_G);
  mpu.setGyroRange(MPU6050_RANGE_500_DEG);
  mpu.setFilterBandwidth(MPU6050_BAND_44_HZ);
  delay(100);

  // CONFIGURACION SERVO
  float u_0 = 0;
  config_servo(phi_a_ton(u_0));
  delay(10000);

  // ESTIMACION DE LOS SESGOS DE accY y gyroX

  for (int i = 0; i < nbias ; i++) {
    // Get new sensor events with the readings 
    sensors_event_t a, g, temp;
    mpu.getEvent(&a, &g, &temp);

    // Acumula las lecturas
    bias_gyroX += g.gyro.x;
    bias_accY += a.acceleration.y;
    bias_pote += leer_angulo_potenciometro(potPin);

    delay(10); // Espera 10 ms entre lecturas
  }  
  // Calculo el sesgo promedio
  bias_gyroX = bias_gyroX/nbias; 
  bias_accY = bias_accY/nbias;
  bias_pote = bias_pote/nbias;

  // Prendo led para indicar que termino la rutina de calibrado
  digitalWrite(pinLed,HIGH);
}



//================================================================================
//
//                                 MAIN LOOP
//
//================================================================================
float theta_g = 0; // Angulo del pendulo estimado con giroscopo
float theta_a = 0; // Angulo del pendulo estimaod con acelerometro
float theta_f = 0; // Angulo del pendulo estimaod con filtro complementario (este valor fija una condicion inicial!!)
float alpha = 0.03; // Parametro del filtro complementario

float phi = 0; // Angulo del barzo del servo con respecto al eje x en sentido antihorario
float phi_1 = 0; // phi anterior
float phi_punto = 0;
float u = 0; // Accion de control
float e = 0; // Error


// Estado Actual y Estado posterior (para observador y controlador)
float theta_monio_actual = 0;
float theta_monio_posterior = 0;

float theta_punto_monio_actual = 0;
float theta_punto_monio_posterior = 0;

float phi_monio_actual = 0;
float phi_monio_posterior = 0;

float phi_punto_monio_actual = 0;
float phi_punto_monio_posterior = 0;

// Delay escalon de 1s
int counter_step = 0;
float step_ref[4] =  {0.2,-0.2,0.4,-0.4};

void loop() {
  // Se toma el tiempo de inicio de ejecucion de la rutina de control
  unsigned long startTime = micros();

  // Delay para las respuesta al escalon:
  if(counter_step % 1000  == 0){
    int i = counter_step / 1000;
    if (i < sizeof(step_ref) / sizeof(step_ref[0])) {
        u = step_ref[i];
    }
  }

  counter_step++;

  // Get new sensor events with the readings 
  sensors_event_t a, g, temp;
  mpu.getEvent(&a, &g, &temp);
 
  // MEDICIONES
    // Estimacion angulo pendulo
  theta_g = theta_f + 0.01 * (g.gyro.x-bias_gyroX); // Se integra sobre la velocidad angular en X
  theta_a = atan2((a.acceleration.y-bias_accY),a.acceleration.z); 
  theta_f = theta_g *(1-alpha) + theta_a * alpha;

    // Lectura angulo brazo servo
  phi = leer_angulo_potenciometro(potPin) - bias_pote;
    //
  actualizar_servo(phi_a_ton(u));

  // OBSERVADOR
    // Estimacion de theta, theta_punto, phi y phi_punto en base a el observador de Lurenberg
  theta_monio_posterior =       Ad[0][0] * theta_monio_actual + Ad[0][1] * theta_punto_monio_actual + Ad[0][2] * phi_monio_actual + Ad[0][3] * phi_punto_monio_actual + Bd[0] * u + L[0][0] * (theta_f - theta_monio_actual) + L[0][1] * (phi - phi_monio_actual);   
  theta_punto_monio_posterior = Ad[1][0] * theta_monio_actual + Ad[1][1] * theta_punto_monio_actual + Ad[1][2] * phi_monio_actual + Ad[1][3] * phi_punto_monio_actual + Bd[1] * u + L[1][0] * (theta_f - theta_monio_actual) + L[1][1] * (phi - phi_monio_actual); 
  phi_monio_posterior =         Ad[2][0] * theta_monio_actual + Ad[2][1] * theta_punto_monio_actual + Ad[2][2] * phi_monio_actual + Ad[2][3] * phi_punto_monio_actual + Bd[2] * u + L[2][0] * (theta_f - theta_monio_actual) + L[2][1] * (phi - phi_monio_actual); 
  phi_punto_monio_posterior =   Ad[3][0] * theta_monio_actual + Ad[3][1] * theta_punto_monio_actual + Ad[3][2] * phi_monio_actual + Ad[3][3] * phi_punto_monio_actual + Bd[3] * u + L[3][0] * (theta_f - theta_monio_actual) + L[3][1] * (phi - phi_monio_actual); 


  // Estimo derivada de phi para comparar con la magnitud observada
  phi_punto = (phi - phi_1)/CTRL_PERIOD_S;
  phi_1 = phi;
  // ENVIO DE DATOS A MATLAB (comentar si no se esta haciendo ninguna prueba)
    // Junto los datos en un array y los envio por puerto serie  
  float data[8] = {theta_f, theta_monio_actual, g.gyro.x-bias_gyroX, theta_punto_monio_actual, phi, phi_monio_actual, phi_punto, phi_punto_monio_actual};
  serial_sendN(data,8);

  // Actualizacion variables del observador
  theta_monio_actual = theta_monio_posterior;
  theta_punto_monio_actual = theta_punto_monio_posterior;
  phi_monio_actual = phi_monio_posterior;
  phi_punto_monio_actual = phi_punto_monio_posterior;

  // Se calcula el tiempo transcurrido en microsegundos y se hace un delay tal para fijar la frecuencia del control digital  
  float elapsedTime = micros() - startTime;
  if(elapsedTime < CTRL_PERIOD){
    delayMicroseconds(CTRL_PERIOD - elapsedTime);
  }
}



//================================================================================
//
//                                  FUNCIONES
//
//================================================================================


//==================================================
//                    SENSORES
//==================================================

float leer_angulo_potenciometro(int pin){
  /*
  Se lee el valor de tension del potenciometro entre 0V y 5V
  */
  float potValue = analogRead(pin);
  // Se tranforma la lectura en un angulo
  float angulo_pote = potValue * (285)/1023 * (pi/180) ;
  return angulo_pote;
}



//==================================================
//               FUNCIONES PWM SERVO
//==================================================

void config_servo(unsigned int t_on0){
  /* 
  La funcion configura el Timer 1 para obtener una salida PWM por el pin PIN_SERVO
  con un periodo de PWM_PERIOD. La misma recive como parametro el tiempo en alto
  inicial del PWM en microsegundos (debe estar entre 500us y 2500us). 
  */
  // Configuro PB1(OC1A) como output (pin 9 arduino uno)
  DDRB = (1<<PIN_SERVO);

  // Seteo la frecuencia del PWM en 100Hz fijando el valor de ICR1
  ICR1H = (TOP_PWM >> 8);
  ICR1L = (TOP_PWM & 0xFF);

  //Set OC1A on compare match when up-counting.
  //Clear OC1A on compare match when down-counting.
  //Phase Correct PWM, top en ICR1, prescaler 1/8
  TCCR1A = (1 << COM1A1) | (1 << COM1A0) | (0 << COM1B1) | (0 << COM1B0) | (1 << WGM11) | (0 << WGM10);
  TCCR1B = (1 << WGM13) | (0 << WGM12) | (0 << CS12) | (1 << CS11) | (0 << CS10);

  unsigned int ocr1a = map(t_on0, PWM_MIN_TON_US, PWM_MAX_TON_US, MAX_OCR1A, MIN_OCR1A);
  // Actualizar OCR1AH y OCR1AL
  OCR1AH = (ocr1a >> 8);
  OCR1AL = (ocr1a & 0xFF);
}


void actualizar_servo(unsigned int t_on){
  /*
  La funcion actualiza el tiempo en alto de la senal PWM del timer 1
  con un tiempo t_on entre 500us y 2500us 
  */
  unsigned int ocr1a = map(t_on, PWM_MIN_TON_US, PWM_MAX_TON_US, MAX_OCR1A, MIN_OCR1A);
  // Actualizar OCR1AH y OCR1AL
  OCR1AH = ((ocr1a >> 8) & 0xFF);
  OCR1AL = (ocr1a & 0xFF);
}

int phi_a_ton(float phi){
  int ton = int(1500 + (2000/pi) * phi);
  return ton;
}


//==================================================
//                 MATLAB/SIMULINK
//==================================================

void serial_send6(float dato1, float dato2, float dato3,float dato4, float dato5, float dato6){
  /*
  Esta funcion envia 6 datos tipo float por puerto serie con el encabezado "abcd".
  Se utiliza en particular para enviar datos a matlab/simulink en tiempo real
  */
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
}


void serial_send7(float dato1, float dato2, float dato3,float dato4, float dato5, float dato6, float dato7){
  /*
  Idem que serial_send6 pero con 7 floats
  */
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
