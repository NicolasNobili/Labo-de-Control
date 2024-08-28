#include "TimerOne.h"

#define PWMoutput 9
#define PWMperiod 10000


const int potPin = A0;

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
  // Leer el valor analógico del potenciómetro
  int potValue = analogRead(potPin);

  float Ton = map(potValue, 0, 1023, 500, 2500);
  float duty=map(Ton, 0, PWMperiod, 0, 1024); // duty=0 is output ALWAYS low, duty=1024 is output ALWAYS high. To produce PWM of X ms, calculate accordingly
  Timer1.pwm(PWMoutput,duty);
  
  delay(1000); //do not use delayMicroseconds with values higher than 16000
}

void timer_callback()
{
}