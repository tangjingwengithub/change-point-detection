gcp_tests = function(A,k=1){
  # n = dim(distM)[1]	
  # A = matrix(0,n,k)
  # for (i in 1:n){
  #   A[i,] = (sort(distM[i,1:n], index.return=T)$ix)[1:k]
  # }
  temp = table(A)
  id = as.numeric(row.names(temp))
  deg = rep(0,n)
  deg[id] = temp
  deg.sumsq = sum(deg^2)
  cn = sum((deg-k)^2)/n/k
  
  count = 0
  for (i in 1:n){
    ids = A[i,]
    count = count + length(which(A[ids,]==i))
  }
  vn = count/n/k
  
  ts = 1:(n-1)
  
  EX = 4*k*ts*(n-ts)/(n-1)
  h = 4*(ts-1)*(n-ts-1)/((n-2)*(n-3))
  VX = EX*(h*(1+vn-2*k/(n-1))+(1-h)*cn)
  
  q = (n-ts-1)/(n-2)
  p = (ts-1)/(n-2)
  EX1L = 2*k*(ts)*(ts-1)/(n-1)
  EX2L = 2*k*(n-ts)*(n-ts-1)/(n-1)
  
  config1 = (2*k*n + 2*k*n*vn)
  config2 = (3*k^2*n + deg.sumsq -2*k*n -2*k*n*vn)
  config3 = (4*n^2*k^2 + 4*k*n + 4*k*n*vn - 12*k^2*n - 4*deg.sumsq)
  
  f11 = 2*(ts)*(ts-1)/n/(n-1)
  f21 = 4*(ts)*(ts-1)*(ts-2)/n/(n-1)/(n-2)
  f31 = (ts)*(ts-1)*(ts-2)*(ts-3)/n/(n-1)/(n-2)/(n-3)
  
  f12 = 2*(n-ts)*(n-ts-1)/n/(n-1)
  f22 = 4*(n-ts)*(n-ts-1)*(n-ts-2)/n/(n-1)/(n-2)
  f32 = (n-ts)*(n-ts-1)*(n-ts-2)*(n-ts-3)/n/(n-1)/(n-2)/(n-3)
  
  var1 = config1*f11 + config2*f21 + config3*f31 - EX1L^2
  var2 = config1*f12 + config2*f22 + config3*f32 - EX2L^2
  v12 = config3*((ts)*(ts-1)*(n-ts)*(n-ts-1))/(n*(n-1)*(n-2)*(n-3)) - EX1L*EX2L
  
  X = X1 = X2 = rep(0,n-1)
  for (t in 1:(n-1)){
    X2[t] = (length(which(A[(t+1):n,]>t)))
    X1[t] = (length(which(A[1:t,]<=t)))
    X[t] = (length(which(A[1:t,]>t))+length(which(A[(t+1):n,]<=t)))
  }
  
  Rw = q*X1 + p*X2
  ERw = (q*EX1L + p*EX2L)/2
  varRw = (q^2*var1 + p^2*var2 + 2*p*q*v12)/4
  Zw = (Rw - ERw)/sqrt(varRw)
  
  varRdiff = (var1+var2-2*v12)/4
  Zdiff = ((X1-X2)-(EX1L-EX2L)/2)/sqrt(varRdiff)
  
  S = Zw^2 + Zdiff^2
  M = max(abs(Zdiff),Zw)
  
  Z= (EX/2-X)/sqrt(VX/4)
  
  list(R0 = X, R1= X1, R2 = X2, Rw = Rw, Z1 = (X1-EX1L)/sqrt(var1) , Z2 = (X2-EX2L)/sqrt(var2),Z = Z, Zdiff = Zdiff, Zw = Zw, S = S, M =M )
}

pk = function(distM,k){
  n=dim(distM)[1]
  A = matrix(0,n,k)
  for (i in 1:n){
    A[i,] = (sort(distM[i,1:n], index.return=T)$ix)[1:k]
  }
  temp = table(A)
  id = as.numeric(row.names(temp))
  
  count = 0
  for (i in 1:n){
    ids = A[i,]
    count = count + length(which(A[ids,]==i))
  }
  
  return(count/n)
}

qk = function(distM,k){
  n=dim(distM)[1]
  A = matrix(0,n,k)
  for (i in 1:n){
    A[i,] = (sort(distM[i,1:n], index.return=T)$ix)[1:k]
  }
  temp = table(A)
  id = as.numeric(row.names(temp))
  
  deg = rep(0,n)
  deg[id] = temp
  deg.sumsq = sum(deg^2)
  
  return(deg.sumsq/n-k)
}

cov_R = function(n,s,t,k,psum = pk(distM,k),qsum = qk(distM,k)){
  X1 = k*n + n*psum
  X2 = 3*k^2*n + n*(qsum +k)
  X3 = n^2*k^2
  
  config1 = X1
  config2 = X2 - 2*X1
  config3 = X3 - X2 + X1
  
  f1 = 2*s*(n-t)/n/(n-1)
  f2 = s*(n-t)*(n-2*s+2*t-2)/n/(n-1)/(n-2)
  f3 = 4*s*(n-t)*((s-1)*(n-s-1)+(t-s)*(n-s-2))/n/(n-1)/(n-2)/(n-3)
  
  return(f1*config1 + f2*config2 + f3*config3 - 4*k^2*t*(n-t)*s*(n-s)/(n-1)^2)
}

cov_Rw = function(n,s,t,k,psum = pk(distM,k),qsum=qk(distM,k)){
  X1 = k*n + n*psum
  X2 = 3*k^2*n + n*(qsum +k)
  X3 = n^2*k^2
  
  config1 = X1
  config2 = X2 - 2*X1
  config3 = X3 - X2 + X1
  
  f1a = s*(s-1)/n/(n-1)
  f2a = s*(s-1)*(t-2)/n/(n-1)/(n-2)
  f3a = s*(s-1)*(t-2)*(t-3)/n/(n-1)/(n-2)/(n-3)
  
  f3b = s*(s-1)*(n-t)*(n-t-1)/n/(n-1)/(n-2)/(n-3)
  
  f1c = (t-s)*(t-s-1)/n/(n-1)
  f2c = (t-s)*((t-s-1)*(t-2)+(n-t)*(t-1))/n/(n-1)/(n-2)
  f3c = ((t-s)*(t-s-1)*(n-s-2)*(n-s-3)+2*s*(t-s)*(n-s-1)*(n-s-2)+s*(s-1)*(n-s)*(n-s-1))/n/(n-1)/(n-2)/(n-3)
  
  f1d = (n-t)*(n-t-1)/n/(n-1)
  f2d = (n-t)*(n-t-1)*(n-s-2)/n/(n-1)/(n-2)
  f3d = (n-t)*(n-t-1)*(n-s-2)*(n-s-3)/n/(n-1)/(n-2)/(n-3)
  
  EX1 = k*(t)*(t-1)/(n-1)
  EX2 = k*(n-t)*(n-t-1)/(n-1)
  
  EX1s = k*(s)*(s-1)/(n-1)
  EX2s = k*(n-s)*(n-s-1)/(n-1)
  
  ERwt = (n-t-1)/(n-2)*EX1 + (t-1)/(n-2)*EX2
  ERws = (n-s-1)/(n-2)*EX1s + (s-1)/(n-2)*EX2s
  
  qt = (n-t-1)/(n-2)
  pt = 1- qt
  
  qs = (n-s-1)/(n-2)
  ps = 1 - qs
  
  ER1R1 = config1*f1a + config2*f2a + config3*f3a
  ER1R2 = config3*f3b
  ER2R1 = config1*f1c + config2*f2c + config3*f3c
  ER2R2 = config1*f1d + config2*f2d + config3*f3d
  
  return(qs*qt*ER1R1 + qs*pt*ER1R2 + ps*qt*ER2R1 + ps*pt*ER2R2 - ERwt*ERws) 
}

