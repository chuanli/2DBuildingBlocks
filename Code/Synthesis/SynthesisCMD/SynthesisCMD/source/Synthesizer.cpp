#include "Synthesizer.h"
#include <QDebug>


int Synthesizer::rowsInput_scaled;
int Synthesizer::colsInput_scaled;
int Synthesizer::rowsSyn_scaled;
int Synthesizer::colsSyn_scaled;

vector<Point2i*> Synthesizer::list_shiftXY_scaled;
vector<Point2i*> Synthesizer::gcoNodes;
Mat1b Synthesizer::imgInputGray_scaled;
Mat1b Synthesizer::imgInputlabel_scaled;
Mat1d Synthesizer::imgInputlabelinterX_scaled;
Mat1d Synthesizer::imgInputlabelinterY_scaled;
Mat1d Synthesizer::imgInputoffsetinterX_scaled;
Mat1d Synthesizer::imgInputoffsetinterY_scaled;
Mat1d Synthesizer::imgInputMask_scaled;
int Synthesizer::numRep;
std::vector<std::vector<int>> Synthesizer::repX_scaled;
std::vector<std::vector<int>> Synthesizer::repY_scaled;
std::vector<std::vector<Point2i*>> Synthesizer::repOffset_scaled;

int Synthesizer::weight_pixel;
int Synthesizer::weight_label;
int Synthesizer::weight_labelinter;

static void meshgrid(const cv::Mat &xgv, const cv::Mat &ygv, cv::Mat1d &X, cv::Mat1d &Y)
{
	cv::repeat(xgv.reshape(1, 1), ygv.total(), 1, X);
	cv::repeat(ygv.reshape(1, 1).t(), 1, xgv.total(), Y);
}

static void meshgridTest(const cv::Range &xgv, const cv::Range &ygv, cv::Mat1d &X, cv::Mat1d &Y)
{
	std::vector<double> t_x, t_y;
	for (int i = xgv.start; i <= xgv.end; i++) t_x.push_back((double)i);
	for (int i = ygv.start; i <= ygv.end; i++) t_y.push_back((double)i);
	meshgrid(cv::Mat(t_x), cv::Mat(t_y), X, Y);
}

// helper functions
inline vector<double> makeVector3f(float x, float y, float z) {
	vector<double> v;
	v.resize(3);
	v[0] = x; v[1] = y; v[2] = z;
	return v;
}

Synthesizer::Synthesizer(void){
	// input 
	qimgInput_fullres = new QImage;
    qimgInput_scaled = new QImage;

	// input label (detection or ground truth)
	qimgInputlabel_fullres = new QImage;
	qimgInputlabel_scaled = new QImage;

	// user guide
	qimgUserGuide_fullres = new QImage;
	qimgUserGuide_scaled = new QImage;

	// synthesis
	qimgSyn_fullres = new QImage;
	qimgSyn_scaled = new QImage;
	qimgSynlabelColor_fullres = new QImage;
	qimgInputlabelinterX_fullres = new QImage;
	qimgInputlabelinterX_scaled = new QImage;
	qimgInputlabelinterY_fullres = new QImage;
	qimgInputlabelinterY_scaled = new QImage;

	// hole filling
	qimgInputMask_fullres = new QImage;
	qimgInputMask_scaled = new QImage;

	// generators
	generatorX_scaled = 0.2; // a regular generator for expansion in X direction, in percentage
	generatorY_scaled = 0.2; // a regular generator for expansion in Y direction, in percentage
	totalGeneratorX_scaled = cmd_totalGeneratorX_scaled; // the total expansion in X direction, in percentage
	totalGeneratorY_scaled = cmd_totalGeneratorY_scaled; // the total expansion in Y direction, in percentage
	shiftsPerGenerator_scaled = 8; // a regular generator for expansion, in the resolution of shifts
	totalShiftsX_scaled = 1; // the total number of shifts in X direction 
	totalShiftsY_scaled = 1; // the total number of shifts in Y direction

	// none local
	r_Nonelocal_scaled = 8;
	r_Nonelocal_fullres = (int)(r_Nonelocal_scaled / scalerRes);

	// rendering
	colorList.resize(10);
	colorList[0] = makeVector3f(102.0, 153.0, 255.0);
	colorList[1] = makeVector3f(255.0, 204.0, 102.0);
	colorList[2] = makeVector3f(102.0, 255.0, 127.0);
	colorList[3] = makeVector3f(255.0, 127.0, 102.0);
	colorList[4] = makeVector3f(102.0, 230.0, 255.0);
	colorList[5] = makeVector3f(41.0, 112.0, 255.0);
	colorList[6] = makeVector3f(255.0, 184.0, 41.0);
	colorList[7] = makeVector3f(235.0, 156.0, 0.0);
	colorList[8] = makeVector3f(0.0, 78.0, 235.0);
	colorList[9] = makeVector3f(255.0, 102.0, 230.0);
	// gco
	weight_pixel = 1;
	weight_label = 10;
	weight_labelinter = 2;

	// 
	numGeneratorsOS = 0;
}

Synthesizer::~Synthesizer(void)
{
}

Mat Synthesizer::qimage2mat(const QImage& qimage){
	cv::Mat mat = cv::Mat(qimage.height(), qimage.width(), CV_8UC4, (uchar*)qimage.bits(), qimage.bytesPerLine());
	cv::Mat mat2 = cv::Mat(mat.rows, mat.cols, CV_8UC3);
	int from_to[] = { 0, 0, 1, 1, 2, 2 };
	cv::mixChannels(&mat, 1, &mat2, 1, from_to, 3);
	return mat2;
};

QImage Mat2QImage(const cv::Mat3b &src) {
	QImage dest(src.cols, src.rows, QImage::Format_ARGB32);
	for (int y = 0; y < src.rows; ++y) {
		const cv::Vec3b *srcrow = src[y];
		QRgb *destrow = (QRgb*)dest.scanLine(y);
		for (int x = 0; x < src.cols; ++x) {

			destrow[x] = qRgba(srcrow[x][2], srcrow[x][1], srcrow[x][0], 255);
		}
	}
	return dest;
}

