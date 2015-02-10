#include "Para.h"

QString name_detection = "Detection";
QString filename_imgInput = "C:/Chuan/data/2DBuildingBlocks/NonFacade/Syn/Input/NonFacade(1).jpg";
QString filename_imgMask = "C:/Chuan/data/2DBuildingBlocks/NonFacade/Syn/Input/NonFacade(1)_mask.bmp";
QString filename_offsetStatisticsPixelInput = "C:/Chuan/data/2DBuildingBlocks/NonFacade/Syn/Input/NonFacade(1)OffsetStatisticsPixel.txt";
QString filename_offsetStatisticsPixelMWInput = "C:/Chuan/data/2DBuildingBlocks/NonFacade/Syn/Input/NonFacade(1)OffsetStatisticsPixelMW.txt";
QString filename_offsetStatisticsBBInput = "C:/Chuan/data/2DBuildingBlocks/NonFacade/Syn/Input/NonFacade(1)OffsetStatistics" + name_detection + ".txt";
QString filename_offsetStatisticsBBMWInput = "C:/Chuan/data/2DBuildingBlocks/NonFacade/Syn/Input/NonFacade(1)OffsetStatistics" + name_detection + "MW.txt";
QString filename_offsetStatisticsInput = "";
QString filename_repInput = "C:/Chuan/data/2DBuildingBlocks/NonFacade/Syn/Input/NonFacade(1)" + name_detection + ".txt";
QString filename_imgOutput = "";

bool flag_MW = true;
double scalerRes = 0.25; // control the resolution of synthesis, balance the speed and quality
int method_now = 1;
