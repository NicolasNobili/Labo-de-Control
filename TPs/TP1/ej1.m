close all
clear all
clc

% Config:
s = tf('s');

optionss=bodeoptions;
optionss.MagVisible='on';
optionss.PhaseMatching='on';
optionss.PhaseMatchingValue=-180;
optionss.PhaseMatchingFreq=1;
optionss.Grid='on';

%%
%{
+====================================================================
+====================================================================
+
+                           PARTE 1
+
+====================================================================
+====================================================================
%}

%Constantes:
G = 9.8;

a_max = 0.4;
h_max = 0.9;
b = 0.1;
d = 0.01065;
Q_i = 8e-3/60;

m = (a_max - b)/h_max;

%%
%{
+==========================================
+
+                Ejercicio c
+                (Simbolico)
+==========================================
%}

% Equilibrio
x_e = 0.45;
u_e = Q_i/(pi * d^2 * sqrt(2*G*x_e)/4);

orden = 1;
x=sym('x',[orden 1],'real');
u=sym('u','real');


% Funcion de estado
f = (Q_i - pi * d^2 * sqrt(2*G*x)*u/4 )/(m^2 * x^2 + 2*b*m*x + b^2);

% Funcion de salida
g = x;

% Linealizacion 
As = jacobian(f,x);
Bs = jacobian(f,u);
Cs = jacobian(g,x);
Ds = jacobian(g,u);


%{
+==========================================
+
+                Ejercicio c
+                (Numerico)
+==========================================
%}

An = -((2*b*m + 2*m^2 *x_e)*(Q_i - (pi*d^2*u_e*sqrt(G*x_e))/(2*sqrt(2))))/(b^2 + 2*b*m*x_e+m^2*x_e^2)^2 - (pi*d^2*G*u_e)/(4*sqrt(2*G*x_e*(b^2+2*b*m*x_e+m^2*x_e^2)));
Bn = - ((1/4)*(pi*d^2)*sqrt(2*G*x_e))/(b+m*x_e)^2;
Cn = 1;
Dn = 0;

%%
%{
+==========================================
+
+                Ejercicio d
+                (Simbolico)
+==========================================
%}

% Trasnferencia de la Planta Linealizada

A = double(subs(As,{x,u},{x_e,u_e}));
B = double(subs(Bs,{x,u},{x_e,u_e}));
C = double(subs(Cs,{x,u},{x_e,u_e}));
D = double(subs(Ds,{x,u},{x_e,u_e}));
Ps = tf(ss(A,B,C,D));

%{
+==========================================
+
+                Ejercicio d
+                (Simbolico)
+==========================================
%}

% Trasnferencia de la Planta Linealizada

Pn = Cn*Bn/(s-An);


%%
%{
+==========================================
+
+                Ejercicio e
+
+==========================================
%}
x_e_bode = (0.1:0.1:0.8);
u_e_bode = Q_i./(pi * d^2 * sqrt(2*G*x_e_bode)/4);

legends = {}; % Inicializa una celda para almacenar las leyendas

figure();hold on
for i=1:length(x_e_bode)
    A = double(subs(As,{x,u},{x_e_bode(i),u_e_bode(i)}));
    B = double(subs(Bs,{x,u},{x_e_bode(i),u_e_bode(i)}));
    C = double(subs(Cs,{x,u},{x_e_bode(i),u_e_bode(i)}));
    D = double(subs(Ds,{x,u},{x_e_bode(i),u_e_bode(i)}));
    P_bode = tf(ss(A,B,C,D));
    bodeplot(P_bode)
    
    legends{end+1} = ['x_e = ' num2str(x_e_bode(i))]; % Almacena la leyenda correspondiente
end
ax = findall(gcf,'type','axes');
legend(ax(2),legends);
legend(ax(3),legends);
%%

%{
+====================================================================
+====================================================================
+
+                           PARTE 2
+
+====================================================================
+====================================================================
%}


%{
+==========================================
+
+                Ejercicio a
+                (Simbolico)
+==========================================
%}
x_e = 0.45;
u_e = Q_i/(pi * d^2 * sqrt(2*G*x_e)/4);

A_sim = double(subs(As,{x,u},{x_e,u_e}));
B_sim = double(subs(Bs,{x,u},{x_e,u_e}));
C_sim = double(subs(Cs,{x,u},{x_e,u_e}));
D_sim = double(subs(Ds,{x,u},{x_e,u_e}));

%%
%{
+==========================================
+
+                Ejercicio b
+                
+==========================================
%}

P = Ps;
%figure(); hold on
%bode(P);

figure(); hold on
P_monio = -P/s;
margin(P_monio);

k= db2mag(-61.1);
C_monio = k;
margin(C_monio*P_monio);