void Synthesizer::initialization(){

	//----------------------------------------------------------------
	// initialize images
	//----------------------------------------------------------------
	qimgInput_fullres->load(filename_imgInput);
    *qimgInput_scaled = qimgInput_fullres->scaled(qimgInput_fullres->size() * scalerRes, Qt::KeepAspectRatio, Qt::SmoothTransformation);

	// matrix for (fullres and scaled) grayscale input image
	imgInput_fullres = qimage2mat(*qimgInput_fullres);
	cvtColor(imgInput_fullres, imgInputGray_fullres, CV_BGR2GRAY);
	imgInput_scaled = qimage2mat(*qimgInput_scaled);
	cvtColor(imgInput_scaled, imgInputGray_scaled, CV_BGR2GRAY);
	rowsInput_fullres = qimgInput_fullres->height();
	colsInput_fullres = qimgInput_fullres->width();
	rowsInput_scaled = qimgInput_scaled->height();
	colsInput_scaled = qimgInput_scaled->width();
	
	//----------------------------------------------------------------
	// initialize offset statistics generators
	//----------------------------------------------------------------
	QFile fileOS(filename_offsetStatisticsInput);
	if (fileOS.open(QIODevice::ReadOnly)){
		QTextStream in(&fileOS);
		in >> numGeneratorsOS;
		generatorsOS_fullres.resize(numGeneratorsOS);
		for (int i_g = 0; i_g < numGeneratorsOS; i_g++){
			generatorsOS_fullres[i_g] = new Point2i(0, 0);
			in >> generatorsOS_fullres[i_g]->x;
			in >> generatorsOS_fullres[i_g]->y;
		}
		generatorsOS_scaled.resize(numGeneratorsOS);
		for (int i_g = 0; i_g < numGeneratorsOS; i_g++){
			generatorsOS_scaled[i_g] = new Point2i((int)round(generatorsOS_fullres[i_g]->x * scalerRes), (int)round(generatorsOS_fullres[i_g]->y * scalerRes));
		}
	}

	for (int i_g = 0; i_g < numGeneratorsOS; i_g++){
		qDebug() << generatorsOS_scaled[i_g]->x << ", " << generatorsOS_scaled[i_g]->y;
	}

	//----------------------------------------------------------------
	// initialize repetitions
	//----------------------------------------------------------------
	numRep = 0;
	QFile fileRep(filename_repInput);
	if (fileRep.open(QIODevice::ReadOnly)){
		QTextStream in(&fileRep);
		in >> numRep;
		sizeRep.resize(numRep);
		for (int i_rep = 0; i_rep < numRep; i_rep++){
			in >> sizeRep[i_rep];
		}
		repX_fullres.resize(numRep);
		repY_fullres.resize(numRep);
		repW_fullres.resize(numRep);
		repH_fullres.resize(numRep);
		for (int i_rep = 0; i_rep < numRep; i_rep++){
			repX_fullres[i_rep].resize(sizeRep[i_rep]);
			repY_fullres[i_rep].resize(sizeRep[i_rep]);
			repW_fullres[i_rep].resize(sizeRep[i_rep]);
			repH_fullres[i_rep].resize(sizeRep[i_rep]);
			for (int j_rep = 0; j_rep < sizeRep[i_rep]; j_rep++){
				in >> repX_fullres[i_rep][j_rep];
				in >> repY_fullres[i_rep][j_rep];
				in >> repW_fullres[i_rep][j_rep];
				in >> repH_fullres[i_rep][j_rep];
			}
		}
	}

	// make sure the labels are inside of the image
	for (int i_rep = 0; i_rep < numRep; i_rep++){
		for (int j_rep = 0; j_rep < sizeRep[i_rep]; j_rep++){
			repX_fullres[i_rep][j_rep] = std::max<int>(0, std::min<int>(repX_fullres[i_rep][j_rep], colsInput_fullres - 1));
			repY_fullres[i_rep][j_rep] = std::max<int>(0, std::min<int>(repY_fullres[i_rep][j_rep], rowsInput_fullres - 1));
			repW_fullres[i_rep][j_rep] = std::max<int>(1, std::min<int>((repX_fullres[i_rep][j_rep] + repW_fullres[i_rep][j_rep]) - repX_fullres[i_rep][j_rep], colsInput_fullres - 1 - repX_fullres[i_rep][j_rep]));
			repH_fullres[i_rep][j_rep] = std::max<int>(1, std::min<int>((repY_fullres[i_rep][j_rep] + repH_fullres[i_rep][j_rep]) - repY_fullres[i_rep][j_rep], rowsInput_fullres - 1 - repY_fullres[i_rep][j_rep]));
		}
	}

	// scale the input labels
	repX_scaled.resize(numRep);
	repY_scaled.resize(numRep);
	repW_scaled.resize(numRep);
	repH_scaled.resize(numRep);
	for (int i_rep = 0; i_rep < numRep; i_rep++){
		repX_scaled[i_rep].resize(sizeRep[i_rep]);
		repY_scaled[i_rep].resize(sizeRep[i_rep]);
		repW_scaled[i_rep].resize(sizeRep[i_rep]);
		repH_scaled[i_rep].resize(sizeRep[i_rep]);
		for (int j_rep = 0; j_rep < sizeRep[i_rep]; j_rep++){
			// scale and make sure the box does not exceed image boundary
			repX_scaled[i_rep][j_rep] = std::min<int>((int)round(repX_fullres[i_rep][j_rep] * scalerRes), colsInput_scaled - 1);
			repY_scaled[i_rep][j_rep] = std::min<int>((int)round(repY_fullres[i_rep][j_rep] * scalerRes), rowsInput_scaled - 1);
			repW_scaled[i_rep][j_rep] = std::max<int>(1, std::min<int>((int)round((repX_fullres[i_rep][j_rep] + repW_fullres[i_rep][j_rep]) * scalerRes) - repX_scaled[i_rep][j_rep], colsInput_scaled - 1 - repX_scaled[i_rep][j_rep]));
			repH_scaled[i_rep][j_rep] = std::max<int>(1, std::min<int>((int)round((repY_fullres[i_rep][j_rep] + repH_fullres[i_rep][j_rep]) * scalerRes) - repY_scaled[i_rep][j_rep], rowsInput_scaled - 1 - repY_scaled[i_rep][j_rep]));
		}
	}

	// compute the offset between all building blocks. this is used for none local method
	repOffset_scaled.resize(numRep * numRep);
	for (int i_rep = 0; i_rep < numRep; i_rep++){
		for (int j_rep = 0; j_rep < numRep; j_rep++){
			int idx = i_rep * numRep + j_rep;
			repOffset_scaled[idx].resize(0);
			for (int ii_rep = 0; ii_rep < (int)repX_scaled[i_rep].size(); ii_rep++){
				for (int jj_rep = 0; jj_rep < (int)repX_scaled[j_rep].size(); jj_rep++){
					Point2i cur_offset(repX_scaled[i_rep][ii_rep] - repX_scaled[j_rep][jj_rep], repY_scaled[i_rep][ii_rep] - repY_scaled[j_rep][jj_rep]);
					bool flag_found = false;
					for (int k = 0; k < (int)repOffset_scaled[idx].size(); k++){
						if (cur_offset.x == repOffset_scaled[idx][k]->x && cur_offset.y == repOffset_scaled[idx][k]->y){
							flag_found = true;
							break;
						}
			        }
					if (!flag_found){
						repOffset_scaled[idx].push_back(new Point2i(cur_offset.x, cur_offset.y));
					}
				}
			}
		}
	}

	// make fullres & scaled maps for input labels
	imgInputlabel_fullres = Mat1b::zeros(rowsInput_fullres, colsInput_fullres); //or, rep->imgSynGray_scaled.create(rows, cols);
	for (int i_rep = 0; i_rep < numRep; i_rep++){
		for (int j_rep = 0; j_rep < sizeRep[i_rep]; j_rep++){
			imgInputlabel_fullres(Range(repY_fullres[i_rep][j_rep], repY_fullres[i_rep][j_rep] + repH_fullres[i_rep][j_rep]), Range(repX_fullres[i_rep][j_rep], repX_fullres[i_rep][j_rep] + repW_fullres[i_rep][j_rep])) = (i_rep + 1);
		}
	}

	imgInputlabel_scaled = Mat1b::zeros(rowsInput_scaled, colsInput_scaled);
	for (int i_rep = 0; i_rep < numRep; i_rep++){
		for (int j_rep = 0; j_rep < sizeRep[i_rep]; j_rep++){
			imgInputlabel_scaled(Range(repY_scaled[i_rep][j_rep], repY_scaled[i_rep][j_rep] + repH_scaled[i_rep][j_rep]), Range(repX_scaled[i_rep][j_rep], repX_scaled[i_rep][j_rep] + repW_scaled[i_rep][j_rep])) = (i_rep + 1);
		}
	}

	//----------------------------------------------------------------
	// initialize internal label
	//----------------------------------------------------------------
	imgInputlabelinterX_scaled = Mat1d::zeros(rowsInput_scaled, colsInput_scaled);
	imgInputlabelinterY_scaled = Mat1d::zeros(rowsInput_scaled, colsInput_scaled);
	imgInputoffsetinterX_scaled = Mat1b::zeros(rowsInput_scaled, colsInput_scaled);
	imgInputoffsetinterY_scaled = Mat1b::zeros(rowsInput_scaled, colsInput_scaled);

	for (int i_rep = 0; i_rep < numRep; i_rep++){
		//for (int j_rep = 0; j_rep < sizeRep[i_rep]; j_rep++){
		for (int j_rep = 0; j_rep < 2; j_rep++){
			cv::Mat1d X, Y, XX, YY;
			meshgridTest(cv::Range(0, repW_scaled[i_rep][j_rep] - 1), cv::Range(0, repH_scaled[i_rep][j_rep] - 1), XX, YY);
			X = XX * ((double)1 / (double)max(1, repW_scaled[i_rep][j_rep]));
			Y = YY * ((double)1 / (double)max(1, repH_scaled[i_rep][j_rep]));
			X.copyTo(imgInputlabelinterX_scaled(Range(repY_scaled[i_rep][j_rep], repY_scaled[i_rep][j_rep] + repH_scaled[i_rep][j_rep]), Range(repX_scaled[i_rep][j_rep], repX_scaled[i_rep][j_rep] + repW_scaled[i_rep][j_rep])));
			Y.copyTo(imgInputlabelinterY_scaled(Range(repY_scaled[i_rep][j_rep], repY_scaled[i_rep][j_rep] + repH_scaled[i_rep][j_rep]), Range(repX_scaled[i_rep][j_rep], repX_scaled[i_rep][j_rep] + repW_scaled[i_rep][j_rep])));
			XX.copyTo(imgInputoffsetinterX_scaled(Range(repY_scaled[i_rep][j_rep], repY_scaled[i_rep][j_rep] + repH_scaled[i_rep][j_rep]), Range(repX_scaled[i_rep][j_rep], repX_scaled[i_rep][j_rep] + repW_scaled[i_rep][j_rep])));
			YY.copyTo(imgInputoffsetinterY_scaled(Range(repY_scaled[i_rep][j_rep], repY_scaled[i_rep][j_rep] + repH_scaled[i_rep][j_rep]), Range(repX_scaled[i_rep][j_rep], repX_scaled[i_rep][j_rep] + repW_scaled[i_rep][j_rep])));
		}
	}


	// make maps for rep internal labels
	imgInputlabelinterX_fullres = Mat1d::zeros(rowsInput_fullres, colsInput_fullres);
	imgInputlabelinterY_fullres = Mat1d::zeros(rowsInput_fullres, colsInput_fullres);
	for (int i_rep = 0; i_rep < numRep; i_rep++){
		for (int j_rep = 0; j_rep < sizeRep[i_rep]; j_rep++){
			cv::Mat1d X, Y;
			meshgridTest(cv::Range(0, repW_fullres[i_rep][j_rep] - 1), cv::Range(0, repH_fullres[i_rep][j_rep] - 1), X, Y);
			X = X * ((double)1 / (double)max(1, repW_fullres[i_rep][j_rep]));
			Y = Y * ((double)1 / (double)max(1, repH_fullres[i_rep][j_rep]));
			X.copyTo(imgInputlabelinterX_fullres(Range(repY_fullres[i_rep][j_rep], repY_fullres[i_rep][j_rep] + repH_fullres[i_rep][j_rep]), Range(repX_fullres[i_rep][j_rep], repX_fullres[i_rep][j_rep] + repW_fullres[i_rep][j_rep])));
			Y.copyTo(imgInputlabelinterY_fullres(Range(repY_fullres[i_rep][j_rep], repY_fullres[i_rep][j_rep] + repH_fullres[i_rep][j_rep]), Range(repX_fullres[i_rep][j_rep], repX_fullres[i_rep][j_rep] + repW_fullres[i_rep][j_rep])));
		}
	}

}

