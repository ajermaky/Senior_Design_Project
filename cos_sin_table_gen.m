x = num2hex(single(cos(-2*pi/256* (0:127))));
y = num2hex(single(sin(-2*pi/256* (0:127))));

cosf = fopen('cos.coe','wt');
sinf = fopen('sin.coe','wt');

fprintf(cosf,'memory_initialization_radix=16;\n');
fprintf(cosf,'memory_initialization_vector=\n');

fprintf(sinf,'memory_initialization_radix=16;\n');
fprintf(sinf,'memory_initialization_vector=\n');

for i=1:128
        for j=1:8
            fprintf(cosf,'%c',x(i,j));
        end
        
        if(i==128)
            fprintf(cosf,';\n');
        else
            fprintf(cosf, ',\n');
        end
end
for i=1:128
        for j=1:8
            fprintf(sinf,'%c',y(i,j));
        end
        
        if(i==128)
            fprintf(sinf,';\n');
        else
            fprintf(sinf, ',\n');
        end
end

fclose(cosf);
fclose(sinf);