cov_Rd = function(n,s,t,k,psum=pk(distM,k),qsum=qk(distM,k)){
  X1 = k*n + n*psum
  X2 = 3*k^2*n + n*(qsum +k)
  X3 = n^2*k^2
  
  config1 = X1
  config2 = X2 - 2*X1
  config3 = X3 - X2 + X1
  
  f1a = s*(s-1)/n/(n-1)
  f2a = s*(s-1)*(t-2)/n/(n-1)/(n-2)
  f3a = s*(s-1)*(t-2)*(t-3)/n/(n-1)/(n-2)/(n-3)
  
  f3b = s*(s-1)*(n-t)*(n-t-1)/n/(n-1)/(n-2)/(n-3)
  
  f1c = (t-s)*(t-s-1)/n/(n-1)
  f2c = (t-s)*((t-s-1)*(t-2)+(n-t)*(t-1))/n/(n-1)/(n-2)
  f3c = ((t-s)*(t-s-1)*(n-s-2)*(n-s-3)+2*s*(t-s)*(n-s-1)*(n-s-2)+s*(s-1)*(n-s)*(n-s-1))/n/(n-1)/(n-2)/(n-3)
  
  f1d = (n-t)*(n-t-1)/n/(n-1)
  f2d = (n-t)*(n-t-1)*(n-s-2)/n/(n-1)/(n-2)
  f3d = (n-t)*(n-t-1)*(n-s-2)*(n-s-3)/n/(n-1)/(n-2)/(n-3)
  
  EX1 = k*(t)*(t-1)/(n-1)
  EX2 = k*(n-t)*(n-t-1)/(n-1)
  
  EX1s = k*(s)*(s-1)/(n-1)
  EX2s = k*(n-s)*(n-s-1)/(n-1)
  
  ERdt = EX1 - EX2
  ERds = EX1s - EX2s
  
  
  ER1R1 = config1*f1a + config2*f2a + config3*f3a
  ER1R2 = config3*f3b
  ER2R1 = config1*f1c + config2*f2c + config3*f3c
  ER2R2 = config1*f1d + config2*f2d + config3*f3d
  
  return(ER1R1 - ER1R2 - ER2R1 + ER2R2 - ERdt*ERds) 
  
}

#### analytical p-value

rho_one = function(n,t, psum = pk(y.dist,k),qsum=qk(y.dist,k)){ # rho_one = n h_G
  -((n - 1)*(6*k*n + 4*n*psum + 2*n*qsum - 5*k*n^2 + 6*k^2*n + k*n^3 - 4*n^2*psum + 12*k*t^2 - n^2*qsum + n^3*qsum + 8*psum*t^2 + 4*qsum*t^2 + k^2*n^2 - k^2*n^3 + 12*k^2*t^2 - 4*k*n*t^2 + 4*k*n^2*t - 12*k^2*n*t - 8*n*psum*t^2 + 8*n^2*psum*t + 4*n*qsum*t^2 - 4*n^2*qsum*t - 4*k^2*n*t^2 + 4*k^2*n^2*t - 12*k*n*t - 8*n*psum*t - 4*n*qsum*t))/(2*t*(n - t)*(6*k + 4*psum + 2*qsum - 11*k*n - 8*n*psum - 3*n*qsum + 6*k*n^2 - 5*k^2*n - k*n^3 + 4*n^2*psum + 2*n^2*qsum - n^3*qsum - 4*psum*t^2 + 4*qsum*t^2 + 6*k^2 - 2*k^2*n^2 + k^2*n^3 - 12*k^2*t^2 + 12*k^2*n*t + 4*n*psum*t^2 - 4*n^2*psum*t - 4*n*qsum*t^2 + 4*n^2*qsum*t + 4*k^2*n*t^2 - 4*k^2*n^2*t + 4*n*psum*t - 4*n*qsum*t))
}

rho_one_Rw = function(n,t, psum = pk(y.dist,k),qsum=qk(y.dist,k)){ # rho_one = n h_G
  -(t*(t - 1)*(2*t^2 - 2*n*t + n)*(n^2 - 2*n*t - n + t^2 + t)*(3*k + 2*psum + qsum - 4*k*n - 3*n*psum - n*qsum + k*n^2 - k^2*n + n^2*psum + 3*k^2)^2)/((n - 1)^3*(n - 2)^4*(n - 3)^2*((t^2*(t - 1)^2*(n^2 - 2*n*t - n + t^2 + t)^2*(3*k + 2*psum + qsum - 4*k*n - 3*n*psum - n*qsum + k*n^2 - k^2*n + n^2*psum + 3*k^2)^2)/((n - 3)^2*(n^2 - 3*n + 2)^4))*2)
}

rho_one_Rd = function(n,t){
  n/(2*t*(n - t))
}

Nu = function(x){ # the Nu function
  y = x/2
  (1/y)*(pnorm(y)-0.5)/(y*pnorm(y) + dnorm(y))
}

## without skewness correction
pvalgb_R = function(n, b,psum = pk(y.dist,k),qsum=qk(y.dist,k),lower=0.1*n, upper=0.9*n){
  integrand = function(s){
    x = rho_one(n,s,psum,qsum)
    x*Nu(sqrt(2*b^2*x))
  }
  dnorm(b)*b*integrate(integrand, lower, upper, subdivisions=3000, stop.on.error=FALSE)$value
}

pvalgb_Rw = function(n, b, psum = pk(y.dist,k),qsum=qk(y.dist,k),lower, upper){
  integrand = function(t){
    x = rho_one_Rw(n,t,psum = pk(y.dist,k),qsum=qk(y.dist,k))
    x*Nu(sqrt(2*b^2*x))
  }
  dnorm(b)*b*integrate(integrand, lower, upper, subdivisions=3000, stop.on.error=FALSE)$value
}

pvalgb_Rd= function(n,k, b, lower, upper){
  integrand1 = function(t){
    x1 = rho_one_Rd(n,t)
    x1*Nu(sqrt(2*b^2*x1))
  }
  2*dnorm(b)*b*integrate(integrand1, lower, upper, subdivisions=3000, stop.on.error=FALSE)$value
}
EX3.f = function(n, t, k, y.dist){
  An = matrix(0,n,k)
  for (i in 1:n){
    An[i,] = (sort(y.dist[i,1:n], index.return=T)$ix)[1:k]
  }
  temp = table(An)
  id = as.numeric(row.names(temp))
  deg = rep(0,n)
  deg[id] = temp
  deg.sumsq = sum(deg^2)
  deg.sum3 = sum(deg^3)
  count = daa = dda = aaa1 = aaa2 = 0
  for (i in 1:n){
    ids = An[i,]
    count = count + length(which(An[ids,]==i))
    daa = daa + deg[i]*length(which(An[ids,]==i))
    dda = dda + deg[i]*sum(deg[ids])
    for (j in ids){
      u = An[j,]
      aaa1 = aaa1 + length(which(An[u,]==i))
      aaa2 = aaa2 + length(which(!is.na(match(ids,u))))
    }
  }
  psum = count/n
  qsum = deg.sumsq/n-k
  vn = count/n/k
  psumk = psum
  qsumk = qsum
  if (k>1){
    count1 = count2 = 0
    for (i in 1:n){
      ids = An[i,k]
      count1 = count1 + length(which(An[ids,]==i))
      count2 = count2 + length(which(An[-i,]==ids))
    }
    psumk = count1/n
    qsumk = count2/n
    vn = count/n/k
  }
  x1 = 2*k*n+6*k*n*vn
  x2 = 3*k^2*n+deg.sumsq+2*k^2*n*vn+2*daa-x1
  x3 = 4*k^2*n^2*(1+vn)-4*(3*k^2*n+deg.sumsq+2*k^2*n*vn+2*daa)+2*(2*k*n+6*k*n*vn)
  x4 = 4*k^3*n+3*k*deg.sumsq+deg.sum3-3*(3*k^2*n+deg.sumsq+2*k^2*n*vn+2*daa)+2*(2*k*n+6*k*n*vn)
  x5 = 4*k^3*n+2*k*deg.sumsq+2*dda-2*(3*k^2*n+deg.sumsq+2*k^2*n*vn+2*daa)+x1-2*aaa1-6*aaa2
  x6 = 2*aaa1+6*aaa2
  x7 = 2*k*n*(3*k^2*n+deg.sumsq)-4*k^2*n^2*(1+vn) - 4*(4*k^3*n+2*k*deg.sumsq+2*dda-(3*k^2*n+deg.sumsq+2*k^2*n*vn+2*daa))-2*(4*k^3*n+3*k*deg.sumsq+deg.sum3-(3*k^2*n+deg.sumsq+2*k^2*n*vn+2*daa))+ 4*((3*k^2*n+deg.sumsq+2*k^2*n*vn+2*daa)-(2*k*n+6*k*n*vn))+2*x6
  x8 = 8*k^3*n^3-4*x1-24*x2-6*x3-8*x4-24*x5-8*x6-12*x7
  p1 = 2*t*(n-t)/n/(n-1)
  p2 = p1/2
  p3 = 4*t*(t-1)*(n-t)*(n-t-1)/(n*(n-1)*(n-2)*(n-3))
  p4 = t*(n-t)*((n-t-1)*(n-t-2)+(t-1)*(t-2))/(n*(n-1)*(n-2)*(n-3))
  p5 = p7 = p3/2
  p8 = 8*t*(t-1)*(t-2)*(n-t)*(n-t-1)*(n-t-2)/(n*(n-1)*(n-2)*(n-3)*(n-4)*(n-5))
  EX3 = 4*x1*p1 + 24*x2*p2 + 6*x3*p3 + 8*x4*p4 + 24*x5*p5 + 12*x7*p7 + x8*p8
  return(EX3/8)
}

