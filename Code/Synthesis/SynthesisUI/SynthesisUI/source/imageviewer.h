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
	void generateColor10();
	void createActions();
	void createMenus();
	void doSynthesis(const int mode);

private slots:
    void slotOpen();
	void slotExpandX();
	void slotShrinkX();
	void slotExpandY();
	void slotShrinkY();

private:
	// scene
	QScrollArea *scrollArea;
	QGraphicsScene* scene;
	QGraphicsView* view;
	QGraphicsPixmapItem* imgDisp;
	double scaleFactor;

	// data
	Synthesizer* syn;

	// rendering 
	vector<vector<double>> colorList;
	QPen pen;

	// actions
	QAction *openAct;
	QAction *synExpandXAct;
	QAction *synShrinkXAct;
	QAction *synExpandYAct;
	QAction *synShrinkYAct;

	// manus
	QMenu *fileMenu;
	QMenu *editMenu;

protected:

};
//! [0]

#endif
