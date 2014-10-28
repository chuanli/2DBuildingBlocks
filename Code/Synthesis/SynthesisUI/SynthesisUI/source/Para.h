#ifndef PARA_H
#define PARA_H

#include <vector>
#include <QString>
#include <QObject>
#include <QDebug>
//#include "SenderObject.h"

using namespace std;

extern QString name_detection;
extern QString filename_imgInput;
extern QString filename_imgMask;
extern QString filename_offsetStatisticsPixelInput;
extern QString filename_offsetStatisticsPixelMWInput;
extern QString filename_offsetStatisticsBBInput;
extern QString filename_offsetStatisticsBBMWInput;
extern QString filename_offsetStatisticsInput;
extern QString filename_repInput;
extern QString filename_imgOutput;

extern bool flag_MW; // flag for Manhattan world flag. set true for facades
extern double scalerRes; // control the resolution of synthesis, balance the speed and quality
extern int method_now; // method control

const int SLOTSWITCHMETHOD = 0;
const int SLOTEXPANDX = 1;
const int SLOTSHRINKX = 2;
const int SLOTEXPANDY = 3;
const int SLOTSHRINKY = 4;

const int MODE_SHIFTMAP = 1;
const int MODE_OFFSETSTATISTICS = 2;
const int MODE_BB = 3;
const int MODE_NONELOCAL = 4;

#endif