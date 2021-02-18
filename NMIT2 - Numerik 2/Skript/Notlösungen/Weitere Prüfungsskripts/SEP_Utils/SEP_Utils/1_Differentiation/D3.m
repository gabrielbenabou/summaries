function [d3] = D3(h, x0,y0, f)
% d3 = example
% Berechnet die Ableitung an der Stelle x0
% mittels Vorwärtsdifferenz
% Fehlerordnung O(h^2), k = 2
%
% x0: Stelle, an der die Ableitung berechnet wird
% y0: Stelle, dan der die Ableitung berechnet wird
% h : Schrittweite
% f : Funktion

format long;

d3 = ( (f(x0, y0) - f(x0 - h, y0))   /  h );