// Shift Map
void Synthesizer::synthesis_ShiftMap(){
	qDebug() << "Synthesis starts (Shift Map) ... ";

	// Prepare shifts
	prepareShifts_ShiftMap();

	// setup graph cut problem
	gcGrid = new GCoptimizationGridGraph(colsSyn_scaled, rowsSyn_scaled, totalShiftsXY_scaled);

	// set unary cost
	gcGrid->setDataCost(&unary_ShiftMap);

	// set smoothness cost
	gcGrid->setSmoothCost(&smooth_ShiftMap);

	// optimize
	qDebug() << "Before optimization energy is " << gcGrid->compute_energy();
	for (int i = 0; i < 2; i++){
		gcGrid->expansion(1);// run expansion for 2 iterations. For swap use gc->swap(num_iterations);
		qDebug() << "after expansion energy is " << gcGrid->compute_energy();
		gcGrid->swap(1);// run expansion for 2 iterations. For swap use gc->swap(num_iterations);
		qDebug() << "after swap energy is " << gcGrid->compute_energy();
	}
	// prepare results
	label2result();
}

void Synthesizer::prepareShifts_ShiftMap(){
	qDebug() << "Prepare shifts ...";
	// compute the dimension of the synthesis image
	totalShiftsX_scaled = (totalGeneratorX_scaled - 1) / (generatorX_scaled / (double)shiftsPerGenerator_scaled) + 1;
	totalShiftsY_scaled = (totalGeneratorY_scaled - 1) / (generatorY_scaled / (double)shiftsPerGenerator_scaled) + 1;
	totalShiftsXY_scaled = totalShiftsX_scaled * totalShiftsY_scaled;
	colsPerShiftX_scaled = (int)round((colsInput_scaled * generatorX_scaled) / (shiftsPerGenerator_scaled));
	colsSyn_scaled = colsInput_scaled + (totalShiftsX_scaled - 1) * colsPerShiftX_scaled;
	rowsPerShiftY_scaled = (int)round((rowsInput_scaled * generatorY_scaled) / (shiftsPerGenerator_scaled));
	rowsSyn_scaled = rowsInput_scaled + (totalShiftsY_scaled - 1) * rowsPerShiftY_scaled;
	numPixelSyn_scaled = colsSyn_scaled * rowsSyn_scaled;
	imgSynGray_scaled = Mat1b::zeros(rowsSyn_scaled, colsSyn_scaled);
	gcolabelSyn_scaled = Mat1i::zeros(rowsSyn_scaled, colsSyn_scaled);
	// compute candidate shifts
	list_shiftX_scaled.resize(totalShiftsX_scaled);
	for (int i_s = 0; i_s < totalShiftsX_scaled; i_s++){
		list_shiftX_scaled[i_s] = i_s * colsPerShiftX_scaled;
	}
	list_shiftY_scaled.resize(totalShiftsY_scaled);
	for (int i_s = 0; i_s < totalShiftsY_scaled; i_s++){
		list_shiftY_scaled[i_s] = i_s * rowsPerShiftY_scaled;
	}
	vector<Point2i*>().swap(list_shiftXY_scaled);
	list_shiftXY_scaled.resize(totalShiftsXY_scaled);
	for (int y = 0; y < totalShiftsY_scaled; y++){
		for (int x = 0; x < totalShiftsX_scaled; x++){
			list_shiftXY_scaled[y * totalShiftsX_scaled + x] = new Point2i(x * colsPerShiftX_scaled, y * rowsPerShiftY_scaled);
		}
	}
	vector<Point2i*>().swap(gcoNodes);
	gcoNodes.resize(numPixelSyn_scaled);
	for (int y = 0; y < rowsSyn_scaled; y++){
		for (int x = 0; x < colsSyn_scaled; x++){
			gcoNodes[y * colsSyn_scaled + x] = new Point2i(x, y);
		}
	}

	qDebug() << "totalShiftsX: " << totalShiftsX_scaled << ", colsSyn_scaled: " << colsSyn_scaled << ", colsPerShiftX_scaled : " << colsPerShiftX_scaled;
	qDebug() << "totalShiftsY: " << totalShiftsY_scaled << ", rowsSyn_scaled: " << rowsSyn_scaled << ", rowsPerShiftY_scaled : " << rowsPerShiftY_scaled;
	//for (int i = 0; i < totalShiftsXY_scaled; i++){
	//	qDebug() << list_shiftXY_scaled[i]->x << ", " << list_shiftXY_scaled[i]->y;
	//}
}

int Synthesizer::unary_ShiftMap(int p, int l){
	
	// compute the unary cost of assigning list_shiftXY_scaled[i_l] to gcoNodes[i_n]
	int newX = -list_shiftXY_scaled[l]->x + gcoNodes[p]->x;
	int newY = -list_shiftXY_scaled[l]->y + gcoNodes[p]->y;
	if (isValid(newX, newY)){
		return 0;
	}
	else{
		return 1000;
	}
}

int Synthesizer::smooth_ShiftMap(int p1, int p2, int l1, int l2){
	int retMe = 0;
	if (l1 == l2){
		return 0;
	}

	Point2i x1_s_a = -*list_shiftXY_scaled[l1] + *gcoNodes[p1];
	Point2i x2_s_b = -*list_shiftXY_scaled[l2] + *gcoNodes[p2];
	if (isValid(x1_s_a.x, x1_s_a.y) && isValid(x2_s_b.x, x2_s_b.y))
	{
		Point2i x1_s_b = -*list_shiftXY_scaled[l2] + *gcoNodes[p1];
		Point2i x2_s_a = -*list_shiftXY_scaled[l1] + *gcoNodes[p2];
		if (isValid(x1_s_b.x, x1_s_b.y) && isValid(x2_s_a.x, x2_s_a.y)){
			int diff1 = imgInputGray_scaled(x1_s_a.y, x1_s_a.x) - imgInputGray_scaled(x1_s_b.y, x1_s_b.x);
			int diff2 = imgInputGray_scaled(x2_s_a.y, x2_s_a.x) - imgInputGray_scaled(x2_s_b.y, x2_s_b.x);
			double energypixel = sqrt(double(diff1*diff1)) + sqrt(double(diff2*diff2));
			retMe = (int)energypixel;
			return retMe;
		}
		else{
			return 1000;
		}
	}
	return 1000;
}

void Synthesizer::fill_ShiftMap(){

}

