#ifndef REP_H
#define REP_H
#include <vector>
#include <QGraphicsView>
#include <QGraphicsScene>
#include <QKeyEvent>
#include <QApplication>
#include <QGraphicsObject>
#include "Para.h"
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv/cv.h>
#include "gco\GCoptimization.h"

using namespace cv;


class Synthesizer
{
public:
	//-------------------------------------------------------------
	// functions
	//-------------------------------------------------------------
	Synthesizer(void);
	~Synthesizer(void);
	Mat qimage2mat(const QImage& qimage);
	void initialization();

	// Shift Map
	void synthesis_ShiftMap();
	void prepareShifts_ShiftMap();
	void prepareShifts_ShiftMapBoarder();
	static int unary_ShiftMap(int p, int l);
	static int smooth_ShiftMap(int p1, int p2, int l1, int l2);
	void fill_ShiftMap();

	// Offset Statistics
	void synthesis_OffsetStatistics();
	void prepareShifts_OffsetStatistics();
	void prepareShifts_OffsetStatisticsMW();
	void prepareShifts_OffsetStatisticsMWBoarder();
	static int unary_OffsetStatistics(int p, int l);
	static int smooth_OffsetStatistics(int p1, int p2, int l1, int l2);
	void fill_OffsetStatistics();
	static int unary_fill_OffsetStatistics(int p, int l);

	// Building Blocks
	void synthesis_BB();
	void prepareShifts_BB();
	void prepareShifts_BBMW();
	void prepareShifts_BBMWBoarder();
	static int unary_BB(int p, int l);
	static int smooth_BB(int p1, int p2, int l1, int l2);
	void fill_BB();
	static int unary_fill_BB(int p, int l);

	// none local
	void synthesis_Nonelocal();
	void prepareShifts_Nonelocal();
	void setNeighbor_Nonelocal();
	static int unary_Nonelocal(int p, int l);
	static int smooth_Nonelocal(int p1, int p2, int l1, int l2);
	int debug_smooth_Nonelocal(int p1, int p2, int l1, int l2);
	static int eval_BBCornerpair_Nonelocal(Point2i pt1, Point2i pt2, int bbtype1, int bbtype2);
	static int eval_BBpair_Nonelocal(Point2i pt1syn, Point2i pt2syn, Point2i pt1input, Point2i pt2input, int bbtype1, int bbtype2);
	static Point2i getoffset_Nonelocal(Point2i pt);

	// misc
	void label2result();
	static bool isValid(int x, int y);
	static bool isValid_fill(int x, int y);
	static bool is4connected(int x, int y);
	static bool is8connected(int p1, int p2);
	static int isBuildingBlockCorner(Point2i pt);
	static int isBuildingBlock(Point2i pt);
	
	//-------------------------------------------------------------
	// variables
	//-------------------------------------------------------------
	//-------------------
	// image data
	//-------------------
	// input image
	QImage* qimgInput_fullres;
	QImage* qimgInput_scaled;
	Mat3b imgInput_fullres;
	Mat3b imgInput_scaled;
	Mat1b imgInputGray_fullres;
	static Mat1b imgInputGray_scaled;

	// input rendering label
	QImage* qimgInputRenderlabel_fullres;
	Mat3b imgInputRenderlabel_fullres;

	// input class label (detection or ground truth)
	QImage* qimgInputlabel_fullres; 
	QImage* qimgInputlabel_scaled;
	Mat1b imgInputlabel_fullres;
	static Mat1b imgInputlabel_scaled;

	// user guide
	QImage* qimgUserGuide_fullres;
	QImage* qimgUserGuide_scaled;
	Mat3b imgUserGuide_fullres;
	Mat3b imgUserGuide_scaled;
	Mat1b imgUserGuideGray_fullres;
	Mat1b imgUserGuideGray_scaled;

	// synthesis
	QImage* qimgSyn_fullres;
	QImage* qimgSyn_scaled;
	QImage* qimgSynlabelColor_fullres;
	QImage* qimgSynRenderlabel_fullres;
	Mat3b imgSyn_fullres;
	Mat3b imgSyn_scaled;
	Mat1b imgSynGray_fullres;
	Mat1b imgSynGray_scaled;
	Mat3b imgSynRenderlabel_fullres;



