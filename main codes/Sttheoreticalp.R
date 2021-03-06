k = 3
d = 5
b = 14
n = 1000
n0 = 200
n1 = n-n0

y = matrix(rnorm(d*n),n,d)
y.dist = as.matrix(dist(y))
diag(y.dist) = max(y.dist)+100

An = matrix(0,n,k)
for (i in 1:n){
  An[i,] = (sort(y.dist[i,], index.return=T)$ix)[1:k]
}

temp = table(An)
id = as.numeric(row.names(temp))
deg = rep(0,n)
deg[id] = temp
cn = sum((deg-k)^2)/n/k
count = 0
for (i in 1:n){
  ids = An[i,]
  count = count + length(which(An[ids,]==i))
}
R2 = (cn + k)*n*k
cw = rep(0,n1-n0+1)
cdiff = rep(0,n1-n0+1)
part = rep(0,n1-n0+1)
for (t in n0:n1){
  cdiff[t-n0+1] = n/(2*t*(n - t))
}
for (t in n0:n1){
  cw[t-n0+1] = -((n - 1)*(2*t^2 - 2*n*t + n))/(2*t*(t - 1)*(n^2 - 2*n*t - n + t^2 + t))
} 
nu = function(x){
  2/x*(pnorm(x/2)-0.5)/((x/2)*pnorm(x/2)+dnorm(x/2))
}
for (t in n0:n1){
  
  temp = function(w)(cw[t-n0+1]*sin(w)^2+cdiff[t-n0+1]*cos(w)^2)*nu(sqrt(2*b*(cw[t-n0+1]*sin(w)^2+cdiff[t-n0+1]*cos(w)^2)))
  part[t-n0+1] = integrate(temp,0,2*pi)
  
}
p = b*exp(-b/2)/2/pi*sum(unlist(part))

