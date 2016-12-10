% a = cos(-2*pi/256*(0:127));
% X = zeros(1,256);
% X(1:128) = a;
% X(129:256) = a;
X = filt_x(257:256+256);
X=bitrevorder(X);

stride = 1;

while(stride<256)
   r= 128/stride;
   k=1;
   while(k<=256)
       for d = (0:1:stride-1)
           a = X(k+d);
           b = X(k+d+stride);
           X(k+d) = a + exp(-2*pi/256*(1i)*r*d)*b;
          X(k+d+stride) = a - exp(-2*pi/256*(1i)*r*d)*b;
         
       end
       k=k+stride*2;
   end
    
   stride= stride*2;
end

rX = abs(real(X));
iX = abs(imag(X));

absX = max(rX,iX)+ min(rX,iX)/4;