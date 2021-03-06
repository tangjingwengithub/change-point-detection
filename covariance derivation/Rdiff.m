syms k
syms t
syms n
syms s
syms count
syms R2
na = n*k+count;
nb = 3*n*k^2-2*n*k+R2-2*count;
nc = n^2*k^2-nb-na;

X1 = k*t*(t-1)/(n-1)
X2 = k*(n-t)*((n-t)-1)/(n-1)
varianceR1 = t/(n - 1)*(t - 1)*(count + k*n)/n +nb*t*(t-1)*(t-2)/n/(n-1)/(n-2) + nc*t*(t-1)*(t-2)*(t-3)/n/(n-1)/(n-2)/(n-3) - X1^2
varianceR2 = (n-t)/(n - 1)*((n-t) - 1)*(count + k*n)/n +nb*(n-t)*((n-t)-1)*((n-t)-2)/n/(n-1)/(n-2) + nc*(n-t)*((n-t)-1)*((n-t)-2)*((n-t)-3)/n/(n-1)/(n-2)/(n-3) - X2^2
ER1R2 = nc*t*(n-t)*(t-1)*(n-t-1)/n/(n-1)/(n-2)/(n-3);
covr1r2 = ER1R2 - X1*X2
a1 = 1
a2 = -1
b1 = 1
b2 = -1

ERdiff = a1*X1 + a2*X2
VRdiff = a1^2*varianceR1 + a2^2*varianceR2 + 2*a1*a2*covr1r2
simplify(VRdiff)



VRdifft = (t*(- n*k^2 + R2)*(n - t))/(n*(n - 1))
VRdiffs = (s*(- n*k^2 + R2)*(n - s))/(n*(n - 1))
pa1 = s*(s-1)/n/(n-1)
pb1 = s*(s-1)*(t-2)/n/(n-1)/(n-2)
pc1 = s*(s-1)*(t-2)*(t-3)/n/(n-1)/(n-2)/(n-3)
pa2 = (t-s)*(t-s-1)/n/(n-1)
pb2 = ((t-s)*(n-t)*(t-1) + (t-s)*(t-s-1)*(t-2))/n/(n-1)/(n-2)
pc2 = ((n-t)*(n-t-1)*t*(t-1) + 2*(t-s)*(n-t)*(t-1)*(t-2) + (t-s)*(t-s-1)*(t-2)*(t-3))/n/(n-1)/(n-2)/(n-3)
pa3 = 0
pb3 = 0
pc3 = (n-t)*(n-t-1)*s*(s-1)/n/(n-1)/(n-2)/(n-3)
pa4 = (n-t)*(n-t-1)/n/(n-1)
pb4 = (n-t)*(n-t-1)*(n-s-2)/n/(n-1)/(n-2)
pc4 = (n-t)*(n-t-1)*(n-s-2)*(n-s-3)/n/(n-1)/(n-2)/(n-3)
ER1t = X1
ER2t = X2
ER1s = k*s*(s-1)/(n-1)
ER2s = k*(n-s)*((n-s)-1)/(n-1)
cov1t1s = pa1*na+pb1*nb+pc1*nc-ER1t*ER1s
cov1t2s = pa2*na+pb2*nb+pc2*nc-ER1t*ER2s
cov2t1s = pa3*na+pb3*nb+pc3*nc-ER2t*ER1s
cov2t2s = pa4*na+pb4*nb+pc4*nc-ER2t*ER2s
covRdifftRdiffs = a1*b1*cov1t1s + a1*b2*cov1t2s + a2*b1*cov2t1s + a2*b2*cov2t2s
covRdifftRdiffs = simplify(covRdifftRdiffs)
covZdifftZdiffs = covRdifftRdiffs/(VRdifft^0.5)/(VRdiffs^0.5)
covZdifftZdiffs = simplify(covZdifftZdiffs)
der = diff(covZdifftZdiffs,'s')
f = @(s)der
ct = limit(f,s,t,'left')
ct = simplify(ct)

