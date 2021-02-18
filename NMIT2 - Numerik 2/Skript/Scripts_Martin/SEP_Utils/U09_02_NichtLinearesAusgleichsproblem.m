% Datentabelle mit den Einflussgrössen für Lambda 1 -4 und 
% dem y-Wert in der letzten Spalte
data = [33.00 53.00 3.32 3.42 29.00
        31.00 36.00 3.10 3.26 24.00
        33.00 51.00 3.18 3.18 26.00
        37.00 51.00 3.39 3.08 22.00
        36.00 54.00 3.20 3.41 27.00
        35.00 35.00 3.03 3.03 21.00
        59.00 56.00 4.78 4.57 33.00
        60.00 60.00 4.72 4.72 34.00
        59.00 60.00 4.60 4.41 32.00
        60.00 60.00 4.53 4.53 34.00
        34.00 35.00 2.90 2.95 20.00
        60.00 59.00 4.40 4.36 36.00
        60.00 62.00 4.31 4.42 34.00
        60.00 36.00 4.27 3.94 23.00
        62.00 38.00 4.41 3.49 24.00
        62.00 61.00 4.39 4.39 32.00
        90.00 64.00 7.32 6.70 40.00
        90.00 60.00 7.32 7.20 46.00
        92.00 92.00 7.45 7.45 55.00
        91.00 92.00 7.27 7.26 52.00
        61.00 62.00 3.91 4.08 29.00
        59.00 42.00 3.75 3.45 22.00
        88.00 65.00 6.48 5.80 31.00
        91.00 89.00 6.70 6.60 45.00
        63.00 62.00 4.30 4.30 37.00
        60.00 61.00 4.02 4.10 37.00
        60.00 62.00 4.02 3.89 33.00
        59.00 62.00 3.98 4.02 27.00
        59.00 62.00 4.39 4.53 34.00
        37.00 35.00 2.75 2.64 19.00
        35.00 35.00 2.59 2.59 16.00
        37.00 37.00 2.73 2.59 22.00];

% Einflussgrössen von Lambda 1 - 4 in A eintragen 
A = data(:,1:4);

% Letze Einflussgrösse für Lambda 5 hinzufügen
A = [A ones(length(A),1)];

% Y aus den Daten extrahieren
y = data(:,5);

% x = Index der Elemente beginnend bei 1 
x = 1:length(A);

% Lambdas berechnen
lambda = (A'*A)\(A'*y);

% Polynom zusammensetzen
mch = @(A, lambda) lambda(1).*A(:,1) + lambda(2).*A(:,2) + ...
    lambda(3).*A(:,3)+lambda(4).*A(:,4) + lambda(5);

% Datenpunkte und ausgewertetes Polynom plotten
subplot(2,1,1);
plot(x,y,'o',x,mch(A, lambda));
legend('Datenpunkte','Ausgleichsfunktion');
xlabel('Zeiteinheit');
ylabel('mCH');


% Teilaufgabe B
max = 1000;
maxff = zeros(1,10);
minff = zeros(1,10);
for dmch=1:10
    minff(dmch) = realmax;
    for n = 1:max
        yGest = y + (y*dmch/100) .* sign(-0.5 + rand(size(y)));
        lambda = (A'*A)\(A'*yGest);
        EGest = norm(y-A*lambda,2)^2;
        if (EGest < minff(dmch))
           minff(dmch) = EGest;
        end
        if (EGest > maxff(dmch))
           maxff(dmch)= EGest; 
        end
    end
end

subplot(2,1,2);
plot(1:10, maxff, 1:10, minff);
legend('maximales Fehlerfunktional', 'minimales Fehlerfunktional');
xlabel('Fehlerkategorie');
ylabel('Fehlerfunktional');