// Offset Statistics
void Synthesizer::synthesis_OffsetStatistics(){
	qDebug() << "Synthesis starts (Offset Statistics) ... ";

	// Prepare shifts
	switch (mode_sampling)
	{
	case 2:
		if (abs(generatorsOS_scaled[0]->x) == 0){
			prepareShifts_OffsetStatisticsMW();
		}
		else{
			prepareShifts_OffsetStatistics();
		}
		break;
	case 3:
		prepareShifts_OffsetStatisticsMW();
		break;
	default:
		break;
	}
	
	// setup graph cut problem
	//qDebug() << "colsSyn_scaled: " << colsSyn_scaled << ", rowsSyn_scaled: " << rowsSyn_scaled << ", totalShiftsXY_scaled: " << totalShiftsXY_scaled;
	gcGrid = new GCoptimizationGridGraph(colsSyn_scaled, rowsSyn_scaled, totalShiftsXY_scaled);

	// set unary cost
	gcGrid->setDataCost(&unary_OffsetStatistics);
	//gc->setDataCost(&unary_BB);

	// set smoothness cost
	gcGrid->setSmoothCost(&smooth_OffsetStatistics);
	//gc->setSmoothCost(&smooth_BB);

	// optimize
	qDebug() << "Before optimization energy is " << gcGrid->compute_energy();
	for (int i = 0; i < 2; i++){
		gcGrid->expansion(1);// run expansion for 2 iterations. For swap use gc->swap(num_iterations);
		qDebug() << "after expansion energy is " << gcGrid->compute_energy();
		gcGrid->swap(1);// run expansion for 2 iterations. For swap use gc->swap(num_iterations);
		qDebug() << "after swap energy is " << gcGrid->compute_energy();
	}
	qDebug() << "Smoothness; " << gcGrid->giveSmoothEnergy();

	// prepare results
	label2result();
}

void Synthesizer::prepareShifts_OffsetStatistics(){

	// compute the dimension of the synthesis image
	totalShiftsX_scaled = (totalGeneratorX_scaled - 1) / (generatorX_scaled / (double)shiftsPerGenerator_scaled) + 1;
	totalShiftsY_scaled = (totalGeneratorY_scaled - 1) / (generatorY_scaled / (double)shiftsPerGenerator_scaled) + 1;
	totalShiftsXY_scaled = totalShiftsX_scaled * totalShiftsY_scaled;
	colsPerShiftX_scaled = (int)round((colsInput_scaled * generatorX_scaled) / (shiftsPerGenerator_scaled));
	colsSyn_scaled = colsInput_scaled + (totalShiftsX_scaled - 1) * colsPerShiftX_scaled;
	rowsPerShiftY_scaled = (int)round((rowsInput_scaled * generatorY_scaled) / (shiftsPerGenerator_scaled));
	rowsSyn_scaled = rowsInput_scaled + (totalShiftsY_scaled - 1) * rowsPerShiftY_scaled;
	numPixelSyn_scaled = colsSyn_scaled * rowsSyn_scaled;
	imgSynGray_scaled = Mat1b::zeros(rowsSyn_scaled, colsSyn_scaled);
	gcolabelSyn_scaled = Mat1i::zeros(rowsSyn_scaled, colsSyn_scaled);

	//// find the generator zone (the expansion zone spanned by one generator at each corner)
	//std::vector<int> zone_expansion_x;
	//std::vector<int> zone_expansion_y;
	//std::vector<int> zone_generator_x;
	//std::vector<int> zone_generator_y;
	//zone_expansion_x.resize(4);
	//zone_expansion_y.resize(4);
	//zone_expansion_x[0] = 0;
	//zone_expansion_x[1] = colsSyn_scaled - colsInput_scaled;
	//zone_expansion_x[2] = colsSyn_scaled - colsInput_scaled;
	//zone_expansion_x[3] = 0;
	//zone_expansion_y[0] = 0;
	//zone_expansion_y[1] = rowsSyn_scaled - rowsInput_scaled;
	//zone_expansion_y[2] = 0;
	//zone_expansion_y[3] = rowsSyn_scaled - rowsInput_scaled;
	//zone_generator_x.resize(16);
	//zone_generator_y.resize(16);
	//for (int i = 0; i < 4; i++){
	//	zone_generator_x[i * 4] = zone_expansion_x[i] - generatorsOS_scaled[0]->x + generatorsOS_scaled[1]->x;
	//	zone_generator_x[i * 4 + 1] = zone_expansion_x[i] + generatorsOS_scaled[0]->x + generatorsOS_scaled[1]->x;
	//	zone_generator_x[i * 4 + 2] = zone_expansion_x[i] + generatorsOS_scaled[0]->x - generatorsOS_scaled[1]->x;
	//	zone_generator_x[i * 4 + 3] = zone_expansion_x[i] - generatorsOS_scaled[0]->x - generatorsOS_scaled[1]->x;
	//	zone_generator_y[i * 4] = zone_expansion_y[i] - generatorsOS_scaled[0]->y + generatorsOS_scaled[1]->y;
	//	zone_generator_y[i * 4 + 1] = zone_expansion_y[i] + generatorsOS_scaled[0]->y + generatorsOS_scaled[1]->y;
	//	zone_generator_y[i * 4 + 2] = zone_expansion_y[i] + generatorsOS_scaled[0]->y - generatorsOS_scaled[1]->y;
	//	zone_generator_y[i * 4 + 3] = zone_expansion_y[i] - generatorsOS_scaled[0]->y - generatorsOS_scaled[1]->y;
	//}
	//int min_x = *min_element(zone_generator_x.begin(), zone_generator_x.end());
	//int min_y = *min_element(zone_generator_y.begin(), zone_generator_y.end());
	//int max_x = *max_element(zone_generator_x.begin(), zone_generator_x.end());
	//int max_y = *max_element(zone_generator_y.begin(), zone_generator_y.end());



	// generate enough candidates and keep the ones in the generator zone
	int num_halfpoolX = 100;
	int num_halfpoolY = 100;
	totalShiftsXY_scaled = 0;
	vector<Point2i*>().swap(list_shiftXY_scaled);
	for (int i_x = -num_halfpoolX; i_x < num_halfpoolX; i_x++){
		for (int i_y = -num_halfpoolY; i_y < num_halfpoolY; i_y++){
			int a_x = generatorsOS_scaled[0]->x * i_x;
			int a_y = generatorsOS_scaled[0]->y * i_x;
			int b_x = generatorsOS_scaled[1]->x * i_y;
			int b_y = generatorsOS_scaled[1]->y * i_y;
			int x = a_x + b_x;
			int y = a_y + b_y;
			// find the area of intersection
			std::vector<int> pos_x(4);
			std::vector<int> pos_y(4);
			pos_x[0] = 0;
			pos_x[1] = colsInput_scaled;
			pos_x[2] = x;
			pos_x[3] = x + colsInput_scaled;
			pos_y[0] = 0;
			pos_y[1] = rowsInput_scaled;
			pos_y[2] = y;
			pos_y[3] = y + rowsInput_scaled;

			int start_x = *min_element(pos_x.begin(), pos_x.end());
			int end_x = *max_element(pos_x.begin(), pos_x.end());
			int start_y = *min_element(pos_y.begin(), pos_y.end());
			int end_y = *max_element(pos_y.begin(), pos_y.end());
			int intersect_x = 2 * colsInput_scaled - (end_x - start_x);
			int intersect_y = 2 * rowsInput_scaled - (end_y - start_y);
			double ratio_intersect;
			if (intersect_x >= 0 && intersect_y >= 0){
				ratio_intersect  = double((intersect_x)* (intersect_y)) / (double)(colsInput_scaled * rowsInput_scaled);
			}
			else{
				ratio_intersect = 0;
			}
			 
			//if (x >= min_x && y >= min_y && x <= max_x  && y <= max_y){
			if (ratio_intersect > 0.15){
				bool flag_in = false;
				// check if x, y is already in the list
				for (int z = 0; z < (int)list_shiftXY_scaled.size(); z++){
					if (list_shiftXY_scaled[z]->x == x && list_shiftXY_scaled[z]->y == y){
						flag_in = true;
						break;
					}
				}
				if (!flag_in){
					list_shiftXY_scaled.push_back(new Point2i(x, y));
					totalShiftsXY_scaled += 1;
				}
			}
		}
	}
	vector<Point2i*>().swap(gcoNodes);
	gcoNodes.resize(numPixelSyn_scaled);
	for (int y = 0; y < rowsSyn_scaled; y++){
		for (int x = 0; x < colsSyn_scaled; x++){
			gcoNodes[y * colsSyn_scaled + x] = new Point2i(x, y);
		}
	}

	for (int i_s = 0; i_s < totalShiftsXY_scaled; i_s++){
		qDebug() << list_shiftXY_scaled[i_s]->x << ", " << list_shiftXY_scaled[i_s]->y;
	}
}