EX3_new.f = function(n, t, k, y.dist){
  An = matrix(0,n,k)
  for (i in 1:n){
    An[i,] = (sort(y.dist[i,1:n], index.return=T)$ix)[1:k]
  }
  temp = table(An)
  id = as.numeric(row.names(temp))
  deg = rep(0,n)
  deg[id] = temp
  deg.sumsq = sum(deg^2)
  deg.sum3 = sum(deg^3)
  count = daa = dda = aaa1 = aaa2 = 0
  for (i in 1:n){
    ids = An[i,]
    count = count + length(which(An[ids,]==i))
    daa = daa + deg[i]*length(which(An[ids,]==i))
    dda = dda + deg[i]*sum(deg[ids])
    for (j in ids){
      u = An[j,]
      aaa1 = aaa1 + length(which(An[u,]==i))
      aaa2 = aaa2 + length(which(!is.na(match(ids,u))))
    }
  }
  psum = count/n
  qsum = deg.sumsq/n-k
  
  psumk = psum
  qsumk = qsum
  if (k>1){
    count1 = count2 = 0
    for (i in 1:n){
      ids = An[i,k]
      count1 = count1 + length(which(An[ids,]==i))
      count2 = count2 + length(which(An[-i,]==ids))
    }
    psumk = count1/n
    qsumk = count2/n
  }
  
  x1 = 2*k*n+6*k*n*psum/k
  x2 = 3*k^2*n+deg.sumsq+2*k*n*psum+2*daa-x1
  x3 = 4*k^2*n^2*(1+psum/k)-4*(3*k^2*n+deg.sumsq+2*k^2*n*psum/k+2*daa)+2*(2*k*n+6*k*n*psum/k)
  x4 = 4*k^3*n+3*k*deg.sumsq+deg.sum3-3*(3*k^2*n+deg.sumsq+2*k^2*n*psum/k+2*daa)+2*(2*k*n+6*k*n*psum/k)
  x5 = 4*k^3*n+2*k*deg.sumsq+2*dda-2*(3*k^2*n+deg.sumsq+2*k^2*n*psum/k+2*daa)+x1-2*aaa1-6*aaa2
  x6 = 2*aaa1+6*aaa2
  x7 = 2*k*n*(3*k^2*n+deg.sumsq)-4*k^2*n^2*(1+psum/k) - 4*(4*k^3*n+2*k*deg.sumsq+2*dda-(3*k^2*n+deg.sumsq+2*k^2*n*psum/k+2*daa))-2*(4*k^3*n+3*k*deg.sumsq+deg.sum3-(3*k^2*n+deg.sumsq+2*k^2*n*psum/k+2*daa))+ 4*((3*k^2*n+deg.sumsq+2*k^2*n*psum/k+2*daa)-(2*k*n+6*k*n*psum/k))+2*x6
  x8 = 8*k^3*n^3-4*x1-24*x2-6*x3-8*x4-24*x5-8*x6-12*x7
  p1 = t*(t-1)/n/(n-1)
  p2 = t*(t-1)*(t-2)/n/(n-1)/(n-2)
  p3 = t*(t-1)*(t-2)*(t-3)/(n*(n-1)*(n-2)*(n-3))
  p4 = p5 = t*(t-1)*(t-2)*(t-3)/(n*(n-1)*(n-2)*(n-3))
  p6 = p2
  p7 = t*(t-1)*(t-2)*(t-3)*(t-4)/(n*(n-1)*(n-2)*(n-3)*(n-4))
  p8 = t*(t-1)*(t-2)*(t-3)*(t-4)*(t-5)/(n*(n-1)*(n-2)*(n-3)*(n-4)*(n-5))
  
  q1 = (n-t)*(n-t-1)/n/(n-1)
  q2 = (n-t)*(n-t-1)*(n-t-2)/n/(n-1)/(n-2)
  q3 = (n-t)*(n-t-1)*(n-t-2)*(n-t-3)/(n*(n-1)*(n-2)*(n-3))
  q4 = q5 = q3
  q6 = q2
  q7 = (n-t)*(n-t-1)*(n-t-2)*(n-t-3)*(n-t-4)/(n*(n-1)*(n-2)*(n-3)*(n-4))
  q8 = (n-t)*(n-t-1)*(n-t-2)*(n-t-3)*(n-t-4)*(n-t-5)/(n*(n-1)*(n-2)*(n-3)*(n-4)*(n-5))
  
  A11 = 4*x1*p1 + 24*x2*p2 + 6*x3*p3 + 8*x4*p4 + 24*x5*p5 + 8*x6*p6 + 12*x7*p7 + x8*p8
  A12 = 2*x3*t*(t-1)*(n-t)*(n-t-1)/(n*(n-1)*(n-2)*(n-3)) + 4*x7*t*(t-1)*(t-2)*(n-t)*(n-t-1)/(n*(n-1)*(n-2)*(n-3)*(n-4)) + x8*t*(t-1)*(t-2)*(t-3)*(n-t)*(n-t-1)/(n*(n-1)*(n-2)*(n-3)*(n-4)*(n-5))
  A21 = 2*x3*t*(t-1)*(n-t)*(n-t-1)/(n*(n-1)*(n-2)*(n-3)) + 4*x7*(n-t)*(n-t-1)*(n-t-2)*(t)*(t-1)/(n*(n-1)*(n-2)*(n-3)*(n-4)) + x8*(n-t)*(n-t-1)*(n-t-2)*(n-t-3)*(t)*(t-1)/(n*(n-1)*(n-2)*(n-3)*(n-4)*(n-5))
  A22 = 4*x1*q1 + 24*x2*q2 + 6*x3*q3 + 8*x4*q4 + 24*x5*q5 + 8*x6*q6 + 12*x7*q7 + x8*q8
  
  q = (n-t-1)/(n-2)
  p = (t-1)/(n-2)
  ERw3 = q^3*A11 + 3*q^2*p*A12 + 3*q*p^2*A21 + p^3*A22
  ERd3 =  A11 - 3*A12 + 3*A21 - A22
  list(ERw3=ERw3/8, ERd3=ERd3/8)
}

