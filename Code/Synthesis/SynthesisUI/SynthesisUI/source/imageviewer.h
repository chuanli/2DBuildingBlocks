#ifndef IMAGEVIEWER_H
#define IMAGEVIEWER_H

#include <QMainWindow>
#include <QGraphicsView>
#include <QGraphicsScene>
#include <QPrinter>
#include <QString>
#include "Synthesizer.h"
#include "Para.h"

#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv/cv.h>
using namespace cv;

QT_BEGIN_NAMESPACE
class QAction;
class QLabel;
class QMenu;
class QScrollArea;
class QScrollBar;
QT_END_NAMESPACE


class ImageViewer : public QMainWindow
{
    Q_OBJECT

public:
	ImageViewer();
	void RepIni();
	void RepPrep();

	// rendering
	//void generateColor10();
	void createActions();
	void createMenus();
	void doSynthesis(const int act);
	void doHoleFilling(const int method_now);

private slots:
    void slotOpen();
	void slotSave();
	void slotExpandX();
	void slotShrinkX();
	void slotExpandY();
	void slotShrinkY();
	void slotSwitchSynMethod1();
	void slotSwitchSynMethod2();
	void slotSwitchSynMethod3();
	void slotSwitchSynMethod4();
	void slotShowMontage();
	void slotHoleFilling();


private:
	// scene
	QGraphicsScene* scene;
	QGraphicsView* view;
	QGraphicsPixmapItem* imgDisp;
	QPainter painter;

	// data
	Synthesizer* syn;

	// montage control
	int montage_now;

	// rendering 
	//vector<vector<double>> colorList;
	QPen pen;

	// actions
	QAction *openAct;
	QAction *saveAct;
	QAction *synExpandXAct;
	QAction *synShrinkXAct;
	QAction *synExpandYAct;
	QAction *synShrinkYAct;
	QAction *switchMethod1Act;
	QAction *switchMethod2Act;
	QAction *switchMethod3Act;
	QAction *switchMethod4Act;
	QAction *showMontageAct;
	QAction *holeFillingAct;

	// manus
	QMenu *fileMenu;
	QMenu *editMenu;

protected:

};
//! [0]

#endif