void Synthesizer::prepareShifts_OffsetStatisticsMW(){
	qDebug() << "Prepare shifts ...";
	// compute the dimension of the synthesis image
	totalShiftsX_scaled = (totalGeneratorX_scaled - 1) / (generatorX_scaled / (double)shiftsPerGenerator_scaled) + 1;
	totalShiftsY_scaled = (totalGeneratorY_scaled - 1) / (generatorY_scaled / (double)shiftsPerGenerator_scaled) + 1;
	totalShiftsXY_scaled = totalShiftsX_scaled * totalShiftsY_scaled;
	colsPerShiftX_scaled = (int)round((colsInput_scaled * generatorX_scaled) / (shiftsPerGenerator_scaled));
	colsSyn_scaled = colsInput_scaled + (totalShiftsX_scaled - 1) * colsPerShiftX_scaled;
	rowsPerShiftY_scaled = (int)round((rowsInput_scaled * generatorY_scaled) / (shiftsPerGenerator_scaled));
	rowsSyn_scaled = rowsInput_scaled + (totalShiftsY_scaled - 1) * rowsPerShiftY_scaled;
	numPixelSyn_scaled = colsSyn_scaled * rowsSyn_scaled;
	imgSynGray_scaled = Mat1b::zeros(rowsSyn_scaled, colsSyn_scaled);
	gcolabelSyn_scaled = Mat1i::zeros(rowsSyn_scaled, colsSyn_scaled);

	// recompute number of shifts
	if (abs(generatorsOS_scaled[0]->x) != 0){
		colsPerShiftX_scaled = abs(generatorsOS_scaled[0]->x);
	}
	if (abs(generatorsOS_scaled[1]->y) != 0){
		rowsPerShiftY_scaled = abs(generatorsOS_scaled[1]->y);
	}
	
	totalShiftsX_scaled = ceil((double)(colsSyn_scaled - colsInput_scaled) / (double)colsPerShiftX_scaled) + 1;
	totalShiftsY_scaled = ceil((double)(rowsSyn_scaled - rowsInput_scaled) / (double)rowsPerShiftY_scaled) + 1;
	totalShiftsXY_scaled = totalShiftsX_scaled * totalShiftsY_scaled;
	// compute candidate shifts
	list_shiftX_scaled.resize(totalShiftsX_scaled);
	for (int i_s = 0; i_s < totalShiftsX_scaled; i_s++){
		list_shiftX_scaled[i_s] = i_s * colsPerShiftX_scaled;
	}
	list_shiftY_scaled.resize(totalShiftsY_scaled);
	for (int i_s = 0; i_s < totalShiftsY_scaled; i_s++){
		list_shiftY_scaled[i_s] = i_s * rowsPerShiftY_scaled;
	}
	vector<Point2i*>().swap(list_shiftXY_scaled);
	list_shiftXY_scaled.resize(totalShiftsXY_scaled);
	for (int y = 0; y < totalShiftsY_scaled; y++){
		for (int x = 0; x < totalShiftsX_scaled; x++){
			list_shiftXY_scaled[y * totalShiftsX_scaled + x] = new Point2i(x * colsPerShiftX_scaled, y * rowsPerShiftY_scaled);
		}
	}
	vector<Point2i*>().swap(gcoNodes);
	gcoNodes.resize(numPixelSyn_scaled);
	for (int y = 0; y < rowsSyn_scaled; y++){
		for (int x = 0; x < colsSyn_scaled; x++){
			gcoNodes[y * colsSyn_scaled + x] = new Point2i(x, y);
		}
	}

	qDebug() << "totalShiftsX: " << totalShiftsX_scaled << ", colsSyn_scaled: " << colsSyn_scaled << ", colsPerShiftX_scaled : " << colsPerShiftX_scaled;
	qDebug() << "totalShiftsY: " << totalShiftsY_scaled << ", rowsSyn_scaled: " << rowsSyn_scaled << ", rowsPerShiftY_scaled : " << rowsPerShiftY_scaled;

}

int Synthesizer::unary_OffsetStatistics(int p, int l){

	// compute the unary cost of assigning list_shiftXY_scaled[i_l] to gcoNodes[i_n]
	int newX = -list_shiftXY_scaled[l]->x + gcoNodes[p]->x;
	int newY = -list_shiftXY_scaled[l]->y + gcoNodes[p]->y;
	if (isValid(newX, newY)){
		return 0;
	}
	else{
		return 1000;
	}
}

int Synthesizer::smooth_OffsetStatistics(int p1, int p2, int l1, int l2){
	int retMe = 0;
	if (l1 == l2){
		return 0;
	}
	Point2i x1_s_a = -*list_shiftXY_scaled[l1] + *gcoNodes[p1];
	Point2i x2_s_b = -*list_shiftXY_scaled[l2] + *gcoNodes[p2];

	if (isValid(x1_s_a.x, x1_s_a.y) && isValid(x2_s_b.x, x2_s_b.y))
	{
		Point2i x1_s_b = -*list_shiftXY_scaled[l2] + *gcoNodes[p1];
		Point2i x2_s_a = -*list_shiftXY_scaled[l1] + *gcoNodes[p2];
		if (isValid(x1_s_b.x, x1_s_b.y) && isValid(x2_s_a.x, x2_s_a.y)){

			int diff1 = imgInputGray_scaled(x1_s_a.y, x1_s_a.x) - imgInputGray_scaled(x1_s_b.y, x1_s_b.x);
			int diff2 = imgInputGray_scaled(x2_s_a.y, x2_s_a.x) - imgInputGray_scaled(x2_s_b.y, x2_s_b.x);
			double energypixel = sqrt(double(diff1*diff1)) + sqrt(double(diff2*diff2));
			retMe = (int)energypixel;
			return retMe;
		}
		else{
			return 1000;
		}
	}
	return 1000;
}

void Synthesizer::fill_OffsetStatistics(){

	qDebug() << "hole filling starts (Offset Statistics) ... ";

	// Prepare shifts
	prepareShifts_OffsetStatistics();

	// setup graph cut problem
	//qDebug() << "colsSyn_scaled: " << colsSyn_scaled << ", rowsSyn_scaled: " << rowsSyn_scaled << ", totalShiftsXY_scaled: " << totalShiftsXY_scaled;
	gcGrid = new GCoptimizationGridGraph(colsSyn_scaled, rowsSyn_scaled, totalShiftsXY_scaled);

	// set unary cost
	gcGrid->setDataCost(&unary_fill_OffsetStatistics);

	//// set smoothness cost
	gcGrid->setSmoothCost(&smooth_OffsetStatistics);

	qDebug() << "Before optimization energy is " << gcGrid->compute_energy();
	for (int i = 0; i < 4; i++){
		gcGrid->expansion(1);// run expansion for 2 iterations. For swap use gc->swap(num_iterations);
		qDebug() << "after expansion energy is " << gcGrid->compute_energy();
		gcGrid->swap(1);// run expansion for 2 iterations. For swap use gc->swap(num_iterations);
		qDebug() << "after swap energy is " << gcGrid->compute_energy();
	}

	//// prepare results
	label2result();
}

int Synthesizer::unary_fill_OffsetStatistics(int p, int l){

	// compute the unary cost of assigning list_shiftXY_scaled[i_l] to gcoNodes[i_n]
	int newX = -list_shiftXY_scaled[l]->x + gcoNodes[p]->x;
	int newY = -list_shiftXY_scaled[l]->y + gcoNodes[p]->y;
	if (isValid_fill(newX, newY)){
		if (imgInputMask_scaled(gcoNodes[p]->y, gcoNodes[p]->x) == 1){
			return 0;
		}
		else{
			if (list_shiftXY_scaled[l]->x == 0 && list_shiftXY_scaled[l]->y == 0){
				return 0;
			}
			return 1000;
		}
	}
    return 1000;
}

// Building Blocks
void Synthesizer::synthesis_BB(){
	qDebug() << "Synthesis starts (Building blocks) ... ";

	// Prepare shifts
	// Prepare shifts
	switch (mode_sampling)
	{
	case 1:
		prepareShifts_ShiftMap();
		break;
	case 2:
		if (abs(generatorsOS_scaled[0]->x) == 0){
			prepareShifts_OffsetStatisticsMW();
		}
		else{
			prepareShifts_OffsetStatistics();
		}
		break;
	case 3:
		prepareShifts_OffsetStatisticsMW();
		break;
	case 4:
		if (abs(generatorsOS_scaled[0]->x) == 0){
			prepareShifts_BBMW();
		}
		else{
			prepareShifts_BB();
		}
		break;
	case 5:
		prepareShifts_BBMW();
		break;
	default:
		break;
	}

	// setup graph cut problem
	gcGrid = new GCoptimizationGridGraph(colsSyn_scaled, rowsSyn_scaled, totalShiftsXY_scaled);

	// set unary cost
	gcGrid->setDataCost(&unary_BB);

	// set smoothness cost
	gcGrid->setSmoothCost(&smooth_BB);

	// optimize
	//qDebug() << "Before optimization energy is " << gcGrid->compute_energy();
	for (int i = 0; i < 2; i++){
		gcGrid->expansion(1);// run expansion for 2 iterations. For swap use gc->swap(num_iterations);
		qDebug() << "after expansion energy is " << gcGrid->compute_energy();
		gcGrid->swap(1);// run expansion for 2 iterations. For swap use gc->swap(num_iterations);
		qDebug() << "after swap energy is " << gcGrid->compute_energy();
	}

	// prepare results
	label2result();
}