pvalgb_R_skew= function(n,k, b, y.dist, lower, upper, subdivisions=3000, bmin=1){
  t = 1:(n-1)
  x = rho_one(n,t,psum = pk(y.dist,k),qsum=qk(y.dist,k))
  
  An = matrix(0,n,k)
  for (i in 1:n){
    An[i,] = (sort(y.dist[i,1:n], index.return=T)$ix)[1:k]
  }
  temp = table(An)
  id = as.numeric(row.names(temp))
  deg = rep(0,n)
  deg[id] = temp
  deg.sumsq = sum(deg^2)
  deg.sum3 = sum(deg^3)
  count = daa = dda = aaa1 = aaa2 = 0
  for (i in 1:n){
    ids = An[i,]
    count = count + length(which(An[ids,]==i))
    daa = daa + deg[i]*length(which(An[ids,]==i))
    dda = dda + deg[i]*sum(deg[ids])
    for (j in ids){
      u = An[j,]
      aaa1 = aaa1 + length(which(An[u,]==i))
      aaa2 = aaa2 + length(which(!is.na(match(ids,u))))
    }
  }
  psum = count/n
  qsum = deg.sumsq/n-k
  
  psumk = psum
  qsumk = qsum
  if (k>1){
    count1 = count2 = 0
    for (i in 1:n){
      ids = An[i,k]
      count1 = count1 + length(which(An[ids,]==i))
      count2 = count2 + length(which(An[-i,]==ids))
    }
    psumk = count1/n
    qsumk = count2/n
  }
  
  vn = psum/k
  
  x1 = 2*k*n+6*k*n*vn
  x2 = 3*k^2*n+deg.sumsq+2*k^2*n*vn+2*daa-x1
  x3 = 4*k^2*n^2*(1+vn)-4*(3*k^2*n+deg.sumsq+2*k^2*n*vn+2*daa)+2*(2*k*n+6*k*n*vn)
  x4 = 4*k^3*n+3*k*deg.sumsq+deg.sum3-3*(3*k^2*n+deg.sumsq+2*k^2*n*vn+2*daa)+2*(2*k*n+6*k*n*vn)
  x5 = 4*k^3*n+2*k*deg.sumsq+2*dda-2*(3*k^2*n+deg.sumsq+2*k^2*n*vn+2*daa)+x1-2*aaa1-6*aaa2
  x6 = 2*aaa1+6*aaa2
  x7 = 2*k*n*(3*k^2*n+deg.sumsq)-4*k^2*n^2*(1+vn) - 4*(4*k^3*n+2*k*deg.sumsq+2*dda-(3*k^2*n+deg.sumsq+2*k^2*n*vn+2*daa))-2*(4*k^3*n+3*k*deg.sumsq+deg.sum3-(3*k^2*n+deg.sumsq+2*k^2*n*vn+2*daa))+ 4*((3*k^2*n+deg.sumsq+2*k^2*n*vn+2*daa)-(2*k*n+6*k*n*vn))+2*x6
  x8 = 8*k^3*n^3-4*x1-24*x2-6*x3-8*x4-24*x5-8*x6-12*x7
  p1 = 2*t*(n-t)/n/(n-1)
  p2 = p1/2
  p3 = 4*t*(t-1)*(n-t)*(n-t-1)/(n*(n-1)*(n-2)*(n-3))
  p4 = t*(n-t)*((n-t-1)*(n-t-2)+(t-1)*(t-2))/(n*(n-1)*(n-2)*(n-3))
  p5 = p7 = p3/2
  p8 = 8*t*(t-1)*(t-2)*(n-t)*(n-t-1)*(n-t-2)/(n*(n-1)*(n-2)*(n-3)*(n-4)*(n-5))
  ER3 = (4*x1*p1 + 24*x2*p2 + 6*x3*p3 + 8*x4*p4 + 24*x5*p5 + 12*x7*p7 + x8*p8)/8
  
  mu = (2*k*t*(n - t))/(n - 1)
  sig1 = (2*t*(n - t)*(k*n + n*psum))/(n*(n - 1)) - (4*k^2*t^2*(n - t)^2)/(n - 1)^2 + (t*(n - t)*(n*(k + qsum) - 2*k*n - 2*n*psum + 3*k^2*n))/(n*(n - 1)) - (4*t*(n - t)*(t - 1)*(t - n + 1)*(k*n - n*(k + qsum) + n*psum - 3*k^2*n + k^2*n^2))/(n*(n - 1)*(n - 2)*(n - 3))
  sig = sqrt(apply(cbind(sig1, rep(0,n-1)), 1, max))  # sigma
  
  r = (mu^3 + 3*mu*sig^2 - ER3)/sig^3
  
  theta_b = rep(0,n-1)
  pos = which(1+2*r*b>0)
  theta_b[pos] = (sqrt((1+2*r*b)[pos])-1)/r[pos]
  ratio = exp((b-theta_b)^2/2 + r*theta_b^3/6)/sqrt(1+r*theta_b)
  a = x*Nu(sqrt(2*b^2*x)) * ratio[1:(n-1)]
  nn = n-length(pos)
  if (nn>0.75*n){
    return(0)
  }
  if (nn>=2*(lower-1)){
    neg = which(1+2*r*b<=0)
    dif = neg[2:nn]-neg[1:(nn-1)]
    id1 = which.max(dif)
    id2 = id1 + ceiling(0.03*n)
    id3 = id2 + ceiling(0.09*n)
    inc = (a[id3]-a[id2])/ceiling(0.06*n)
    a[id2:1] = a[id2+1]-inc*(1:id2)
    a[(n/2+1):n] = a[(n/2):1]
    neg2 = which(a<0)
    a[neg2] = 0
  }
  integrand = function(s){
    a[s]
  }
  result = try(dnorm(b)*b*integrate(integrand, lower, upper, subdivisions=3000, stop.on.error=FALSE)$value, silent=T)
  if (is.numeric(result)){
    return(result)
  }else{
    return(2)
  }
}

pvalgb_Rw_skew = function(n,k, b, y.dist, lower, upper, subdivisions=3000, bmin=1){
  t = 1:(n-1)
  x = rho_one_Rw(n,t,psum = pk(y.dist,k),qsum=qk(y.dist,k))
  
  An = matrix(0,n,k)
  for (i in 1:n){
    An[i,] = (sort(y.dist[i,1:n], index.return=T)$ix)[1:k]
  }
  temp = table(An)
  id = as.numeric(row.names(temp))
  deg = rep(0,n)
  deg[id] = temp
  deg.sumsq = sum(deg^2)
  deg.sum3 = sum(deg^3)
  count = daa = dda = aaa1 = aaa2 = 0
  for (i in 1:n){
    ids = An[i,]
    count = count + length(which(An[ids,]==i))
    daa = daa + deg[i]*length(which(An[ids,]==i))
    dda = dda + deg[i]*sum(deg[ids])
    for (j in ids){
      u = An[j,]
      aaa1 = aaa1 + length(which(An[u,]==i))
      aaa2 = aaa2 + length(which(!is.na(match(ids,u))))
    }
  }
  psum = count/n
  qsum = deg.sumsq/n-k
  
  psumk = psum
  qsumk = qsum
  if (k>1){
    count1 = count2 = 0
    for (i in 1:n){
      ids = An[i,k]
      count1 = count1 + length(which(An[ids,]==i))
      count2 = count2 + length(which(An[-i,]==ids))
    }
    psumk = count1/n
    qsumk = count2/n
  }
  
  x1 = 2*k*n+6*k*n*psum/k
  x2 = 3*k^2*n+deg.sumsq+2*k*n*psum+2*daa-x1
  x3 = 4*k^2*n^2*(1+psum/k)-4*(3*k^2*n+deg.sumsq+2*k^2*n*psum/k+2*daa)+2*(2*k*n+6*k*n*psum/k)
  x4 = 4*k^3*n+3*k*deg.sumsq+deg.sum3-3*(3*k^2*n+deg.sumsq+2*k^2*n*psum/k+2*daa)+2*(2*k*n+6*k*n*psum/k)
  x5 = 4*k^3*n+2*k*deg.sumsq+2*dda-2*(3*k^2*n+deg.sumsq+2*k^2*n*psum/k+2*daa)+x1-2*aaa1-6*aaa2
  x6 = 2*aaa1+6*aaa2
  x7 = 2*k*n*(3*k^2*n+deg.sumsq)-4*k^2*n^2*(1+psum/k) - 4*(4*k^3*n+2*k*deg.sumsq+2*dda-(3*k^2*n+deg.sumsq+2*k^2*n*psum/k+2*daa))-2*(4*k^3*n+3*k*deg.sumsq+deg.sum3-(3*k^2*n+deg.sumsq+2*k^2*n*psum/k+2*daa))+ 4*((3*k^2*n+deg.sumsq+2*k^2*n*psum/k+2*daa)-(2*k*n+6*k*n*psum/k))+2*x6
  x8 = 8*k^3*n^3-4*x1-24*x2-6*x3-8*x4-24*x5-8*x6-12*x7
  p1 = t*(t-1)/n/(n-1)
  p2 = t*(t-1)*(t-2)/n/(n-1)/(n-2)
  p3 = t*(t-1)*(t-2)*(t-3)/(n*(n-1)*(n-2)*(n-3))
  p4 = p5 = t*(t-1)*(t-2)*(t-3)/(n*(n-1)*(n-2)*(n-3))
  p6 = p2
  p7 = t*(t-1)*(t-2)*(t-3)*(t-4)/(n*(n-1)*(n-2)*(n-3)*(n-4))
  p8 = t*(t-1)*(t-2)*(t-3)*(t-4)*(t-5)/(n*(n-1)*(n-2)*(n-3)*(n-4)*(n-5))
  
  q1 = (n-t)*(n-t-1)/n/(n-1)
  q2 = (n-t)*(n-t-1)*(n-t-2)/n/(n-1)/(n-2)
  q3 = (n-t)*(n-t-1)*(n-t-2)*(n-t-3)/(n*(n-1)*(n-2)*(n-3))
  q4 = q5 = q3
  q6 = q2
  q7 = (n-t)*(n-t-1)*(n-t-2)*(n-t-3)*(n-t-4)/(n*(n-1)*(n-2)*(n-3)*(n-4))
  q8 = (n-t)*(n-t-1)*(n-t-2)*(n-t-3)*(n-t-4)*(n-t-5)/(n*(n-1)*(n-2)*(n-3)*(n-4)*(n-5))
  
  A11 = 4*x1*p1 + 24*x2*p2 + 6*x3*p3 + 8*x4*p4 + 24*x5*p5 + 8*x6*p6 + 12*x7*p7 + x8*p8
  A12 = 2*x3*t*(t-1)*(n-t)*(n-t-1)/(n*(n-1)*(n-2)*(n-3)) + 4*x7*t*(t-1)*(t-2)*(n-t)*(n-t-1)/(n*(n-1)*(n-2)*(n-3)*(n-4)) + x8*t*(t-1)*(t-2)*(t-3)*(n-t)*(n-t-1)/(n*(n-1)*(n-2)*(n-3)*(n-4)*(n-5))
  A21 = 2*x3*t*(t-1)*(n-t)*(n-t-1)/(n*(n-1)*(n-2)*(n-3)) + 4*x7*(n-t)*(n-t-1)*(n-t-2)*(t)*(t-1)/(n*(n-1)*(n-2)*(n-3)*(n-4)) + x8*(n-t)*(n-t-1)*(n-t-2)*(n-t-3)*(t)*(t-1)/(n*(n-1)*(n-2)*(n-3)*(n-4)*(n-5))
  A22 = 4*x1*q1 + 24*x2*q2 + 6*x3*q3 + 8*x4*q4 + 24*x5*q5 + 8*x6*q6 + 12*x7*q7 + x8*q8
  
  q = (n-t-1)/(n-2)
  p = (t-1)/(n-2)
  ERw3 = q^3*A11 + 3*q^2*p*A12 + 3*q*p^2*A21 + p^3*A22
  
  mu = - (k*t*(t - 1)*(t - n + 1))/((n - 1)*(n - 2)) - (k*(n - t)*(t - 1)*(t - n + 1))/((n - 1)*(n - 2))
  sig1 = ((t - n + 1)^2*((t*(t - 1)*(k*n + n*psum))/(n*(n - 1)) + (t*(t - 1)*(t - 2)*(n*(k + qsum) - 2*k*n - 2*n*psum + 3*k^2*n))/(n*(n - 1)*(n - 2)) + (t*(t - 1)*(t - 2)*(t - 3)*(k*n - n*(k + qsum) + n*psum - 3*k^2*n + k^2*n^2))/(n*(n - 1)*(n - 2)*(n - 3))))/(n - 2)^2 - ((t - n + 1)/(n - 2) + 1)^2*(((n - t)*(k*n + n*psum)*(t - n + 1))/(n*(n - 1)) - ((n - t)*(t - n + 1)*(t - n + 2)*(n*(k + qsum) - 2*k*n - 2*n*psum + 3*k^2*n))/(n*(n - 1)*(n - 2)) + ((n - t)*(t - n + 1)*(t - n + 2)*(t - n + 3)*(k*n - n*(k + qsum) + n*psum - 3*k^2*n + k^2*n^2))/(n*(n - 1)*(n - 2)*(n - 3))) - ((k*t*(t - 1)*(t - n + 1))/((n - 1)*(n - 2)) + (k*(n - t)*(t - 1)*(t - n + 1))/((n - 1)*(n - 2)))^2 + (2*t*((t - n + 1)/(n - 2) + 1)*(n - t)*(t - 1)*(t - n + 1)^2*(k*n - n*(k + qsum) + n*psum - 3*k^2*n + k^2*n^2))/(n*(n - 1)*(n - 2)^2*(n - 3))
  sig = sqrt(apply(cbind(sig1, rep(0,n-1)), 1, max))  # sigma
  
  r =  (ERw3/8- 3*mu*sig^2 - mu^3)/sig^3
  
  theta_b = rep(0,n-1)
  pos = which(1+2*r*b>0)
  theta_b[pos] = (sqrt((1+2*r*b)[pos])-1)/r[pos]
  ratio = exp((b-theta_b)^2/2 + r*theta_b^3/6)/sqrt(1+r*theta_b)
  a = x*Nu(sqrt(2*b^2*x)) * ratio
  a_na = which(is.na(a)==TRUE )
  a[a_na] = 0
  nn = n-1-length(pos)
  if (nn>0.75*n){
    return(0)
  }
  
  if (nn>=2*lower-1){
    print("extrapolate")
    neg = which(1+2*r*b<=0)
    dif = neg[2:nn]-neg[1:(nn-1)]
    id1 = which.max(dif)
    id2 = id1 + ceiling(0.03*n)
    id3 = id2 + ceiling(0.09*n)
    inc = (a[id3]-a[id2])/ceiling(0.06*n)
    a[id2:1] = a[id2+1]-inc*(1:id2)
    a[(n/2+1):n] = a[(n/2):1]
    neg2 = which(a<0 | is.na(a)==TRUE )
    a[neg2] = 0
  }
  integrand = function(s){
    a[s]
  }
  
  result = try(dnorm(b)*b*integrate(integrand, lower, upper, subdivisions=3000, stop.on.error=FALSE)$value, silent=T)
  if (is.numeric(result)){
    return(result)
  }else{
    return(2)
  }
}

