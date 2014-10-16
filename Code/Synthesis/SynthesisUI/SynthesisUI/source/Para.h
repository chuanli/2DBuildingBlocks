#ifndef PARA_H
#define PARA_H

#include <vector>
#include <QString>
#include <QObject>
#include <QDebug>
//#include "SenderObject.h"

using namespace std;

extern QString filename_imgInput;
extern QString filename_repInput;

extern double scalerRes; // control the resolution of synthesis, balance the speed and quality





//extern  int cost_data_inf;
//extern  int cost_smooth_inf;
//extern  int cost_smooth_label;
//extern  int cost_data_guide_inf;
//extern  float cost_smooth_pixel_scaler;
//extern  float cost_data_pixel_scaler;
//
//extern  int max_iter_rec;
//
//
////extern SenderObject* globalsender;
//
//extern bool flag_multiselection;
//
//extern bool flag_sideselection;
//
//extern int sel_bb_type;
//
//extern int sel_bb_idx;
//
//extern int global_rowsSyn_scaled;
//extern int global_colsSyn_scaled;
//extern int global_rowsInput_scaled;
//extern int global_colsInput_scaled;
//
//extern int global_rowsSyn_fullres;
//extern int global_colsSyn_fullres;
//extern int global_rowsInput_fullres;
//extern int global_colsInput_fullres;
//
//extern double global_cover_in_thresh;
//extern double global_cover_out_thresh;
//
//extern bool flag_syn_Y;
//extern int step_reconfig;
//
//extern int num_iter_autostitch;
//
//extern double scalerPaintX;
//extern double scalerPaintY;
//
//
//extern bool flag_scribble;

const int SLOTEXPANDX = 0;
const int SLOTSHRINKX = 1;
const int SLOTEXPANDY = 2;
const int SLOTSHRINKY = 3;

#endif