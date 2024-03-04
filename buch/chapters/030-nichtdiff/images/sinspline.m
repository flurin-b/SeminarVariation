%
% sinspline.m -- spline interpolation für 
%
% (c) 2024 Prof Dr Andreas Müller
%
n = 10;
m = pi / 20;
x = (0:n)' * m
y = arrayfun(@sin,x)
A = 4 * eye(n+1) + circshift(eye(n+1),1) + circshift(eye(n+1),-1);
A(1,1) = 2;
A(n+1,n+1) = 2;
A(1,n+1) = 0;
A(n+1,1) = 0;
A
b = zeros(n+1,1);
b(2:n,1) = y(3:n+1,1) - y(1:n-1,1);
b(1,1) = y(2,1) - y(1,1);
b(n+1,1) = y(n+1,1) - y(n,1);
b = (3/m) * b

s = A\b

S = arrayfun(@cos, x);

fn = fopen("sintable.tex", "w");
fprintf(fn, "%%\n");
fprintf(fn, "%% sintable.tex -- table of spline interpolations parameters\n");
fprintf(fn, "%%\n");
fprintf(fn, "%% generated by sinspline.m, don't edit\n");
fprintf(fn, "%%\n");
fprintf(fn, "\\begin{tabular}{|>{$}r<{$}|>{$}r<{$}|>{$}r<{$}|>{$}r<{$}|>{$}r<{$}|>{$}r<{$}|}\n");
fprintf(fn, "\\hline\n");
fprintf(fn, "  k  ");
fprintf(fn, "&        x_k ");
fprintf(fn, "&          y_k ");
fprintf(fn, "&          s_k ");
fprintf(fn, "&      f'(x_k) ");
fprintf(fn, "& s_k-f'(x_k) \\\\\n");
fprintf(fn, "\\hline\n");
for i = (1:11)
	fprintf(fn, "%4d ", i-1);
	fprintf(fn, "& %10.4f ", x(i,1));
	fprintf(fn, "& %12.8f ", y(i,1));
	fprintf(fn, "& %12.8f ", s(i,1));
	fprintf(fn, "& %12.8f ", S(i,1));
	fprintf(fn, "& %12.8f ", s(i,1) - S(i,1));
	fprintf(fn, "\\\\\n");
end
fprintf(fn, "\\hline\n");
fprintf(fn, "\\end{tabular}\n");
fclose(fn);

function retval = H0(x)
	retval = (2*x-3)*x*x+1;
end

function retval = H1(x)
	retval = (-2*x+3)*x*x;
end

function retval = H01(x)
	retval = ((x-2)*x+1)*x;
end

function retval = H11(x)
	retval = (x-1)*x*x;
end

%
% x	Stützstellen
% y	Werte an den Stützstellen
% s	Steigungen an den Stützstellen
% t	Wert
%
function retval = Y(x, y, s, t)
	m = x(2,1) - x(1,1);
	X = (t - x(1,1)) / m;
	retval = y(1,1) * H0(X) + y(2,1) * H1(X) + (s(1,1) * H01(X) + s(2,1) * H11(X)) * m;
end

fehler = zeros(181,1);
hfehler = zeros(181,1);

fn = fopen("sinpath.tex", "w");

% spline schreiben
fprintf(fn, "\\def\\spline{\n");
fprintf(fn, "\t(0,0)");
for t = (1:179)
	k = floor(t / 18) + 1;
	X = (pi / 2) * (t / 180)
	wert = Y(x(k:k+1,1), y(k:k+1,1), s(k:k+1,1), X);
	fprintf(fn, "\n\t-- (%.4f,%.4f)", 6 * X, 6 * wert);
	fehler(t+1,1) = sin(X) - wert;
end
fprintf(fn, "\n\t--(%.4f,6)", 3*pi);
fprintf(fn, "\n}\n");

% hermite interpolation schreiben
fprintf(fn, "\\def\\hermite{\n");
fprintf(fn, "\t(0,0)");
for t = (1:179)
	k = floor(t / 18) + 1;
	X = (pi / 2) * (t / 180)
	wert = Y(x(k:k+1,1), y(k:k+1,1), S(k:k+1,1), X);
	fprintf(fn, "\n\t-- (%.4f,%.4f)", 6 * X, 6 * wert);
	hfehler(t+1,1) = sin(X) - wert;
end
fprintf(fn, "\n\t--(%.4f,6)", 3*pi);
fprintf(fn, "\n}\n");

fehler

% Fehlerspline schreiben
scale = 1000;
fprintf(fn, "\\def\\fehlerspline{\n");
fprintf(fn, "\t(0,0)");
for k = (2:180)
	fprintf(fn, "\n\t-- (%4f,%4f)", 6 * (pi/2) * (k-1)/180, 6 * scale * fehler(k, 1));
end
fprintf(fn, "\n\t-- (%.4f,0)", 3 * pi);
fprintf(fn, "\n}\n");

scale = 100000;

fprintf(fn, "\\def\\fehlerhermite{\n");
fprintf(fn, "\t(0,0)");
for k = (2:180)
	fprintf(fn, "\n\t-- (%4f,%4f)", 6 * (pi/2) * (k-1)/180, 6 * scale * hfehler(k, 1));
end
fprintf(fn, "\n\t-- (%.4f,0)", 3 * pi);
fprintf(fn, "\n}\n");

fclose(fn);
