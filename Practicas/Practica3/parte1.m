close all
clc

% Extraemos las mediciones de simulink
time = out.phi.time;
phi = out.phi.data(:);

[max_phi,argmax] = max(phi);

% Calculamos los paramteros del polinomio de la transferencia discreta
Y = phi(3:end);
X = [phi(2:end-1),phi(1:end-2)];
a = pinv(X)*Y;

% Trasnferencia discreta
Td = tf(1,[1 -a(1) -a(2)],time(2)-time(1));

% Polos discretos y continuos
pd = pole(Td);
pc = log(pd)/(time(2) - time(1));

% Armo la forma canonica del controlador de la planta
den = poly(pc); 
A = [0 1; -den(3) -den(2)];
B = [0;1];
C = [1 0];
D = 0;
sys = ss(A,B,C,D);

% Grafico las mediciones y la respuesta teorica a condiciones iniciales
figure(); hold on
plot(time(argmax:end)-time(argmax),phi(argmax:end),'r');
initial(sys,[max_phi;0],time(argmax:end)-time(argmax));
legend({'Mediciones','Respuesta teorica'})