void Synthesizer::prepareShifts_BB(){
	prepareShifts_OffsetStatistics();
}

void Synthesizer::prepareShifts_BBMW(){
	prepareShifts_OffsetStatisticsMW();
}

int Synthesizer::unary_BB(int p, int l){

	int newX = -list_shiftXY_scaled[l]->x + gcoNodes[p]->x;
	int newY = -list_shiftXY_scaled[l]->y + gcoNodes[p]->y;
	if (isValid(newX, newY)){
		return 0;
	}
	else{
		return 1000;
	}

}

int Synthesizer::smooth_BB(int p1, int p2, int l1, int l2){
	int retMe = 0;
	if (l1 == l2){
		return 0;
	}
	Point2i x1_s_a = -*list_shiftXY_scaled[l1] + *gcoNodes[p1];
	Point2i x2_s_b = -*list_shiftXY_scaled[l2] + *gcoNodes[p2];

	if (isValid(x1_s_a.x, x1_s_a.y) && isValid(x2_s_b.x, x2_s_b.y)){
		Point2i x1_s_b = -*list_shiftXY_scaled[l2] + *gcoNodes[p1];
		Point2i x2_s_a = -*list_shiftXY_scaled[l1] + *gcoNodes[p2];
		if (isValid(x1_s_b.x, x1_s_b.y) && isValid(x2_s_a.x, x2_s_a.y)){

			int diff1 = weight_pixel * imgInputGray_scaled(x1_s_a.y, x1_s_a.x) - imgInputGray_scaled(x1_s_b.y, x1_s_b.x);
			int diff2 = weight_pixel * imgInputGray_scaled(x2_s_a.y, x2_s_a.x) - imgInputGray_scaled(x2_s_b.y, x2_s_b.x);

			double diffRep1 = weight_label * (imgInputlabel_scaled(x1_s_a.y, x1_s_a.x) != imgInputlabel_scaled(x1_s_b.y, x1_s_b.x));
			double diffRep2 = weight_label * (imgInputlabel_scaled(x2_s_a.y, x2_s_a.x) != imgInputlabel_scaled(x2_s_b.y, x2_s_b.x));

			bool indicator1 = imgInputlabel_scaled(x1_s_a.y, x1_s_a.x) == imgInputlabel_scaled(x1_s_b.y, x1_s_b.x);
			bool indicator2 = imgInputlabel_scaled(x2_s_a.y, x2_s_a.x) == imgInputlabel_scaled(x2_s_b.y, x2_s_b.x);
			double diffRepinter1X = weight_labelinter * (imgInputlabelinterX_scaled(x1_s_a.y, x1_s_a.x) - imgInputlabelinterX_scaled(x1_s_b.y, x1_s_b.x));
			double diffRepinter1Y = weight_labelinter * (imgInputlabelinterY_scaled(x1_s_a.y, x1_s_a.x) - imgInputlabelinterY_scaled(x1_s_b.y, x1_s_b.x));
			double diffRepinter2X = weight_labelinter * (imgInputlabelinterX_scaled(x2_s_a.y, x2_s_a.x) - imgInputlabelinterX_scaled(x2_s_b.y, x2_s_b.x));
			double diffRepinter2Y = weight_labelinter * (imgInputlabelinterY_scaled(x2_s_a.y, x2_s_a.x) - imgInputlabelinterY_scaled(x2_s_b.y, x2_s_b.x));

			double energypixel = sqrt(double(diff1*diff1)) + sqrt(double(diff2*diff2));
			double energylabel = sqrt(double(diffRep1*diffRep1)) + sqrt(double(diffRep2*diffRep2));
			double energyinterlabel = indicator1 * (sqrt(double(diffRepinter1X*diffRepinter1X)) + sqrt(double(diffRepinter1Y*diffRepinter1Y))) + indicator2 * (sqrt(double(diffRepinter2X * diffRepinter2X)) + sqrt(double(diffRepinter2Y * diffRepinter2Y)));

			retMe = ceil(energypixel + energylabel + energyinterlabel);
			//retMe = ceil(energypixel);
			return retMe;
		}
		else{
			return 1000;
		}
	}
	return 1000;
}

void Synthesizer::fill_BB(){

	prepareShifts_BB();

	// setup graph cut problem
	gcGrid = new GCoptimizationGridGraph(colsSyn_scaled, rowsSyn_scaled, totalShiftsXY_scaled);

	// set unary cost
	gcGrid->setDataCost(&unary_fill_BB);
	//gc->setDataCost(&unary_OffsetStatistics);

	// set smoothness cost
	gcGrid->setSmoothCost(&smooth_BB);
	//gc->setSmoothCost(&smooth_OffsetStatistics);

	// optimize
	qDebug() << "Before optimization energy is " << gcGrid->compute_energy();
	for (int i = 0; i < 4; i++){
		gcGrid->expansion(1);// run expansion for 2 iterations. For swap use gc->swap(num_iterations);
		qDebug() << "after expansion energy is " << gcGrid->compute_energy();
		gcGrid->swap(1);// run expansion for 2 iterations. For swap use gc->swap(num_iterations);
		qDebug() << "after swap energy is " << gcGrid->compute_energy();
	}

	// prepare results
	label2result();
}

int Synthesizer::unary_fill_BB(int p, int l){

	// compute the unary cost of assigning list_shiftXY_scaled[i_l] to gcoNodes[i_n]
	int newX = -list_shiftXY_scaled[l]->x + gcoNodes[p]->x;
	int newY = -list_shiftXY_scaled[l]->y + gcoNodes[p]->y;
	if (isValid_fill(newX, newY)){
		if (imgInputMask_scaled(gcoNodes[p]->y, gcoNodes[p]->x) == 1){
			return 0;
		}
		else{
			if (list_shiftXY_scaled[l]->x == 0 && list_shiftXY_scaled[l]->y == 0){
				return 0;
			}
			return 1000;
		}
	}
	return 1000;
}

// None local
void Synthesizer::synthesis_Nonelocal(){
	qDebug() << "Synthesis starts (None local) ... ";

	// Prepare shifts
	prepareShifts_Nonelocal();

	// setup graph cut problem
	gcGeneral = new GCoptimizationGeneralGraph(colsSyn_scaled * rowsSyn_scaled, totalShiftsXY_scaled);

	// set neighbors
	setNeighbor_Nonelocal();

	// set unary cost
	gcGeneral->setDataCost(&unary_Nonelocal);

	// set smoothness cost
	gcGeneral->setSmoothCost(&smooth_Nonelocal);


	//qDebug() << "Before optimization energy is " << gcGeneral->compute_energy();
	for (int i = 0; i < 2; i++){
		gcGeneral->expansion(1);// run expansion for 2 iterations. For swap use gc->swap(num_iterations);
		qDebug() << "after expansion energy is " << gcGeneral->compute_energy();
		//gcGeneral->swap(1);// run expansion for 2 iterations. For swap use gc->swap(num_iterations);
		//qDebug() << "after swap energy is " << gcGeneral->compute_energy();
	}
	qDebug() << "Smoothness; " << gcGeneral->giveSmoothEnergy();
	//qDebug() << "Unary: " << gcGeneral->giveDataEnergy() << ", Smoothness; " << gcGeneral->giveSmoothEnergy();

	//// prepare results
	label2result();
}

void Synthesizer::prepareShifts_Nonelocal(){
	prepareShifts_OffsetStatisticsMW();
	//prepareShifts_ShiftMap();
}

void Synthesizer::setNeighbor_Nonelocal(){
	for (int i_n = 0; i_n < (int)gcoNodes.size(); i_n++){
		for (int j_n = i_n + 1; j_n < (int)gcoNodes.size(); j_n++){
			int i_x = gcoNodes[i_n]->x;
			int i_y = gcoNodes[i_n]->y;
			int j_x = gcoNodes[j_n]->x;
			int j_y = gcoNodes[j_n]->y;
			if (abs(i_x - j_x) <= r_Nonelocal_scaled && abs(i_y - j_y) <= r_Nonelocal_scaled){
				gcGeneral->setNeighbors(i_n, j_n, 1);
			}
		}
	}
}

int Synthesizer::unary_Nonelocal(int p, int l){
	int newX = -list_shiftXY_scaled[l]->x + gcoNodes[p]->x;
	int newY = -list_shiftXY_scaled[l]->y + gcoNodes[p]->y;
	if (isValid(newX, newY)){
		return 0;
	}
	else{
		return 10000000;
	}
}