	QImage* qimgInputlabelinterX_fullres; // input repetition labels
	QImage* qimgInputlabelinterX_scaled;
	QImage* qimgInputlabelinterY_fullres; // input repetition labels
	QImage* qimgInputlabelinterY_scaled;
	Mat1d imgInputlabelinterX_fullres;
	static Mat1d imgInputlabelinterX_scaled;
	Mat1d imgInputlabelinterY_fullres;
	static Mat1d imgInputlabelinterY_scaled;
	static Mat1d imgInputoffsetinterX_scaled;
	static Mat1d imgInputoffsetinterY_scaled;

	// hole filling
	QImage* qimgInputMask_fullres;
	QImage* qimgInputMask_scaled;
	static Mat1d imgInputMask_scaled;

	// dimension
	int rowsInput_fullres;
	int colsInput_fullres;
	static int rowsInput_scaled;
	static int colsInput_scaled;
	int rowsSyn_fullres;
	int colsSyn_fullres;
	static int rowsSyn_scaled;
	static int colsSyn_scaled;
	int numPixelSyn_scaled;
	int numPixelSyn_fullres;

	//-------------------
	// repetition data
	//-------------------
    static int numRep; 
	std::vector<int>sizeRep;
	std::vector<std::vector<int>> repX_fullres; // repetitions X fullres
	std::vector<std::vector<int>> repY_fullres; // repetitions Y fullres
	std::vector<std::vector<int>> repW_fullres; // repetitions W fullres
	std::vector<std::vector<int>> repH_fullres; // repetitions H fullres
	static std::vector<std::vector<int>> repX_scaled; // repetitions X scaled
	static std::vector<std::vector<int>> repY_scaled; // repetitions Y scaled
	std::vector<std::vector<int>> repW_scaled; // repetitions W scaled
	std::vector<std::vector<int>> repH_scaled; // repetitions H scaled


	//-------------------
	// offset data
	//-------------------
    double generatorX_scaled; // a regular generator for expansion in X direction, in percentage
	double generatorY_scaled; // a regular generator for expansion in Y direction, in percentage
	double totalGeneratorX_scaled; // the total expansion in X direction, in percentage
	double totalGeneratorY_scaled; // the total expansion in Y direction, in percentage
	int shiftsPerGenerator_scaled; // a regular generator for expansion, in the resolution of steps
	int totalShiftsX_scaled; // the total number of shifts in X direction 
	int totalShiftsY_scaled; // the total number of shifts in Y direction
	int totalShiftsXY_scaled;
	int colsPerShiftX_scaled;
	int rowsPerShiftY_scaled;
	vector<int> list_shiftX_scaled;
	vector<int> list_shiftY_scaled;
	static vector<Point2i*> list_shiftXY_scaled;
	

	double generatorX_fullres; // a regular generator for expansion in X direction, in percentage
	double generatorY_fullres; // a regular generator for expansion in Y direction, in percentage
	double totalGeneratorX_fulles; // the total expansion in X direction, in percentage
	double totalGeneratorY_fullres; // the total expansion in Y direction, in percentage
	int shiftsPerGenerator_fullres; // a regular generator for expansion, in the resolution of steps
	int totalShiftsX_fullres; // the total number of shifts in X direction 
	int totalShiftsY_fullres; // the total number of shifts in Y direction
	int totalShiftsXY_fullres;
	int colsPerShiftX_fullres;
	int rowsPerShiftY_fullres;
	vector<int> list_shiftX_fullres;
	vector<int> list_shiftY_fullres;
	vector<Point2i*> list_shiftXY_fullres;

	//-------------------
	// generator from offset statistics
	//-------------------
	int numGeneratorsOS;
	vector<Point2i*> generatorsOS_fullres;
	vector<Point2i*> generatorsOS_scaled;

	// graph cut
	GCoptimizationGridGraph *gcGrid;
	GCoptimizationGeneralGraph *gcGeneral;

	Mat1i gcolabelSyn_scaled;
	Mat1i gcolabelSyn_fullres;
	Mat3b gcoBBlabelSynColor_scaled;
	Mat3b gcoBBlabelSynColor_fullres;


	static vector<Point2i*> gcoNodes;

	//-------------------
	// None local
	//-------------------
	int r_Nonelocal_fullres;
	int r_Nonelocal_scaled;
	static std::vector<std::vector<Point2i*>> repOffset_scaled;

	//-------------------
	// gco
	//-------------------
	static int weight_pixel;
	static int weight_label;
	static int weight_labelinter;

	//-------------------
	// rendering
	//-------------------
	vector<vector<double>> colorList;
};

#endif