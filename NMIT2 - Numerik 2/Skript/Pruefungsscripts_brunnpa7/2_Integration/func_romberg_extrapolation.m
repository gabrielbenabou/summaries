% ====================================================================== %
% Funktion: Summierte Rechteckregel
%
% Beschreibung:
% Die Funktion die 
% 
% a: untere Intervallsgrenze
% b: obere Intervallsgrenze
% f: Funktion von dem das Maximum bestimmt werden soll
% 
% Beispielaufruf:  [T,E] = func_romberg_extrapolation(@(x) 1./x, 2, 4, 3)
% 
% maxFx: Maximaler Funktionswert der Funktion im Intervall f(a) bis f(b)
% xForMaxFx: x-Wert bei dem das Maximum maxFx erreicht wurde
% ====================================================================== %
function [T,E] = func_romberg_extrapolation(f, a, b, max)
    % Korrekte Loesung berechnen
    fIntCorrect = integral(f, a, b);

    % Vektoren initialisieren
    T = zeros(max+1);
    E = zeros(max+1);

    % Trapezregel definieren
    % T1f = @(n, h) func_summierte_trapezregel(f, a, b, n); 
    % T1f = @(n, h) func_summierte_rechteckregel(f, a, b, n); 
     T1f = @(n, h) func_simpsonregel(f, a, b, n); 

    % Startwerte berechnen
    for i = 1:(max+1)
        n = 2^(i-1);
        h = (b-a)/2^(i-1);
        T(i,1) = T1f(n,h);
        E(i,1) = abs(T(i,1)-fIntCorrect);
        fprintf('T%d0= %.4f\n',i-1, T1f(n,h));
        fprintf('E%d0= | T%d1 - fexakt | = | %.4f - %.4f | = %.4f\n',i-1,i-1, T(i,1), fIntCorrect, E(i,1));

    end

    % Restliche Werte berechnen
    for k = 2:(max+1)
        kReal = k-1;
        for i = 1:(max+1) - kReal
            T(i,k) = (4^kReal * T(i+1, k-1) - T(i, k-1)) / (4^kReal - 1);
            E(i,k) = abs(T(i,k)- fIntCorrect );
            fprintf('T%d%d= %.4f\n',i-1,k-1, T1f(n,h));
            fprintf('E%d%d= | T%d%d - fexakt | = | %.4f - %.4f | = %.4f\n',i-1,k-1,i-1,k-1, T(i,1), fIntCorrect, E(i,1));
        end
    end
end