pvalgb_Rd_skew = function(n,k, b, y.dist, lower, upper, subdivisions=3000, bmin=1){
  t = 1:(n-1)
  x = rho_one_Rd(n,t)
  
  An = matrix(0,n,k)
  for (i in 1:n){
    An[i,] = (sort(y.dist[i,1:n], index.return=T)$ix)[1:k]
  }
  temp = table(An)
  id = as.numeric(row.names(temp))
  deg = rep(0,n)
  deg[id] = temp
  deg.sumsq = sum(deg^2)
  deg.sum3 = sum(deg^3)
  count = daa = dda = aaa1 = aaa2 = 0
  for (i in 1:n){
    ids = An[i,]
    count = count + length(which(An[ids,]==i))
    daa = daa + deg[i]*length(which(An[ids,]==i))
    dda = dda + deg[i]*sum(deg[ids])
    for (j in ids){
      u = An[j,]
      aaa1 = aaa1 + length(which(An[u,]==i))
      aaa2 = aaa2 + length(which(!is.na(match(ids,u))))
    }
  }
  psum = count/n
  qsum = deg.sumsq/n-k
  
  psumk = psum
  qsumk = qsum
  if (k>1){
    count1 = count2 = 0
    for (i in 1:n){
      ids = An[i,k]
      count1 = count1 + length(which(An[ids,]==i))
      count2 = count2 + length(which(An[-i,]==ids))
    }
    psumk = count1/n
    qsumk = count2/n
  }
  
  x1 = 2*k*n+6*k*n*psum/k
  x2 = 3*k^2*n+deg.sumsq+2*k*n*psum+2*daa-x1
  x3 = 4*k^2*n^2*(1+psum/k)-4*(3*k^2*n+deg.sumsq+2*k^2*n*psum/k+2*daa)+2*(2*k*n+6*k*n*psum/k)
  x4 = 4*k^3*n+3*k*deg.sumsq+deg.sum3-3*(3*k^2*n+deg.sumsq+2*k^2*n*psum/k+2*daa)+2*(2*k*n+6*k*n*psum/k)
  x5 = 4*k^3*n+2*k*deg.sumsq+2*dda-2*(3*k^2*n+deg.sumsq+2*k^2*n*psum/k+2*daa)+x1-2*aaa1-6*aaa2
  x6 = 2*aaa1+6*aaa2
  x7 = 2*k*n*(3*k^2*n+deg.sumsq)-4*k^2*n^2*(1+psum/k) - 4*(4*k^3*n+2*k*deg.sumsq+2*dda-(3*k^2*n+deg.sumsq+2*k^2*n*psum/k+2*daa))-2*(4*k^3*n+3*k*deg.sumsq+deg.sum3-(3*k^2*n+deg.sumsq+2*k^2*n*psum/k+2*daa))+ 4*((3*k^2*n+deg.sumsq+2*k^2*n*psum/k+2*daa)-(2*k*n+6*k*n*psum/k))+2*x6
  x8 = 8*k^3*n^3-4*x1-24*x2-6*x3-8*x4-24*x5-8*x6-12*x7
  p1 = t*(t-1)/n/(n-1)
  p2 = t*(t-1)*(t-2)/n/(n-1)/(n-2)
  p3 = t*(t-1)*(t-2)*(t-3)/(n*(n-1)*(n-2)*(n-3))
  p4 = p5 = t*(t-1)*(t-2)*(t-3)/(n*(n-1)*(n-2)*(n-3))
  p6 = p2
  p7 = t*(t-1)*(t-2)*(t-3)*(t-4)/(n*(n-1)*(n-2)*(n-3)*(n-4))
  p8 = t*(t-1)*(t-2)*(t-3)*(t-4)*(t-5)/(n*(n-1)*(n-2)*(n-3)*(n-4)*(n-5))
  
  q1 = (n-t)*(n-t-1)/n/(n-1)
  q2 = (n-t)*(n-t-1)*(n-t-2)/n/(n-1)/(n-2)
  q3 = (n-t)*(n-t-1)*(n-t-2)*(n-t-3)/(n*(n-1)*(n-2)*(n-3))
  q4 = q5 = q3
  q6 = q2
  q7 = (n-t)*(n-t-1)*(n-t-2)*(n-t-3)*(n-t-4)/(n*(n-1)*(n-2)*(n-3)*(n-4))
  q8 = (n-t)*(n-t-1)*(n-t-2)*(n-t-3)*(n-t-4)*(n-t-5)/(n*(n-1)*(n-2)*(n-3)*(n-4)*(n-5))
  
  A11 = 4*x1*p1 + 24*x2*p2 + 6*x3*p3 + 8*x4*p4 + 24*x5*p5 + 8*x6*p6 + 12*x7*p7 + x8*p8
  A12 = 2*x3*t*(t-1)*(n-t)*(n-t-1)/(n*(n-1)*(n-2)*(n-3)) + 4*x7*t*(t-1)*(t-2)*(n-t)*(n-t-1)/(n*(n-1)*(n-2)*(n-3)*(n-4)) + x8*t*(t-1)*(t-2)*(t-3)*(n-t)*(n-t-1)/(n*(n-1)*(n-2)*(n-3)*(n-4)*(n-5))
  A21 = 2*x3*t*(t-1)*(n-t)*(n-t-1)/(n*(n-1)*(n-2)*(n-3)) + 4*x7*(n-t)*(n-t-1)*(n-t-2)*(t)*(t-1)/(n*(n-1)*(n-2)*(n-3)*(n-4)) + x8*(n-t)*(n-t-1)*(n-t-2)*(n-t-3)*(t)*(t-1)/(n*(n-1)*(n-2)*(n-3)*(n-4)*(n-5))
  A22 = 4*x1*q1 + 24*x2*q2 + 6*x3*q3 + 8*x4*q4 + 24*x5*q5 + 8*x6*q6 + 12*x7*q7 + x8*q8
  
  ER3 = A11 - 3*A12 + 3*A21 - A22
  mu = (k*(n - t)*(t - n + 1))/(n - 1) + (k*t*(t - 1))/(n - 1)
  sig1 = (t*(t - 1)*(k*n + n*psum))/(n*(n - 1)) - ((n - t)*(k*n + n*psum)*(t - n + 1))/(n*(n - 1)) - ((k*(n - t)*(t - n + 1))/(n - 1) + (k*t*(t - 1))/(n - 1))^2 + (t*(t - 1)*(t - 2)*(n*(k + qsum) - 2*k*n - 2*n*psum + 3*k^2*n))/(n*(n - 1)*(n - 2)) + ((n - t)*(t - n + 1)*(t - n + 2)*(n*(k + qsum) - 2*k*n - 2*n*psum + 3*k^2*n))/(n*(n - 1)*(n - 2)) + (t*(t - 1)*(t - 2)*(t - 3)*(k*n - n*(k + qsum) + n*psum - 3*k^2*n + k^2*n^2))/(n*(n - 1)*(n - 2)*(n - 3)) - ((n - t)*(t - n + 1)*(t - n + 2)*(t - n + 3)*(k*n - n*(k + qsum) + n*psum - 3*k^2*n + k^2*n^2))/(n*(n - 1)*(n - 2)*(n - 3)) + (2*t*(n - t)*(t - 1)*(t - n + 1)*(k*n - n*(k + qsum) + n*psum - 3*k^2*n + k^2*n^2))/(n*(n - 1)*(n - 2)*(n - 3))
  sig = sqrt(apply(cbind(sig1, rep(0,n-1)), 1, max))  # sigma
  
  r =  (ER3/8- 3*mu*sig^2 - mu^3)/sig^3
  for(i in 1:length(r)){
    if (is.na(r[i])==TRUE | abs(r[i])=='Inf'){
      r[i]=0 }
  }
  if (r[n/2]==0) {r[n/2]=r[n/2+1]}
  theta_b = rep(0,n-1)
  pos = which(1+2*r*b>0)
  theta_b[pos] = (sqrt((1+2*r*b)[pos])-1)/r[pos]
  ratio = exp((b-theta_b)^2/2 + r*theta_b^3/6)/sqrt(1+r*theta_b)
  
  # if(length(which(is.infinite(ratio)==TRUE))>0.95*n) {
  #   return(0)
  # }
  # ratio[ratio==Inf]= max(range(ratio,finite=T))
  nn.l = ceiling(n/2)-length(which(1+2*r[1:ceiling(n/2)]*b>0))
  nn.r = ceiling(n/2)-length(which(1+2*r[ceiling(n/2+1):n]*b>0))
  if (nn.l>0.35*n || nn.r>0.35*n){
    return(0)
  }
  if (nn.l>=lower){
    neg = which(1+2*r[1:ceiling(n/2)]*b<=0)
    dif = c(diff(neg),n/2-nn.l)
    id1 = which.max(dif)
    id2 = id1 + ceiling(0.03*n)
    id3 = id2 + ceiling(0.09*n)
    inc = (ratio[id3]-ratio[id2])/(id3-id2)
    ratio[id2:1] = ratio[id2+1]-inc*(1:id2)
  }
  if (nn.r>=(n-upper)){
    print('extrapolate')
    neg = which(1+2*r[ceiling(n/2+1):(n-1)]*b<=0)
    id1 = neg[1]+ceiling(n/2)-1
    id2 = id1 - ceiling(0.03*n)
    id3 = id2 - ceiling(0.09*n)
    inc = (ratio[id3]-ratio[id2])/(id3-id2)
    ratio[id2:n] = ratio[id2-1]+inc*((id2:n)-id2)
    ratio[ratio<0]=0
  }
  a = x*Nu(sqrt(2*b^2*x)) * ratio[1:(n-1)]
  neg2 = which(a<0)
  a[neg2] = 0
  integrand = function(s){
    a[s]
  }
  result = try(2*dnorm(b)*b*integrate(integrand, lower, upper, subdivisions=3000, stop.on.error=FALSE)$value, silent=T)
  if (is.numeric(result)){
    return(result)
  }else{
    return(2)
  }
}



