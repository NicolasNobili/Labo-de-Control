#include "TimerOne.h"

#define PWMoutput 9
#define PWMperiod 10000


const int potPin = A0;

const int loop_period = 1000;

void setup()
{
  pinMode(PWMoutput, OUTPUT);
  Timer1.initialize(PWMperiod);              // initialize timer1, and set period in microseconds
  Timer1.pwm(PWMoutput, 0);                  // setup pwm, X duty cycle
  Timer1.attachInterrupt(timer_callback);    // attaches callback() as a timer overflow interrupt

  Serial.begin(115200);
}

void loop()
{

  // Marcar el inicio del ciclo
  unsigned long startTime = micros();

  // Leer el valor analógico del potenciómetro
  int potValue = analogRead(potPin);

  float Ton = map(potValue, 0, 1023, 500, 2500);
  float duty=map(Ton, 0, PWMperiod, 0, 1024); // duty=0 is output ALWAYS low, duty=1024 is output ALWAYS high. To produce PWM of X ms, calculate accordingly
  
  Timer1.pwm(PWMoutput,duty);
  ; //do not use delayMicroseconds with values higher than 16000

  unsigned long elapsedTime = (micros() - startTime)/1000;
  delay(loop_period - elapsedTime);
}


unsigned int leer_angulo_pote(int pin){
  // Se lee el valor de tension del potenciometro entre 0V y 5V
  int potValue = analogRead(pin);
  // Se tranforma la lectura en un angulo
  int angulo = map(potValue, 0, 1023, 0, 285);
  return angle
}

void timer_callback()
{
}