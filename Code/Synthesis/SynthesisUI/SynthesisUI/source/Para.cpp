#include "Para.h"

//QString filename_imgInput = "C:/Chuan/data/2DBuildingBlocks/NonFacade/Syn/Input/NonFacade(0).jpg";
//QString filename_offsetStatisticsInput = "C:/Chuan/data/2DBuildingBlocks/NonFacade/Syn/Input/NonFacade(0)OffsetStatisticsPixel.txt";
//QString filename_repInput = "....";

QString append_BB = "GT";
QString filename_imgInput = "C:/Chuan/data/2DBuildingBlocks/Facade/Syn/Input/Facade(1).jpg";
QString filename_imgMask = "C:/Chuan/data/2DBuildingBlocks/NonFacade/Syn/Input/Facade(1)_mask.bmp";
QString filename_offsetStatisticsPixelInput = "C:/Chuan/data/2DBuildingBlocks/Facade/Syn/Input/Facade(1)OffsetStatisticsPixel.txt";
QString filename_offsetStatisticsBBInput = "C:/Chuan/data/2DBuildingBlocks/Facade/Syn/Input/Facade(1)OffsetStatistics" + append_BB + ".txt";
QString filename_offsetStatisticsInput = "";
QString filename_repInput = "C:/Chuan/data/2DBuildingBlocks/Facade/Syn/Input/Facade(1)" + append_BB + ".txt";
QString filename_imgOutput = "";


//QString filename_imgInput = "C:/Chuan/data/2DBuildingBlocks/ShiftMap/Syn/Input/ShiftMap(9).jpg";
//QString filename_offsetStatisticsInput = "C:/Chuan/data/2DBuildingBlocks/ShiftMap/Syn/Input/ShiftMap(9)OffsetStatisticsPixel.txt";
//QString filename_repInput = "....";

//QString filename_imgInput = "C:/Chuan/data/2DBuildingBlocks/OffsetStatistics/Syn/Input/OffsetStatistics(0).jpg";
//QString filename_offsetStatisticsInput = "C:/Chuan/data/2DBuildingBlocks/OffsetStatistics/Syn/Input/OffsetStatistics(0)OffsetStatisticsPixel.txt";
//QString filename_repInput = "....";

double scalerRes = 0.25; // control the resolution of synthesis, balance the speed and quality
int method_now = 1;