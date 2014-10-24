#ifndef REP_H
#define REP_H
#include <vector>
#include <QLabel>
#include <QGraphicsView>
#include <QGraphicsScene>
#include <QKeyEvent>
#include <QApplication>
#include <QGraphicsObject>
#include "Para.h"
//#include "SenderObject.h"
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv/cv.h>
#include "gco\GCoptimization.h"
//#include "../src/gui/graphicsview/qgraphicsitem.h"

using namespace cv;

//class BBItem : public QGraphicsPolygonItem, public QObject
//{
//public:
//	BBItem(int a, int b);
//
//	int x_start;
//	int y_start;
//	int idx_s; // index to rec_shift_list
//	int idx_item; // index to rec_bb_list
//	bool flag_changed;
//
//	int x_shift;
//	int y_shift;
//	int x_shift_ori;
//	int y_shift_ori;
//	int bb_type;
//	int bb_idx;
//
//	int x_fullres;
//	int y_fullres;
//	int w_fullres; 
//	int h_fullres;
//	int x_scaled;
//	int y_scaled;
//	int w_scaled; 
//	int h_scaled;
//
//signals:
//
//protected:
//	void mousePressEvent(QGraphicsSceneMouseEvent *event);
//	void mouseReleaseEvent(QGraphicsSceneMouseEvent *event);
//	void mouseMoveEvent(QGraphicsSceneMouseEvent *event);
//	void updateX(QGraphicsSceneMouseEvent *event);
//	void updateY(QGraphicsSceneMouseEvent *event);
//
//private:
//
//};



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
	static int unary_ShiftMap(int p, int l);
	static int smooth_ShiftMap(int p1, int p2, int l1, int l2);
	void fill_ShiftMap();

	// Offset Statistics
	void synthesis_OffsetStatistics();
	void prepareShifts_OffsetStatistics();
	static int unary_OffsetStatistics(int p, int l);
	static int smooth_OffsetStatistics(int p1, int p2, int l1, int l2);
	void fill_OffsetStatistics();
	static int unary_fill_OffsetStatistics(int p, int l);

	// Building Blocks
	void synthesis_BB();
	void prepareShifts_BB();
	static int unary_BB(int p, int l);
	static int smooth_BB(int p1, int p2, int l1, int l2);
	void fill_BB();
	static int unary_fill_BB(int p, int l);

	void label2result();
	static bool isValid(int x, int y);
	static bool isValid_fill(int x, int y);

	//-------------------------------------------------------------
	// variables
	//-------------------------------------------------------------
	//-------------------
	// image data
	//-------------------
	// input image
	QImage* qimgInput_fullres;
	QImage* qimgInput_scaled;
	QLabel* qlabelInput_fullres;
	QLabel* qlabelInput_scaled;
	Mat3b imgInput_fullres;
	Mat3b imgInput_scaled;
	Mat1b imgInputGray_fullres;
	static Mat1b imgInputGray_scaled;

	// input label (detection or ground truth)
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
	QLabel* qlabelSyn_fullres;
	QLabel* qlabelSyn_scaled;
	QLabel* qlabelSynlabelColor_fullres;
	Mat3b imgSyn_fullres;
	Mat3b imgSyn_scaled;
	Mat1b imgSynGray_fullres;
	Mat1b imgSynGray_scaled;

	QImage* qimgInputlabelinterX_fullres; // input repetition labels
	QImage* qimgInputlabelinterX_scaled;
	QImage* qimgInputlabelinterY_fullres; // input repetition labels
	QImage* qimgInputlabelinterY_scaled;
	Mat1d imgInputlabelinterX_fullres;
	static Mat1d imgInputlabelinterX_scaled;
	Mat1d imgInputlabelinterY_fullres;
	static Mat1d imgInputlabelinterY_scaled;

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
	int rowsSyn_scaled;
	int colsSyn_scaled;
	int numPixelSyn_scaled;
	int numPixelSyn_fullres;

	//-------------------
	// repetition data
	//-------------------
    int numRep; 
	std::vector<int>sizeRep;
	std::vector<std::vector<int>> repX_fullres; // repetitions X fullres
	std::vector<std::vector<int>> repY_fullres; // repetitions Y fullres
	std::vector<std::vector<int>> repW_fullres; // repetitions W fullres
	std::vector<std::vector<int>> repH_fullres; // repetitions H fullres
	std::vector<std::vector<int>> repX_scaled; // repetitions X scaled
	std::vector<std::vector<int>> repY_scaled; // repetitions Y scaled
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
	GCoptimizationGridGraph *gc;
	Mat1b gcolabelSyn_scaled;
	Mat1b gcolabelSyn_fullres;
	static vector<Point2i*> gcoNodes;






	//vector<Point2i> gcLabels;
	//Mat1b gcLabel;
	//Mat1d gcLabelinterX;
	//Mat1d gcLabelinterY;
	//Mat1b gcImage;
	//int inputcols;
	//int inputrows;
	//Mat1b gcolabelSyn_fullres;
	//
	//int rowsInput;
	//int colsInput;
	//int rowsSyn;
	//int colsSyn;
	//int rowsPaint;
	//int colsPaint;

	//int numPixelInput;
	//int numPixelSyn;


	//int rowsSyn_fullres;
	//int colsSyn_fullres;
	//int rowsPaint_fullres;
	//int colsPaint_fullres;

	//int num_shift_scaled;
	//int dist_shift_scaled;
	//vector<int> list_shift_scaled;
	//int dist_shift_fullres;
	//vector<int> list_shift_fullres;

	//int num_shift_scaledY;
	//int dist_shift_scaledY;
	//vector<int> list_shift_scaledY;
	//int dist_shift_fullresY;
	//vector<int> list_shift_fullresY;



	//// data related to cooccurrence
	//int numCooC; 
	//vector<int>sizeCooC;
	//vector<vector<int>> coocX_fullres;
	//vector<vector<int>> coocY_fullres;
	//vector<vector<int>> coocX_scaled;
	//vector<vector<int>> coocY_scaled;


	//// cooc votes in the image
	//vector<int>sizeVote;
	//vector<vector<int>> voteX_fullres;
	//vector<vector<int>> voteY_fullres;
	//vector<vector<int>> voteX_scaled;
	//vector<vector<int>> voteY_scaled;

	//Mat1d imgVote_scaled;


	//QImage* qimgInputlabel_fullres; // input repetition labels
	//QImage* qimgInputlabel_scaled;
	//Mat1b imgInputlabel_fullres;
	//Mat1b imgInputlabel_scaled;




	////data related to guidance map
	//Mat1b imgGuide_fullres;
	//Mat1b imgGuide_scaled;

	//vector<int> rec_shift_list;
	//vector<vector<pair<int, int>>> rec_bb_list;


	//vector<int> rec_shift_listY;
	//vector<vector<pair<int, int>>> rec_bb_listY;


	//vector<int> config_shift_list;
	//vector<vector<pair<int, int>>> config_bb_list;



};

#endif