R = function(n,t,k,y.dist){
An = matrix(0,n,k)
for (i in 1:n){
  An[i,] = (sort(y.dist[i,], index.return=T)$ix)[1:k]
}

temp = table(An)
id = as.numeric(row.names(temp))
deg = rep(0,n)
deg[id] = temp
mix = 0
Mix = 0
for (i in 1:n){
  for (j in 1:k){
    Mix = Mix + deg[i]*deg[An[i,j]]
    mix = mix + deg[i]*(deg[An[i,j]]-1)
  }
}
cn = sum((deg-k)^2)/n/k
count = 0
double = rep(0,n)
for (i in 1:n){
  ids = An[i,]
  double[i] = length(which(An[ids,]==i))
  count = count + length(which(An[ids,]==i))
}


R2 = (cn + k)*n*k
N = rep(0,23)
P = rep(0,23)
N[1] = n*k
N[2] = 3*count
N[3] = 6*n*k^2 - 6*count
N[4] = 3*n*k*(k-1)
N[5] = 3*R2 - 3*n*k
N[6] = 6*(k-1)*count
N[7] = 6*(sum(deg*double)-count)
for (i in 1:n){
  for (j in 1:k){
    for (m in 1:k){
      N[8] = N[8] + length(which(An[An[i,j],]==An[i,m]))
      N[9] = N[9] + length(which(An[An[An[i,j],m],]==i))
    }
  }
}
N[8] = 6*N[8]
N[9] = 2*N[9]
N[10] = 3*(n^2*k^2 - 3*n*k^2 + n*k + count - R2)
N[11] = 3*count*(n*k - 2*k) - N[7]
N[12] = n*k*(k-1)*(k-2)
N[13] = 3*n*k^2*(k-1) - N[6]
N[14] = 3*k*R2 - 3*n*k^2 - N[7]
N[15] = sum(deg^3) - 3*R2 + 2*n*k
N[16] = 6*n*k^3 - N[6] - N[7] - 2*N[2] - 3*N[9]
N[17] = 6*mix - N[7] - N[8]
N[18] = 6*n*k^2*(k-1) - N[6] - N[8]
N[19] = 6*(k-1)*(R2 - n*k) - N[8]
N[20] = 3*k^2*(k-1)*(n-3)*n - N[13] - N[19]
N[21] = 3*k*(n-3)*(R2 - n*k) - 3*N[15] - N[17]
N[22] = 6*(n-3)*k*(n*k^2 - count) - 2*N[14] - N[16] - N[17]
N[23] = n^3*k^3 - sum(N[1:22])



  c_t = -((n - 1)*(2*R2*n + 4*count*n - R2*n^2 + R2*n^3 + 4*R2*t^2 - 4*count*n^2 + 8*count*t^2 + 4*k*n^2 - 4*k*n^3 + 6*k^2*n^2 + k^2*n^3 - k^2*n^4 - 8*count*n*t^2 + 8*count*n^2*t + 8*k*n*t^2 - 8*k*n^2*t + 8*k*n^3*t - 8*k*n^2*t^2 + 12*k^2*n*t^2 - 12*k^2*n^2*t + 4*k^2*n^3*t - 4*R2*n*t - 8*count*n*t - 4*k^2*n^2*t^2 + 4*R2*n*t^2 - 4*R2*n^2*t))/(2*t*(n - t)*(2*R2 + 4*count - 3*R2*n - 8*count*n + 4*k*n + 2*R2*n^2 - R2*n^3 + 4*R2*t^2 + 4*count*n^2 - 4*count*t^2 - 8*k*n^2 + 6*k^2*n + 4*k*n^3 - 5*k^2*n^2 - 2*k^2*n^3 + k^2*n^4 + 4*count*n*t^2 - 4*count*n^2*t - 4*k*n*t^2 + 4*k*n^2*t - 4*k*n^3*t + 4*k*n^2*t^2 - 12*k^2*n*t^2 + 12*k^2*n^2*t - 4*k^2*n^3*t - 4*R2*n*t + 4*count*n*t + 4*k^2*n^2*t^2 - 4*R2*n*t^2 + 4*R2*n^2*t))
  P[1] = P[2] = 2*t*(n-t)/n/(n-1)
  for (i in 3:7){
    P[i] = t*(n-t)/n/(n-1)
  }
  P[8] = P[9] = 0
  P[10] = P[11] = 4*t*(n-t)*(t-1)*((n-t)-1)/n/(n-1)/(n-2)/(n-3)
  for (i in 12:15){
    P[i] = t*(n-t)*((n-t-1)*(n-t-2) + (t-1)*(t-2))/n/(n-1)/(n-2)/(n-3)
  }
  for (i in 16:22){
    P[i] = 2*t*(t-1)*(n-t)*(n-t-1)/n/(n-1)/(n-2)/(n-3)
  }
  P[23] = 8*t*(t-1)*(t-2)*(n-t)*(n-t-1)*(n-t-2)/n/(n-1)/(n-2)/(n-3)/(n-4)/(n-5)
  E3 = sum(N*P)
  return(E3)
}