int Synthesizer::smooth_Nonelocal(int p1, int p2, int l1, int l2){
	int retMe = 0;

	if (l1 == l2){
		return 0;
	}

	if (is4connected(p1, p2)){
		// if p1 and p2 are local neighbors (4 connected)
		Point2i x1_s_a = -*list_shiftXY_scaled[l1] + *gcoNodes[p1];
		Point2i x2_s_b = -*list_shiftXY_scaled[l2] + *gcoNodes[p2];
		if (isValid(x1_s_a.x, x1_s_a.y) && isValid(x2_s_b.x, x2_s_b.y)){
			Point2i x1_s_b = -*list_shiftXY_scaled[l2] + *gcoNodes[p1];
			Point2i x2_s_a = -*list_shiftXY_scaled[l1] + *gcoNodes[p2];
			if (isValid(x1_s_b.x, x1_s_b.y) && isValid(x2_s_a.x, x2_s_a.y)){



				int diff1 = weight_pixel * imgInputGray_scaled(x1_s_a.y, x1_s_a.x) - imgInputGray_scaled(x1_s_b.y, x1_s_b.x);
				int diff2 = weight_pixel * imgInputGray_scaled(x2_s_a.y, x2_s_a.x) - imgInputGray_scaled(x2_s_b.y, x2_s_b.x);

				double diffRep1 = weight_label * (imgInputlabel_scaled(x1_s_a.y, x1_s_a.x) != imgInputlabel_scaled(x1_s_b.y, x1_s_b.x));
				double diffRep2 = weight_label * (imgInputlabel_scaled(x2_s_a.y, x2_s_a.x) != imgInputlabel_scaled(x2_s_b.y, x2_s_b.x));

				bool indicator1 = imgInputlabel_scaled(x1_s_a.y, x1_s_a.x) == imgInputlabel_scaled(x1_s_b.y, x1_s_b.x);
				bool indicator2 = imgInputlabel_scaled(x2_s_a.y, x2_s_a.x) == imgInputlabel_scaled(x2_s_b.y, x2_s_b.x);
				double diffRepinter1X = weight_labelinter * (imgInputlabelinterX_scaled(x1_s_a.y, x1_s_a.x) - imgInputlabelinterX_scaled(x1_s_b.y, x1_s_b.x));
				double diffRepinter1Y = weight_labelinter * (imgInputlabelinterY_scaled(x1_s_a.y, x1_s_a.x) - imgInputlabelinterY_scaled(x1_s_b.y, x1_s_b.x));
				double diffRepinter2X = weight_labelinter * (imgInputlabelinterX_scaled(x2_s_a.y, x2_s_a.x) - imgInputlabelinterX_scaled(x2_s_b.y, x2_s_b.x));
				double diffRepinter2Y = weight_labelinter * (imgInputlabelinterY_scaled(x2_s_a.y, x2_s_a.x) - imgInputlabelinterY_scaled(x2_s_b.y, x2_s_b.x));

				double energypixel = sqrt(double(diff1*diff1)) + sqrt(double(diff2*diff2));
				double energylabel = sqrt(double(diffRep1*diffRep1)) + sqrt(double(diffRep2*diffRep2));
				double energyinterlabel = indicator1 * (sqrt(double(diffRepinter1X*diffRepinter1X)) + sqrt(double(diffRepinter1Y*diffRepinter1Y))) + indicator2 * (sqrt(double(diffRepinter2X * diffRepinter2X)) + sqrt(double(diffRepinter2Y * diffRepinter2Y)));

				retMe = ceil(energypixel + energylabel + energyinterlabel);
				//retMe = ceil(energypixel);
				return retMe;
			}
			else{
				return 1000;
			}
		}
		return 1000;
	}
	else{
		//////// if p1 and p2 are none local neighbors, check if they are building blocks
		Point2i pt1 = -*list_shiftXY_scaled[l1] + *gcoNodes[p1];
		Point2i pt2 = -*list_shiftXY_scaled[l2] + *gcoNodes[p2];
		if (isValid(pt1.x, pt1.y) && isValid(pt2.x, pt2.y)){
			// see if x1_s_a and x2_s_b land on any building block
		    int b1 = -1;
			int b2 = -1;
			b1 = isBuildingBlock(pt1);
			b2 = isBuildingBlock(pt2);
			if (b1 > -1 && b2 > -1){
				// compute the cost
				retMe = eval_BBpair_Nonelocal(*gcoNodes[p1], *gcoNodes[p2], pt1, pt2, b1, b2);
			}
		}
		else{
			retMe = 1000;
		}
		return retMe;
	}

}

int Synthesizer::debug_smooth_Nonelocal(int p1, int p2, int l1, int l2){
	return 0;
}

int Synthesizer::eval_BBCornerpair_Nonelocal(Point2i pt1, Point2i pt2, int bbtype1, int bbtype2){
	Point2i offset;
	int idx;
	if (bbtype1 < bbtype2){
		idx = bbtype1 * numRep + bbtype2;
		offset = pt1 - pt2;
	}
	else{
		idx = bbtype2 * numRep + bbtype1;
		offset = pt2 - pt1;
	}

	for (int i_offset = 0; i_offset < (int)repOffset_scaled[idx].size(); i_offset++){
		if (offset.x == repOffset_scaled[idx][i_offset]->x && offset.y == repOffset_scaled[idx][i_offset]->y){
			return 0;
		}
	}
	return 1000;
}

int Synthesizer::eval_BBpair_Nonelocal(Point2i pt1syn, Point2i pt2syn, Point2i pt1input, Point2i pt2input, int bbtype1, int bbtype2){
	Point2i offset12, offset1, offset2;
	offset1 = getoffset_Nonelocal(pt1input);
	offset2 = getoffset_Nonelocal(pt2input);
	int idx;
	idx = bbtype1 * numRep + bbtype2;
	offset12 = (pt1syn - offset1) - (pt2syn - offset2);
	//qDebug() << offset12.x << offset12.y;
	for (int i_offset = 0; i_offset < (int)repOffset_scaled[idx].size(); i_offset++){
		if (offset12.x == repOffset_scaled[idx][i_offset]->x && offset12.y == repOffset_scaled[idx][i_offset]->y){
			return 0;
		}
	}
	return 100;
}

Point2i Synthesizer::getoffset_Nonelocal(Point2i pt){
	pt.x = min<int>(pt.x, colsSyn_scaled - 1);
	pt.x = max<int>(pt.x, 0);
	pt.y = min<int>(pt.y, rowsSyn_scaled - 1);
	pt.y = max<int>(pt.y, 0);

	int x = (int)imgInputoffsetinterX_scaled(pt.y, pt.x);
	int y = (int)imgInputoffsetinterY_scaled(pt.y, pt.x);
	return Point2i(x, y);
}

