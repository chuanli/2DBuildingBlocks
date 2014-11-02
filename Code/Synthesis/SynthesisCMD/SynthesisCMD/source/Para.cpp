#include "Para.h"

// command input
QString name_inputpath = "";
QString name_imgInput = "";
QString name_imgInputformat = "";
QString name_imgOutputformat = ".png";
int mode_method = 0;
int mode_sampling = 0;
QString name_detection = "";
double cmd_totalGeneratorX_scaled = 1;
double cmd_totalGeneratorY_scaled = 1;

// filenames
QString filename_imgInput = "";
QString filename_offsetStatisticsPixelInput = "";
QString filename_offsetStatisticsPixelMWInput = "";
QString filename_offsetStatisticsBBInput = "";
QString filename_offsetStatisticsBBMWInput = "";
QString filename_offsetStatisticsInput = "";
QString append_BB = "";
QString filename_repInput = "";
QString filename_imgOutput = "";
QString filename_imgBBOutput = "";

double scalerRes = 0.25; // control the resolution of synthesis, balance the speed and quality
//int method_now = 1;