R.p = function(n,k, b, y.dist, n0, n1){
An = matrix(0,n,k)
for (i in 1:n){
  An[i,] = (sort(y.dist[i,], index.return=T)$ix)[1:k]
}

temp = table(An)
id = as.numeric(row.names(temp))
deg = rep(0,n)
deg[id] = temp
mix = 0
Mix = 0
for (i in 1:n){
  for (j in 1:k){
    Mix = Mix + deg[i]*deg[An[i,j]]
    mix = mix + deg[i]*(deg[An[i,j]]-1)
  }
}
cn = sum((deg-k)^2)/n/k
count = 0
double = rep(0,n)
for (i in 1:n){
  ids = An[i,]
  double[i] = length(which(An[ids,]==i))
  count = count + length(which(An[ids,]==i))
}


R2 = (cn + k)*n*k
c_t = rep(0,n1-n0+1)
E3 = rep(0,n1-n0+1)
E3hao = rep(0,n1-n0+1)
E = rep(0,n1-n0+1)
r1 = rep(0,n1-n0+1)
r2 = rep(0,n1-n0+1)
r3 = rep(0,n1-n0+1)
r4 = rep(0,n1-n0+1)
Gammahao = rep(0,n1-n0+1)
Thetahao = rep(0,n1-n0+1)
Shao = rep(0,n1-n0+1)
Var = rep(0,n1-n0+1)
Gamma = rep(0,n1-n0+1)
Theta = rep(0,n1-n0+1)
S = rep(0,n1-n0+1)
N = rep(0,23)
P = matrix(0,23,n1-n0+1)
N[1] = n*k
N[2] = 3*count
N[3] = 6*n*k^2 - 6*count
N[4] = 3*n*k*(k-1)
N[5] = 3*R2 - 3*n*k
N[6] = 6*(k-1)*count
N[7] = 6*(sum(deg*double)-count)
for (i in 1:n){
  for (j in 1:k){
    for (m in 1:k){
      N[8] = N[8] + length(which(An[An[i,j],]==An[i,m]))
      N[9] = N[9] + length(which(An[An[An[i,j],m],]==i))
    }
  }
}
N[8] = 6*N[8]
N[9] = 2*N[9]
N[10] = 3*(n^2*k^2 - 3*n*k^2 + n*k + count - R2)
N[11] = 3*count*(n*k - 2*k) - N[7]
N[12] = n*k*(k-1)*(k-2)
N[13] = 3*n*k^2*(k-1) - N[6]
N[14] = 3*k*R2 - 3*n*k^2 - N[7]
N[15] = sum(deg^3) - 3*R2 + 2*n*k
N[16] = 6*n*k^3 - N[6] - N[7] - 2*N[2] - 3*N[9]
N[17] = 6*mix - N[7] - N[8]
N[18] = 6*n*k^2*(k-1) - N[6] - N[8]
N[19] = 6*(k-1)*(R2 - n*k) - N[8]
N[20] = 3*k^2*(k-1)*(n-3)*n - N[13] - N[19]
N[21] = 3*k*(n-3)*(R2 - n*k) - 3*N[15] - N[17]
N[22] = 6*(n-3)*k*(n*k^2 - count) - 2*N[14] - N[16] - N[17]
N[23] = n^3*k^3 - sum(N[1:22])


for (t in n0:n1){
  c_t[t-n0+1] = -((n - 1)*(2*R2*n + 4*count*n - R2*n^2 + R2*n^3 + 4*R2*t^2 - 4*count*n^2 + 8*count*t^2 + 4*k*n^2 - 4*k*n^3 + 6*k^2*n^2 + k^2*n^3 - k^2*n^4 - 8*count*n*t^2 + 8*count*n^2*t + 8*k*n*t^2 - 8*k*n^2*t + 8*k*n^3*t - 8*k*n^2*t^2 + 12*k^2*n*t^2 - 12*k^2*n^2*t + 4*k^2*n^3*t - 4*R2*n*t - 8*count*n*t - 4*k^2*n^2*t^2 + 4*R2*n*t^2 - 4*R2*n^2*t))/(2*t*(n - t)*(2*R2 + 4*count - 3*R2*n - 8*count*n + 4*k*n + 2*R2*n^2 - R2*n^3 + 4*R2*t^2 + 4*count*n^2 - 4*count*t^2 - 8*k*n^2 + 6*k^2*n + 4*k*n^3 - 5*k^2*n^2 - 2*k^2*n^3 + k^2*n^4 + 4*count*n*t^2 - 4*count*n^2*t - 4*k*n*t^2 + 4*k*n^2*t - 4*k*n^3*t + 4*k*n^2*t^2 - 12*k^2*n*t^2 + 12*k^2*n^2*t - 4*k^2*n^3*t - 4*R2*n*t + 4*count*n*t + 4*k^2*n^2*t^2 - 4*R2*n*t^2 + 4*R2*n^2*t))
  P[1,t-n0+1] = P[2,t-n0+1] = 2*t*(n-t)/n/(n-1)
  for (i in 3:7){
    P[i,t-n0+1] = t*(n-t)/n/(n-1)
  }
  P[8,t-n0+1] = P[9,t-n0+1] = 0
  P[10,t-n0+1] = P[11,t-n0+1] = 4*t*(n-t)*(t-1)*((n-t)-1)/n/(n-1)/(n-2)/(n-3)
  for (i in 12:15){
    P[i,t-n0+1] = t*(n-t)*((n-t-1)*(n-t-2) + (t-1)*(t-2))/n/(n-1)/(n-2)/(n-3)
  }
  for (i in 16:22){
    P[i,t-n0+1] = 2*t*(t-1)*(n-t)*(n-t-1)/n/(n-1)/(n-2)/(n-3)
  }
  P[23,t-n0+1] = 8*t*(t-1)*(t-2)*(n-t)*(n-t-1)*(n-t-2)/n/(n-1)/(n-2)/(n-3)/(n-4)/(n-5)
  E3[t-n0+1] = sum(N*P[,t-n0+1])
  
  r1[t-n0+1] = 2*t*(n-t)/n/(n-1)
  r2[t-n0+1] = 4*t*(t-1)*(n-t)*(n-t-1)/n/(n-1)/(n-2)/(n-3)
  r3[t-n0+1] = t*(n-t)*((t-1)*(t-2) + (n-t-1)*(n-t-2))/n/(n-1)/(n-2)/(n-3)
  r4[t-n0+1] = 8*t*(t-1)*(t-2)*(n-t)*(n-t-1)*(n-t-2)/n/(n-1)/(n-2)/(n-3)/(n-4)/(n-5)
  
  E3hao[t-n0+1] = 8*k^3*n^3*r4[t-n0+1] + 12*k^2*n^2*(r2[t-n0+1] + 3*k*(r2[t-n0+1] - 2*r4[t-n0+1])) + 
    4*k*n*(3*r2[t-n0+1] - r1[t-n0+1] + 2*r3[t-n0+1] - 4*r4[t-n0+1] + 3*k*(3*r1[t-n0+1] - 2*r2[t-n0+1] - 4*r3[t-n0+1] - 4*r4[t-n0+1]) + 8*k^2*(r3[t-n0+1] - 3*r2[t-n0+1] + 5*r4[t-n0+1])) + 
    24*count/n*(k*n^2*r4[t-n0+1] + k*n*(r1[t-n0+1] + r2[t-n0+1] - 2*r3[t-n0+1] - 4*r4[t-n0+1]) + 2*n*(2*r3[t-n0+1] - r1[t-n0+1] + 2*r4[t-n0+1])) + 
    12*(R2/n - k)*(k*n^2*(r2[t-n0+1] - 2*r4[t-n0+1]) + k*n*(2*r3[t-n0+1] - 5*r2[t-n0+1] + 8*r4[t-n0+1]) + n*(r1[t-n0+1] + r2[t-n0+1]- 2*r3[t-n0+1]-4*r4[t-n0+1])) + 
    4*(2*r3[t-n0+1] - 3*r2[t-n0+1] + 4*r4[t-n0+1])*sum(deg^3) + 
    24*(r1[t-n0+1] + r2[t-n0+1] - 2*r3[t-n0+1]-4*r4[t-n0+1])*(sum(deg*double)) + 
    24*(2*r4[t-n0+1] - r2[t-n0+1])*Mix  - 
    16*r4[t-n0+1]*(0.5*N[9] + 0.5*N[8])
  E3hao[t-n0+1] = E3hao[t-n0+1]/8
  
  
  
  E[t-n0+1] = 2*k*t*(n-t)/(n-1)
  Var[t-n0+1] = (2*t*(n - t)*(count + k*n))/(n*(n - 1)) - (4*k^2*t^2*(n - t)^2)/(n - 1)^2 + (t*(n - t)*(3*n*k^2 - 2*n*k + R2 - 2*count))/(n*(n - 1)) - (4*t*(n - t)*(t - 1)*(t - n + 1)*(k^2*n^2 - 3*k^2*n + k*n - R2 + count))/(n*(n - 1)*(n - 2)*(n - 3))
  Gamma[t-n0+1] = (E[t-n0+1]^3 + 3*E[t-n0+1]*Var[t-n0+1] - E3[t-n0+1])/((Var[t-n0+1])^1.5)
  Gammahao[t-n0+1] = (E[t-n0+1]^3 + 3*E[t-n0+1]*Var[t-n0+1] - E3hao[t-n0+1])/((Var[t-n0+1])^1.5)
  
  Theta[t-n0+1] = (-1 + (1+2*Gamma[t-n0+1]*b)^0.5)/Gamma[t-n0+1]
  S[t-n0+1] = exp(0.5*(b-Theta[t-n0+1])^2 + 1/6*Gamma[t-n0+1]*Theta[t-n0+1]^3)/((1+Gamma[t-n0+1]*Theta[t-n0+1])^0.5)
  
  Thetahao[t-n0+1] = (-1 + (1+2*Gammahao[t-n0+1]*b)^0.5)/Gammahao[t-n0+1]
  Shao[t-n0+1] = exp(0.5*(b-Thetahao[t-n0+1])^2 + 1/6*Gammahao[t-n0+1]*Thetahao[t-n0+1]^3)/((1+Gammahao[t-n0+1]*Thetahao[t-n0+1])^0.5)
  
}
nu = function(x){
  2/x*(pnorm(x/2)-0.5)/((x/2)*pnorm(x/2)+dnorm(x/2))
}
temp = dnorm(b)*b*sum(c_t*S*nu(sqrt(2*c_t*b^2)))
integrandhao = c_t*Shao*nu(sqrt(2*c_t*b^2))
for (i in (n/2):1){
  if (is.na(integrandhao[i])) integrandhao[i] = integrandhao[i+1] - (integrandhao[i+2]-integrandhao[i+1])
  
  if (integrandhao[i]<0) integrandhao[i] = 0
}
for (i in (n/2):n){
  if (is.na(integrandhao[i])) integrandhao[i] = integrandhao[i-1] - (integrandhao[i-2]-integrandhao[i-1])
  
  if (integrandhao[i]<0) integrandhao[i] = 0
}

integrand = c_t*S*nu(sqrt(2*c_t*b^2))
for (i in (n/2):1){
  if (is.na(integrand[i])) integrand[i] = integrand[i+1] - (integrand[i+2]-integrand[i+1])
  
  if (integrand[i]<0) integrand[i] = 0
}
for (i in (n/2):n){
  if (is.na(integrand[i])) integrand[i] = integrand[i-1] - (integrand[i-2]-integrand[i-1])
  
  if (integrand[i]<0) integrand[i] = 0
}

temp = dnorm(b)*b*sum(integrand)
return(temp)
}

