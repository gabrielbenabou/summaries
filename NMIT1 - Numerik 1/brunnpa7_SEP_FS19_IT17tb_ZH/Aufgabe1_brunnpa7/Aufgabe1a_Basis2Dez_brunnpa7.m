% BASIS B in DEZIMAL
% 
% INPUT:
% var = Zahl als character String
% base = Basis als int -> B <= 10
%
% OUTPUT:
% decimalNumber = die berechnete Dezimalzahl
%
% BEISPIELAUFRUF:
% [decimalNumber] = Aufgabe1a_Basis2Dez_brunnpa7
function [decimalNumber] = Aufgabe1a_Basis2Dez_brunnpa7
format long;

var = '0.50103000000000000000000';
base = 6;
% Zuweisung der Nummer als String
charStr = char(var);
% �berpr�fung ob es sich um eine negative Zahl handelt
if(charStr(1) == '-')
    error('negative numbers not allowed');
end

% Split die eingebene Zahl beim Punkt
% man erh�lt ein Array mit zwei Elementen [Integer, Decimal]
splittedInput = split(var, ".");
% Berechnung der Arraygr�sse
sizeOfArray = size(splittedInput);
% Falls das Array mehr als 1 Element hat, hat es auch eine Dezimalzahl
if (sizeOfArray(1) > 1)
    % weise Integer zur 
    vorkommaStelle = splittedInput(1);
    vorkommaStelle = char(vorkommaStelle);
    nachkommaStelle = splittedInput(2);
    nachkommaStelle = char(nachkommaStelle);
else
    vorkommaStelle = var;
    vorkommaStelle = char(var);
end

int = 0;

if (base ~= 10)   
    % Berechnung Integerzahl
    for i = 1 : length(vorkommaStelle)
        int = int + str2num(vorkommaStelle(i)) * base^(length(vorkommaStelle) - i);
    end
    
    % Berechnung Dezimalzahl
    dec = 0;
    for i = 1: length(nachkommaStelle)
        dec = dec + str2num(nachkommaStelle(i)) * base^(i*(-1));
    end
    decimalNumber = int+dec;
else
    decimalNumber = var;
end
    
end