// misc
void Synthesizer::label2result(){
	// prepare results
	imgSyn_scaled = Mat3b::zeros(rowsSyn_scaled, colsSyn_scaled);
	gcolabelSyn_scaled = Mat1i::zeros(rowsSyn_scaled, colsSyn_scaled);
	std::vector<int> label_used;
	label_used.resize(0);
	for (int i = 0; i < numPixelSyn_scaled; i++){
		int label;
		label = gcGrid->whatLabel(i);
		int newX = -list_shiftXY_scaled[label]->x + gcoNodes[i]->x;
		int newY = -list_shiftXY_scaled[label]->y + gcoNodes[i]->y;
		if (newX >= 0 && newX < colsInput_scaled && newY >= 0 && newY < rowsInput_scaled){
			imgSyn_scaled(gcoNodes[i]->y, gcoNodes[i]->x) = imgInput_scaled(newY, newX);
			gcolabelSyn_scaled(gcoNodes[i]->y, gcoNodes[i]->x) = label;
			auto loc = std::find(label_used.begin(), label_used.end(), label);
			int idx_shift = loc - label_used.begin();
			if (idx_shift == label_used.size()){
				label_used.push_back(label);
			}
		}
	}	
	totalShiftsXY_fullres = totalShiftsXY_scaled;
	list_shiftXY_fullres.resize(totalShiftsXY_fullres);
	for (int xy = 0; xy < totalShiftsXY_fullres; xy++){
		list_shiftXY_fullres[xy] = new Point2i(list_shiftXY_scaled[xy]->x / scalerRes, list_shiftXY_scaled[xy]->y / scalerRes);
	}
	rowsSyn_fullres = rowsSyn_scaled / scalerRes;
	colsSyn_fullres = colsSyn_scaled / scalerRes;
	gcolabelSyn_fullres = Mat1i::zeros(rowsSyn_fullres, colsSyn_fullres);
	cv::resize(gcolabelSyn_scaled, gcolabelSyn_fullres, Size(colsSyn_fullres, rowsSyn_fullres), 0, 0, INTER_NEAREST);
	imgSyn_fullres = Mat3b::zeros(rowsSyn_fullres, colsSyn_fullres);
	for (int r = 0; r < rowsSyn_fullres; r++){
		for (int c = 0; c < colsSyn_fullres; c++){
			if ((c - list_shiftXY_fullres[gcolabelSyn_fullres(r, c)]->x) < colsInput_fullres && (c - list_shiftXY_fullres[gcolabelSyn_fullres(r, c)]->x) >= 0){
				if ((r - list_shiftXY_fullres[gcolabelSyn_fullres(r, c)]->y) < rowsInput_fullres && (r - list_shiftXY_fullres[gcolabelSyn_fullres(r, c)]->y) >= 0){
					imgSyn_fullres(r, c) = imgInput_fullres(r - list_shiftXY_fullres[gcolabelSyn_fullres(r, c)]->y, c - list_shiftXY_fullres[gcolabelSyn_fullres(r, c)]->x);
				}
			}
			else{
			}
		}
	}

	*qimgSyn_fullres = Mat2QImage(imgSyn_fullres);
	qimgSyn_fullres->save(filename_imgOutput);

	gcoBBlabelSynColor_scaled = Mat3b::zeros(rowsSyn_scaled, colsSyn_scaled);
	gcoBBlabelSynColor_fullres = Mat3b::zeros(rowsSyn_fullres, colsSyn_fullres);
	for (int r = 0; r < rowsSyn_scaled; r++){
		for (int c = 0; c < colsSyn_scaled; c++){
			int cc = -list_shiftXY_scaled[gcolabelSyn_scaled(r, c)]->x + c;
			int rr = -list_shiftXY_scaled[gcolabelSyn_scaled(r, c)]->y + r;
			if (rr >= 0 && rr < rowsInput_scaled && cc >= 0 && cc < colsSyn_scaled){
				int bb_type = imgInputlabel_scaled(rr, cc) - 1;
				if (bb_type > -1){
					Vec3d color(colorList[bb_type][2], colorList[bb_type][1], colorList[bb_type][0]);
					gcoBBlabelSynColor_scaled(r, c) = color;
				}
			}
	//		Vec3d color(colorList[gcolabelSyn_scaled(r, c)][2], colorList[gcolabelSyn_scaled(r, c)][1], colorList[gcolabelSyn_scaled(r, c)][0]);
	//		gcolabelSynColor_scaled(r, c) = color;
		}
	}
	cv::resize(gcoBBlabelSynColor_scaled, gcoBBlabelSynColor_fullres, Size(colsSyn_fullres, rowsSyn_fullres), 0, 0, INTER_NEAREST);
	*qimgSynlabelColor_fullres = Mat2QImage(gcoBBlabelSynColor_fullres);
	qimgSynlabelColor_fullres->save(filename_imgBBOutput);


	//// debug the nonlocal cost
	//if (mode_method > 0){
		//std::vector<int> bb_x_scale, bb_y_scale, bb_x_fullres, bb_y_fullres, bb_type;
		//bb_x_scale.resize(0);
		//bb_y_scale.resize(0);
		//bb_x_fullres.resize(0);
		//bb_y_fullres.resize(0);
		//bb_type.resize(0);
		//for (int r = 0; r < rowsSyn_scaled; r++){
		//	for (int c = 0; c < colsSyn_scaled; c++){
		//		Point2i loc(c, r);
		//		loc = loc - *list_shiftXY_scaled[gcolabelSyn_scaled(r, c)];
		//		int ret_type = isBuildingBlockCorner(loc);
		//		if (ret_type > -1){
		//			bb_x_scale.push_back(c);
		//			bb_y_scale.push_back(r);
		//			bb_x_fullres.push_back(c / scalerRes);
		//			bb_y_fullres.push_back(r / scalerRes);
		//			bb_type.push_back(ret_type);
		//		}
		//	}
		//}

		//Mat3b im_impose_fullres = Mat3b::zeros(rowsSyn_fullres, colsSyn_fullres);
		//im_impose_fullres = imgSyn_fullres;
		//for (int i = 0; i < (int)bb_x_fullres.size(); i++){
		//	Vec3d color(colorList[bb_type[i]][2], colorList[bb_type[i]][1], colorList[bb_type[i]][0]);
		//	for (int r = 0; r < 10; r++){
		//		for (int c = 0; c < 10; c++){
		//			if (bb_y_fullres[i] + r > -1 && bb_y_fullres[i] + r < rowsSyn_fullres && bb_x_fullres[i] + c > -1 && bb_x_fullres[i] + c < colsSyn_fullres){
		//				im_impose_fullres(bb_y_fullres[i] + r, bb_x_fullres[i] + c) = color;
		//			}
		//			
		//		}
		//	}
		//}


		//int invalid_pair = 0;
		//for (int i = 0; i < (int)bb_x_scale.size(); i++){
		//	for (int j = 0; j < (int)bb_x_scale.size(); j++){
		//		if (i != j){
		//			Point2i p1(bb_x_scale[i], bb_y_scale[i]);
		//			Point2i p2(bb_x_scale[j], bb_y_scale[j]);
		//			Point2i offset;
		//			int idx;

		//			if (!((abs(p1.x - p2.x) == 1 && p1.y == p2.y) || (abs(p1.y - p2.y) == 1 && p1.x == p2.x))){
		//				if (abs(p1.x - p2.x) <= r_Nonelocal_scaled && abs(p1.y - p2.y) <= r_Nonelocal_scaled){
		//					if (i < j){
		//						idx = bb_type[i] * numRep + bb_type[j];
		//						offset = p1 - p2;
		//					}
		//					else{
		//						idx = bb_type[j] * numRep + bb_type[i];
		//						offset = p2 - p1;
		//					}
		//					// see if offset is valid
		//					int cost = 1000;
		//					for (int i_offset = 0; i_offset < (int)repOffset_scaled[idx].size(); i_offset++){
		//						if (offset.x == repOffset_scaled[idx][i_offset]->x && offset.y == repOffset_scaled[idx][i_offset]->y){
		//							cost = 0;
		//							break;
		//						}
		//					}
		//					if (cost > 0){
		//						int p_1 = p1.y * colsSyn_scaled + p1.x;
		//						int p_2 = p2.y * colsSyn_scaled + p2.x;
		//						int l_1;
		//						int l_2;
		//						if (mode_method != 4){
		//							l_1 = gcGrid->whatLabel(p_1);
		//							l_2 = gcGrid->whatLabel(p_2);
		//						}
		//						else{
		//							l_1 = gcGeneral->whatLabel(p_1);
		//							l_2 = gcGeneral->whatLabel(p_2);
		//						}
		//						int sc = smooth_Nonelocal(p_1, p_2, l_1, l_2);
		//						//qDebug() << p_1 << ", " << p_2 << ", " << l_1 << ", " << l_2 << ", " << sc;
		//						invalid_pair += 1;
		//						Vec3d color(0, 0, 255);
		//						for (int r = 0; r < 10; r++){
		//							for (int c = 0; c < 10; c++){
		//								im_impose_fullres(bb_y_fullres[i] + r, bb_x_fullres[i] + c) = color;
		//							}
		//						}
		//					}
		//				}
		//			}
		//		}
		//	}
		//}
		//QImage* qim_impose_fullres = new QImage; // input repetition labels
		//*qim_impose_fullres = Mat2QImage(im_impose_fullres);
		//qim_impose_fullres->save(filename_imgBBOutput);

}

bool Synthesizer::isValid(int x, int y){
	if (x >= 0 && y >= 0 && x < colsInput_scaled && y < rowsInput_scaled){
		return true;
	}
	return false;
}

bool Synthesizer::isValid_fill(int x, int y){
	if (x >= 0 && y >= 0 && x < colsInput_scaled && y < rowsInput_scaled){
		if (imgInputMask_scaled(y, x) != 1){
			return true;
		}
		return false;
	}
	return false;
}

bool Synthesizer::is4connected(int p1, int p2){
	int x1 = gcoNodes[p1]->x;
	int y1 = gcoNodes[p1]->y;
	int x2 = gcoNodes[p2]->x;
	int y2 = gcoNodes[p2]->y;
	if ((abs(x1 - x2) == 1 && y1 == y2) || (abs(y1 - y2) == 1 && x1 == x2)){
		return true;
	}
	return false;

}

int Synthesizer::isBuildingBlockCorner(Point2i pt){

	for (int i_rep = 0; i_rep < numRep; i_rep++){
		for (int j_rep = 0; j_rep < (int)repX_scaled[i_rep].size(); j_rep++){
			if (pt.x == repX_scaled[i_rep][j_rep] && pt.y == repY_scaled[i_rep][j_rep]){
				return i_rep;
			}
		}
	}

	return -1;
}

int Synthesizer::isBuildingBlock(Point2i pt){
	return (int)imgInputlabel_scaled(pt.y, pt.x) - 1;
}