R.pb = function(n,k, b, y.dist, n0, n1){
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
  c_t = rep(0,n1-n0+1)
  CT = rep(0,n1-n0+1)
  ct = rep(0,n1-n0+1)
  miu = rep(0,n1-n0+1)
  MIU1 = rep(0,n1-n0+1)
  sigma = rep(0,n1-n0+1)
  MIU = rep(0,n1-n0+1)
  MIU2 = rep(0,n1-n0+1)
  decimal = rep(0,n1-n0+1)
  for (t in n0:n1){
    c_t[t-n0+1] = -((n - 1)*(2*R2*n + 4*count*n - R2*n^2 + R2*n^3 + 4*R2*t^2 - 4*count*n^2 + 8*count*t^2 + 4*k*n^2 - 4*k*n^3 + 6*k^2*n^2 + k^2*n^3 - k^2*n^4 - 8*count*n*t^2 + 8*count*n^2*t + 8*k*n*t^2 - 8*k*n^2*t + 8*k*n^3*t - 8*k*n^2*t^2 + 12*k^2*n*t^2 - 12*k^2*n^2*t + 4*k^2*n^3*t - 4*R2*n*t - 8*count*n*t - 4*k^2*n^2*t^2 + 4*R2*n*t^2 - 4*R2*n^2*t))/(2*t*(n - t)*(2*R2 + 4*count - 3*R2*n - 8*count*n + 4*k*n + 2*R2*n^2 - R2*n^3 + 4*R2*t^2 + 4*count*n^2 - 4*count*t^2 - 8*k*n^2 + 6*k^2*n + 4*k*n^3 - 5*k^2*n^2 - 2*k^2*n^3 + k^2*n^4 + 4*count*n*t^2 - 4*count*n^2*t - 4*k*n*t^2 + 4*k*n^2*t - 4*k*n^3*t + 4*k*n^2*t^2 - 12*k^2*n*t^2 + 12*k^2*n^2*t - 4*k^2*n^3*t - 4*R2*n*t + 4*count*n*t + 4*k^2*n^2*t^2 - 4*R2*n*t^2 + 4*R2*n^2*t))
  }
  nu = function(x){
    2/x*(pnorm(x/2)-0.5)/((x/2)*pnorm(x/2)+dnorm(x/2))
  }
  p = dnorm(b)/b*sum(sigma)
  temp = dnorm(b)*b*sum(c_t*nu(sqrt(2*c_t*b^2)))
  return(temp)
}

n = 1000
d = 100
k = 3
t = 200
b = 3.05
n = 1000
n0 = 25
n1 = n-n0
y = matrix(rnorm(d*n),n,d)
y.dist = as.matrix(dist(y))
diag(y.dist) = max(y.dist)+100
#p value before skewness correction
Lpb = pvalgb_R(n, b,psum = pk(y.dist,k),qsum=qk(y.dist,k),n0, n1)
Jpb = R.pb(n,k, b, y.dist, n0, n1)
difference_of_p_before = Lpb - Jpb
#the difference is not zero. I think the reason is that I use "dnorm(b)*b*sum(c_t*nu(sqrt(2*c_t*b^2)))"
#to calculate the p value while you use the integrate "dnorm(b)*b*integrate(integrand, lower, upper, subdivisions=3000, stop.on.error=FALSE)$value"

#E(R3)
LYNNA = EX3.f(1000, 200, 3, y.dist)
Jingwen = R(1000,200,3,y.dist)
difference_of_third_moment_R = LYNNA - Jingwen#which = 0 indicating that they are the same
Lp = pvalgb_R_skew(n,k, b, y.dist, n0, n1, subdivisions=3000, bmin=1)
Jp = R.p(n,k, b, y.dist, n0, n1)
Difference_of_p_after_skewness = Lp- Jp
#which !=0 indicating that they are different because of the procedure of extrapolating

