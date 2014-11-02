#ifndef PARA_H
#define PARA_H

#include <vector>
#include <QString>
#include <QObject>
#include <QDebug>

using namespace std;

// command input
extern QString name_inputpath;
extern QString name_imgInput;
extern QString name_imgInputformat;
extern QString name_imgOutputformat;
extern int mode_method;
extern int mode_sampling;
extern QString name_detection;
extern double cmd_totalGeneratorX_scaled;
extern double cmd_totalGeneratorY_scaled;

// filenames
extern QString filename_imgInput;
extern QString filename_offsetStatisticsPixelInput;
extern QString filename_offsetStatisticsPixelMWInput;
extern QString filename_offsetStatisticsBBInput;
extern QString filename_offsetStatisticsBBMWInput;
extern QString filename_offsetStatisticsInput;
extern QString append_BB;
extern QString filename_repInput;
extern QString filename_imgOutput;
extern QString filename_imgBBOutput;


extern double scalerRes; // control the resolution of synthesis, balance the speed and quality

//const int SLOTSWITCHMETHOD = 0;
//const int SLOTEXPANDX = 1;
//const int SLOTSHRINKX = 2;
//const int SLOTEXPANDY = 3;
//const int SLOTSHRINKY = 4;
//
//const int MODE_SHIFTMAP = 1;
//const int MODE_OFFSETSTATISTICS = 2;
//const int MODE_BB = 3;
//const int MODE_NONELOCAL = 4;

#endif