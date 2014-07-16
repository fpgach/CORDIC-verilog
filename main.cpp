#include <stdio.h>

#include <iostream>
#include <fstream>
using namespace std;
#include <math.h>
#include <limits.h>
#include <stdlib.h>

const double PI = M_PI;
#define     N       14 //number steps
#define AMP_MSB     14
#define ARG_MSB     16
//#define ARG_N       65536 //how much 360 degrees in int

void calc_cordic(int& re, int& im, int module, int angle) {
    double d_angle[N];
    int i_angle[N];
    double sum_angles = .0f;
    for(int k = 0; k < N; k++) {
        d_angle[k] = atan(1.0/pow(2,k)) * (180/PI);
        sum_angles += d_angle[k];
        //printf("%f\n", d_angle[k]);
        i_angle[k] = d_angle[k]*(1 << ARG_MSB)/360.0f;
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


    //int quad = (angle & 0xC000 ) >> 14;
    //angle = angle & 0x3FFF;

    int quad = (angle & (3 << (ARG_MSB-2))) >> (ARG_MSB-2);
    angle = angle & ((1 << (ARG_MSB-2)) -1);

    int ARG[N];
    ARG[0] = i_angle[0];


    //printf("%f\t\t%d\t%d\t\n", ARG[0], Re[0], Im[0]);
    int tmp_i = 0;
    int tmp_Re = 0;
    int tmp_Im = 0;
    int tst = 0;
    int tst_re[N];
    int tst_im[N];
    for(int i = 1; i < N; i++) {
        if(i > 8)
            tmp_i = 1 << (i-1);
        else
            tmp_i = 0;

        if(ARG[i-1] > angle) {
            tmp_Im  =   Im[i-1] + tmp_i;
            tmp_Re  =   Re[i-1] + tmp_i;
            Re[i]   =   Re[i-1] + (tmp_Im >> i);
            Im[i]   =   Im[i-1] - (tmp_Re >> i);
            ARG[i]  =   ARG[i-1] - i_angle[i];
        }
        else {
            tmp_Im  =   Im[i-1] + tmp_i;
            tmp_Re  =   Re[i-1] + tmp_i;
            Re[i]   =   Re[i-1] - (tmp_Im >> i);
            Im[i]   =   Im[i-1] + (tmp_Re >> i);
            ARG[i]  =   ARG[i-1] + i_angle[i];
        }
        //printf("%d\t%d\t%d\t\t\t%d\t%d\n",i, Re[i], Im[i], ARG[i], angle);

    }

    double mcos = cos(angle*PI/180);
    double msin = sin(angle*PI/180);
    double r = sqrt(msin*msin + mcos*mcos);
    int icos = mcos*(module );
    int isin = msin*(module );

    int tmp;


    if(quad == 0) {
        re = Re[N-1];
        im = Im[N-1];
    }
    if(quad == 1) {
        re = -Im[N-1];
        im = Re[N-1];
    }
    if(quad == 2) {
        re = -Re[N-1];
        im = -Im[N-1];
    }
    if(quad == 3) {
        re = Im[N-1];
        im = -Re[N-1];
    }


    //static int max_delta_cos = tmp_cos > max_delta_cos ? tmp_cos : max_delta_cos;
    //static int max_delta_sin = tmp_sin > max_delta_sin ? tmp_sin : max_delta_sin;
    //printf("%d\t%d\t%d", ARG[N-1], re, im);
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
    double my_val = 0;
/*
    calc_cordic(Re, Im, 8191, 10260);
    double  my_angle = 10260*360.0/(1<<ARG_MSB);
    int     my_modul = 1 << (AMP_MSB-1);
    double mcos = cos(my_angle*PI/180);
    double msin = sin(my_angle*PI/180);

    int icos = mcos*(my_modul);
    int isin = msin*(my_modul);
    tmp_cos = Re - icos;
    tmp_sin = Im - isin;
    //max_arg = abs(tmp_cos) > abs(max_delta_re) ? i : max_arg;
    max_delta_re = abs(tmp_cos) > abs(max_delta_re) ? tmp_cos : max_delta_re;
    max_delta_im = abs(tmp_sin) > abs(max_delta_im) ? tmp_sin : max_delta_im;
*/

    for(int i = 0; i < (1<<ARG_MSB); i++) {
        double  my_angle = (double)i*360.0/(1<<ARG_MSB);
        int     my_modul = 1 << (AMP_MSB-1);
        calc_cordic(Re,Im, my_modul, i);

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
        max_arg = abs(tmp_cos) > abs(max_delta_re) ? i : max_arg;
        max_delta_re = abs(tmp_cos) > abs(max_delta_re) ? tmp_cos : max_delta_re;
        max_delta_im = abs(tmp_sin) > abs(max_delta_im) ? tmp_sin : max_delta_im;

        my_val += abs(tmp_cos);

        disp_cos += tmp_cos;
        disp_sin += tmp_sin;

    }

    my_val /= (1<<ARG_MSB);

    //printf("\n%d\t%d\n", icos, isin);
    printf("\n%d\t%d\n", max_delta_re, max_delta_im);
    printf("\n%d\t%d\t\t%d\n", disp_cos, disp_sin, max_arg);
    printf("%f\n", my_val);
    console.close();
    cos_delta_file.close();
    sin_delta_file.close();
    return 0;
}
