#include <stdio.h>

#include <iostream>
#include <fstream>
using namespace std;
#include <math.h>
#include <limits.h>
#include <stdlib.h>

const double PI = M_PI;
#define N 14 //number steps
#define ARG_N      65536 //how much 360 degrees in int

void calc_cordic(int& re, int& im, int module, double angle) {
    double d_angle[N];
    double sum_angles = .0f;
    //int tst_an = 0;
    for(int k = 0; k < N; k++) {
        d_angle[k] = atan(1.0/pow(2,k)) * (180/PI);
        sum_angles += d_angle[k];
        //printf("%f\n", d_angle[k]);
        //tst_an = d_angle[k]*ARG_N/360.0f;
        //printf("%d\n", tst_an);
    }

    double cordic_gain = .0f;
    for(int k =0; k < N; k++) {
        if(k == 0) {
            cordic_gain = cos(d_angle[k]*PI/180.0);
        }
        else {
            cordic_gain *= cos(d_angle[k]*PI/180.0);
        }
    }

    int Re[N];
    int Im[N];
    int CORDIC_GAIN = cordic_gain*module;

    //printf("%d\n", CORDIC_GAIN);

    Re[0] = CORDIC_GAIN;
    Im[0] = CORDIC_GAIN;

    double my_arg = angle;
    if(my_arg >= 90.0f && my_arg < 180) {
        my_arg -= 90.0f;
    }
    if(my_arg >= 180.0f && my_arg < 270) {
        my_arg -= 180.0f;
    }
    if(my_arg >= 270.0f && my_arg < 360) {
        my_arg -= 270.0f;
    }

    double ARG[N];
    ARG[0] = 45.0f;


    //printf("%f\t\t%d\t%d\t\n", ARG[0], Re[0], Im[0]);
    int tmp_i = 0;
    int tmp_Re = 0;
    int tmp_Im = 0;
    int tst = 0;
    for(int i = 1; i < N; i++) {
        tmp_i = int(pow(2,i-1));
        if(ARG[i-1] > my_arg) {
            tmp_Im = Im[i-1] + tmp_i;
            tmp_Re = Re[i-1] + tmp_i;
            //Re[i] = Re[i-1] + (tmp_Im >> i);
            Re[i] = Re[i-1] + (tmp_Im >> i);
            Im[i] = Im[i-1] - (tmp_Re >> i);
            ARG[i] = ARG[i-1] - d_angle[i];
        }
        else {
            tmp_Im = Im[i-1] + tmp_i;
            tmp_Re = Re[i-1] + tmp_i;
            Re[i] = Re[i-1] - (tmp_Im >> i);
            Im[i] = Im[i-1] + (tmp_Re >> i);
            ARG[i] = ARG[i-1] + d_angle[i];
        }
    }

    double mcos = cos(angle*PI/180);
    double msin = sin(angle*PI/180);
    double r = sqrt(msin*msin + mcos*mcos);
    int icos = mcos*(module );
    int isin = msin*(module );

    int tmp;


    if(angle >= 90.0f && angle < 180) {
        tmp = Re[N-1];
        Re[N-1] = -Im[N-1];
        Im[N-1] = tmp;
        ARG[N-1] += 90.0;
    }
    if(angle >= 180.0f && angle < 270) {
        tmp = Re[N-1];
        Re[N-1] = -Re[N-1];
        Im[N-1] = -Im[N-1];
        ARG[N-1] += 180.0;
    }
    if(angle >= 270.0f && angle < 360) {
        tmp = Re[N-1];
        Re[N-1] = Im[N-1];
        Im[N-1] = -tmp;
        ARG[N-1] += 270.0;
    }

    int tmp_cos = Re[N-1] - icos;
        tmp_cos = tmp_cos < 0 ? -tmp_cos : tmp_cos;
    int tmp_sin = Im[N-1] - isin;
        tmp_sin = tmp_sin < 0 ? -tmp_sin : tmp_sin;

    re = Re[N-1];
    im = Im[N-1];

    //static int max_delta_cos = tmp_cos > max_delta_cos ? tmp_cos : max_delta_cos;
    //static int max_delta_sin = tmp_sin > max_delta_sin ? tmp_sin : max_delta_sin;
    //printf("%f\t%d\t%d", ARG[N-1], re, im);
}

int main() {
    ofstream console("debug.txt", ios::out);
    ofstream cos_delta_file("cos_delta.txt", ios::out);
    ofstream sin_delta_file("sin_delta.txt", ios::out);
    int Re = 0;
    int Im = 0;
    int tmp_cos = 0;
    int tmp_sin = 0;
    int max_delta_re = 0;
    int max_delta_im = 0;
    int max_arg = 0;
    int disp_cos = 0;
    int disp_sin = 0;
    for(int i = 0; i < ARG_N; i++) {
    //for(int i = 0; i < 360000; i++) {
        double  my_angle = (double)i*360.0/ARG_N;
        //double  my_angle = (double)i/1000.0;
        int     my_modul = 8191;
        calc_cordic(Re,Im, my_modul, my_angle);

        double mcos = cos(my_angle*PI/180);
        double msin = sin(my_angle*PI/180);

        int icos = mcos*(my_modul);
        int isin = msin*(my_modul);



        tmp_cos = Re - icos;
        tmp_sin = Im - isin;

        cos_delta_file << tmp_cos << endl;
        sin_delta_file << tmp_sin << endl;

        //printf("\t%d\t%d\t%d\t%d\n",icos, isin, tmp_cos, tmp_sin);
        console << tmp_cos <<  endl;//"\t" << tmp_sin<< endl;// << "\t" << tmp_sin << "\t" << endl;
        //tmp_cos = tmp_cos < 0 ? -tmp_cos : tmp_cos;
        //tmp_sin = tmp_sin < 0 ? -tmp_sin : tmp_sin;


        max_arg = tmp_cos > max_delta_re ? i : max_arg;
        max_delta_re = abs(tmp_cos) > abs(max_delta_re) ? tmp_cos : max_delta_re;
        max_delta_im = abs(tmp_sin) > abs(max_delta_im) ? tmp_sin : max_delta_im;

        disp_cos += tmp_cos;
        disp_sin += tmp_sin;

    }

    printf("\n%d\t%d\n", max_delta_re, max_delta_im);
    printf("\n%d\t%d\n", disp_cos, disp_sin);

    console.close();
    cos_delta_file.close();
    sin_delta_file.close();
    return 0;
}
