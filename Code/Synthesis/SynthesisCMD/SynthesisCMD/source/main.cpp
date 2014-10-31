#include "Para.h"
#include "Synthesizer.h"
#include <QDebug>

int main(int argc, char *argv[])
{
	// parsing input
	name_inputpath.append(argv[1]);
	name_imgInput.append(argv[2]);
	name_imgInputformat.append(argv[3]);
	mode_method = atof(argv[4]);
	mode_sampling = atof(argv[5]);
	name_detection.append(argv[6]);
	cmd_totalGeneratorX_scaled = atof(argv[7]);
	cmd_totalGeneratorY_scaled = atof(argv[8]);
	scalerRes = atof(argv[9]);

	qDebug() << "filename_inputpath: " << name_inputpath;
	qDebug() << "name_imgInput: " << name_imgInput;
	qDebug() << "name_imgInputformat: " << name_imgInputformat;
	qDebug() << "mode_method: " << mode_method;
	qDebug() << "mode_sampling: " << mode_sampling;
	qDebug() << "name_detection: " << name_detection;
	qDebug() << "totalGeneratorX_scaled: " << cmd_totalGeneratorX_scaled;
	qDebug() << "totalGeneratorY_scaled: " << cmd_totalGeneratorY_scaled;
	qDebug() << "scalerRes: " << scalerRes;

	// filenames
	filename_imgInput.append(name_inputpath);
	filename_imgInput.append(name_imgInput);
	filename_imgInput.append(name_imgInputformat);
	filename_offsetStatisticsPixelInput.append(name_inputpath);
	filename_offsetStatisticsPixelInput.append(name_imgInput);
	filename_offsetStatisticsPixelInput.append("OffsetStatisticsPixel.txt");
	filename_offsetStatisticsPixelMWInput.append(name_inputpath);
	filename_offsetStatisticsPixelMWInput.append(name_imgInput);
	filename_offsetStatisticsPixelMWInput.append("OffsetStatisticsPixelMW.txt");
	filename_offsetStatisticsBBInput.append(name_inputpath);
	filename_offsetStatisticsBBInput.append(name_imgInput);
	filename_offsetStatisticsBBInput.append("OffsetStatistics");
	filename_offsetStatisticsBBInput.append(name_detection);
	filename_offsetStatisticsBBInput.append(".txt");
	filename_offsetStatisticsBBMWInput.append(name_inputpath);
	filename_offsetStatisticsBBMWInput.append(name_imgInput);
	filename_offsetStatisticsBBMWInput.append("OffsetStatistics");
	filename_offsetStatisticsBBMWInput.append(name_detection);
	filename_offsetStatisticsBBMWInput.append("MW");
	filename_offsetStatisticsBBMWInput.append(".txt");

	filename_repInput.append(name_inputpath);
	filename_repInput.append(name_imgInput);
	filename_repInput.append(name_detection);
	filename_repInput.append(".txt");

	filename_imgOutput.append(name_inputpath);
	filename_imgOutput.resize(filename_imgOutput.size() - 6);
	filename_imgOutput.append("output\\");
	filename_imgOutput.append(name_imgInput);
	filename_imgOutput.append("_syn_");
	filename_imgOutput.append(QString::number(cmd_totalGeneratorX_scaled));
	filename_imgOutput.append("_");
	filename_imgOutput.append(QString::number(cmd_totalGeneratorY_scaled));
	filename_imgOutput.append("_");
	filename_imgOutput.append(QString::number(mode_method));
	filename_imgOutput.append("_");
	filename_imgOutput.append(QString::number(mode_sampling));
	filename_imgOutput.append("_");
	filename_imgOutput.append(name_detection);
	filename_imgOutput.append(name_imgInputformat);

	filename_imgBBOutput.append(name_inputpath);
	filename_imgBBOutput.resize(filename_imgBBOutput.size() - 6);
	filename_imgBBOutput.append("output\\");
	filename_imgBBOutput.append(name_imgInput);
	filename_imgBBOutput.append("_synBB_");
	filename_imgBBOutput.append(QString::number(cmd_totalGeneratorX_scaled));
	filename_imgBBOutput.append("_");
	filename_imgBBOutput.append(QString::number(cmd_totalGeneratorY_scaled));
	filename_imgBBOutput.append("_");
	filename_imgBBOutput.append(QString::number(mode_method));
	filename_imgBBOutput.append("_");
	filename_imgBBOutput.append(QString::number(mode_sampling));
	filename_imgBBOutput.append("_");
	filename_imgBBOutput.append(name_detection);
	filename_imgBBOutput.append(name_imgInputformat);

	switch (mode_sampling){
	case 1:
		filename_offsetStatisticsInput = ""; // regular sampling
		break;
	case 2:
		filename_offsetStatisticsInput = filename_offsetStatisticsPixelInput; // sampling using pixel statistics
		break;
	case 3:
		filename_offsetStatisticsInput = filename_offsetStatisticsPixelMWInput; // sampling using MW pixel statistics 
		break;
	case 4:
		filename_offsetStatisticsInput = filename_offsetStatisticsBBInput; // sampling using BB statistics 
		break;
	case 5:
		filename_offsetStatisticsInput = filename_offsetStatisticsBBMWInput; // sampling using MW BB statistics 
		break;
	default:
		break;
	}
	qDebug() << "filename_imgInput: " << filename_imgInput;
	qDebug() << "filename_offsetStatisticsPixelInput: " << filename_offsetStatisticsPixelInput;
	qDebug() << "filename_offsetStatisticsPixelMWInput: " << filename_offsetStatisticsPixelMWInput;
	qDebug() << "filename_offsetStatisticsBBInput: " << filename_offsetStatisticsBBInput;
	qDebug() << "filename_offsetStatisticsBBMWInput: " << filename_offsetStatisticsBBMWInput;
	qDebug() << "filename_offsetStatisticsInput: " << filename_offsetStatisticsInput;
	qDebug() << "filename_repInput: " << filename_repInput;
	qDebug() << "filename_imgOutput: " << filename_imgOutput;
	qDebug() << "filename_imgBBOutput: " << filename_imgBBOutput;

	// initialization
	Synthesizer* syn = new Synthesizer;
	syn->initialization();

	switch (mode_method){
	case 1:
		syn->synthesis_ShiftMap();
		break;
	case 2:
		syn->synthesis_OffsetStatistics();
		break;
	case 3:
		syn->synthesis_BB();
		break;
	default:
		;
		break;
	}

}