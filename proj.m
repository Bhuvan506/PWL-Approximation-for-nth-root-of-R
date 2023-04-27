%Pseudocode of the proposed self-adaptive segmentation method for R^(1/N)
N = 15;
Mr = 1:1/2^15:(2-1/2^15);
Er = -14:1:15;
LN = length(N);
LMR = length(Mr);
LER = length(Er);
% right and left window of bisection method
F = 1; % flag for while loop

Arr_Err = [];
Err_hw = 1.9531*10^-3;
mae_hw = Err_hw;
QF = 0.3;
Err_sw = QF*mae_hw;
mae_sw = Err_sw;
rmae = mae_sw;
lmae = 0;
qw = ceil(-log2(mae_hw));
R=[];
while F==1
    Arr_Err = [];
    R = [];
    [k_log,b_log,si_log,ei_log] = seg_log2(15,1,2,mae_sw); 
    [k_pow,b_pow,si_pow,ei_pow] = seg_pow2(15,0,1,mae_sw);
    for i=1:1:LN
        for j=1:1:LER
            for m=1:1:LMR
                f = pow2((Er(j)+log2(Mr(m)))/N(i));
                idx1 = 1;
                for k=2:length(si_log)
                    if(si_log(k) > Mr(m))
                        idx1 = k-1;
                        break;
                    end
                end
                ki_log = round(k_log(idx1)*2^(qw))*2^(-qw);
                bi_log = round(b_log(idx1)*2^(qw))*2^(-qw);
                hi_m = (floor(ki_log*Mr(m)*2^(qw)) + bi_log*2^(qw))*2^(-qw); 
                inv_N = round((1/N(i))*2^(qw))*2^(-qw);
                P = floor((inv_N*(Er(j)+hi_m))*2^(qw))*2^(-qw);
                PI = floor(P);
                PF = P-PI;
                idx2 = 1;
                for k=2:length(si_pow)
                    if(si_pow(k) > PF)
                        idx2 = k-1;
                        break;
                    end
                end
                ki_pow = round(k_pow(idx2)*2^(qw))*2^(-qw);
                bi_pow = round(b_pow(idx2)*2^(qw))*2^(-qw);
                h_pf = (floor(ki_pow*PF*2^(qw)) + bi_pow*2^(qw))*2^(-qw); 
                h = pow2(PI)*floor(h_pf*2^(qw))*2^(-qw);
                err = abs((f-h)/f);
                if(err < 0.02)
                    Arr_Err(end+1) = err;
                    R(end+1) = Mr(m)*pow2(Er(j));
                end
            end
        end
    end
    Max_Err = mean(Arr_Err);
    disp(Max_Err);
    % Find maximum value of mae_sw with the restrict of Max_Err using
    % bisection method.
    if Max_Err <= Err_sw
        if(rmae-lmae<10)
            F = 0;
        else
            lmae = mae_sw;
        end
    else
        rmae = mae_sw;
        mae_sw = (rmae+lmae)/2;
        mae_hw = mae_sw/QF;
        if Max_Err > mae_hw
            qw = qw+1;
        end
    end
end

rbn = nthroot(R,N);
%plot(R,rbn)
plot(R,Arr_Err, '.','MarkerSize',3);
grid on;
title('Error of R^(1/n) vs R')
xlabel('R')
ylabel('Err')
% variables a, b, and c in the below two functions represent the fractional
% bit number of the input and the start and end of the input
% range, respectively
function [k_arr,b_arr,si_arr,ei_arr] = seg_log2(a,b,c,mae_sw)
    Num = (c-b)*2^a + 1; 
    points = linspace(b,c,Num);
    si = 1;li = 1;ei = Num; ri = Num;
    k_arr = [];
    b_arr = [];
    si_arr = [];
    ei_arr = [];
    while(1)
        while(1)
            Err = [];
            k = (log2(points(ei))-log2(points(si)))/(ei-si);
            b = log2(points(si))-k*points(si);
            for i=si:ei
                Err(end+1) = k*points(i)+b-log2(points(i));
            end
            MAE = (max(Err)-min(Err))/2;
            if(MAE <= mae_sw)
                if(ei == ri || ei == ri-1)
                    k_arr(end+1) = k;
                    b_arr(end+1) = b + (max(Err)+min(Err))/2;
                    si_arr(end+1) = points(si);
                    ei_arr(end+1) = points(ei);
                    break;
                else
                    li = ei;
                    ei = ceil((li+ri)/2);
                end
            else
                ri = ei;
                ei = floor((li+ri)/2);
            end
        end
        if(ei == Num)
            break;
        elseif(ei == Num-1)
            k = (log2(points(Num))-log2(points(Num-1)));
            b = log2(points(Num))-k*points(Num-1);
            k_arr(end+1) = k;
            b_arr(end+1) = b + (k*points(Num)+b-log2(points(Num))+k*points(Num-1)+b-log2(points(Num-1)))/2;
            si_arr(end+1) = points(Num-1);
            ei_arr(end+1) = points(Num);
            break;
        else
            si = ei;li = ei; ei = Num; ri = Num;
        end
    end
end

function [k_arr,b_arr,si_arr,ei_arr] = seg_pow2(a,b,c,mae_sw)
    Num = (c-b)*2^a + 1; 
    points = linspace(b,c,Num);
    si = 1;li = 1;ei = Num; ri = Num;
    k_arr = [];
    b_arr = [];
    si_arr = [];
    ei_arr = [];
    while(1)
        while(1)
            Err = [];
            k = (pow2(points(ei))-pow2(points(si)))/(ei-si);
            b = pow2(points(si))-k*points(si);
            for i=si:ei
                Err(end+1) = k*points(i)+b-pow2(points(i));
            end
            MAE = (max(Err)-min(Err))/2;
            if(MAE <= mae_sw)
                if(ei == ri || ei == ri-1)
                    k_arr(end+1) = k;
                    b_arr(end+1) = b + (max(Err)+min(Err))/2;
                    si_arr(end+1) = points(si);
                    ei_arr(end+1) = points(ei);
                    break;
                else
                    li = ei;
                    ei = ceil((ei+ri)/2);
                end
            else
                ri = ei;
                ei = floor((li+ei)/2);
            end
        end
        if(ei == Num)
            break;
        elseif(ei == Num-1)
            k = (pow2(points(Num))-pow2(points(Num-1)));
            b = pow2(points(Num))-k*points(Num-1);
            k_arr(end+1) = k;
            b_arr(end+1) = b + (k*points(Num)+b-pow2(points(Num))+k*points(Num-1)+b-pow2(points(Num-1)))/2;
            si_arr(end+1) = points(Num-1);
            ei_arr(end+1) = points(Num);
            break;
        else
            si = ei;li = ei; ei = Num; ri = Num;
        end
    end
end