#include <QtGui>
#include "imageviewer.h"

using namespace std;

// helper functions
inline vector<double> makeVector3f(float x, float y, float z) {
	vector<double> v;
	v.resize(3);
	v[0] = x; v[1] = y; v[2] = z;
	return v;
}

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

// member functions
ImageViewer::ImageViewer(){
	method_now = 1;

	//-------------------------------------------------------------
	// initialization
	//-------------------------------------------------------------
	syn = new Synthesizer;
	syn->initialization(filename_imgInput, filename_offsetStatisticsInput);

	//-------------------------------------------------------------
	// display input image
	//-------------------------------------------------------------
	scene = new QGraphicsScene();
	imgDisp = new QGraphicsPixmapItem(QPixmap::fromImage(*syn->qimgInput_fullres));
	scene->addItem(imgDisp);
	scene->setSceneRect(0, 0, syn->qimgInput_fullres->width(), syn->qimgInput_fullres->height());
	createActions();
	createMenus();
	view = new QGraphicsView(scene);
	setCentralWidget(view);
	resize(syn->qimgInput_fullres->width() + 10, syn->qimgInput_fullres->height() + 50);
	setWindowTitle(tr("SynthesisUI"));
}

// rendering
void ImageViewer::generateColor10(){
	colorList.resize(10);
	colorList[0] = makeVector3f(102.0, 153.0, 255.0);
	colorList[1] = makeVector3f(255.0, 204.0, 102.0);
	colorList[2] = makeVector3f(102.0, 255.0, 127.0);
	colorList[3] = makeVector3f(102.0, 230.0, 255.0);
	colorList[4] = makeVector3f(255.0, 127.0, 102.0);
	colorList[5] = makeVector3f(230.0, 255.0, 102.0);
	colorList[6] = makeVector3f(102.0, 255.0, 204.0);
	colorList[7] = makeVector3f(255.0, 102.0, 153.0);
	colorList[8] = makeVector3f(204.0, 102.0, 255.0);
	colorList[9] = makeVector3f(153.0, 255.0, 102.0);
}

void ImageViewer::slotOpen(){
	filename_imgInput = QFileDialog::getOpenFileName(this, tr("Open image"), QDir::currentPath());
	filename_offsetStatisticsInput = QFileDialog::getOpenFileName(this, tr("Open offset statistics file"), QDir::currentPath());

	delete syn;

	//-------------------------------------------------------------
	// initialization
	//-------------------------------------------------------------
	syn = new Synthesizer;
	syn->initialization(filename_imgInput, filename_repInput);

	//-------------------------------------------------------------
	// display input image
	//-------------------------------------------------------------
	scene = new QGraphicsScene();
	imgDisp = new QGraphicsPixmapItem(QPixmap::fromImage(*syn->qimgInput_fullres));
	scene->addItem(imgDisp);
	scene->setSceneRect(0, 0, syn->qimgInput_fullres->width(), syn->qimgInput_fullres->height());
	view = new QGraphicsView(scene);
	setCentralWidget(view);
	resize(syn->qimgInput_fullres->width() + 10, syn->qimgInput_fullres->height() + 50);
	setWindowTitle(tr("SynthesisUI"));
}

void ImageViewer::slotExpandX(){
	doSynthesis(SLOTEXPANDX);
}

void ImageViewer::slotShrinkX(){
	doSynthesis(SLOTSHRINKX);
}

void ImageViewer::slotExpandY(){
	doSynthesis(SLOTEXPANDY);
}

void ImageViewer::slotShrinkY(){
	doSynthesis(SLOTSHRINKY);
}

void ImageViewer::doSynthesis(const int act){
	switch (act){
	case SLOTSWITCHMETHOD:
		break;
	case SLOTEXPANDX:
		syn->totalGeneratorX_scaled += syn->generatorX_scaled;
		break;
	case SLOTSHRINKX:
		if (syn->totalGeneratorX_scaled > 1 + syn->generatorX_scaled)
		{
			syn->totalGeneratorX_scaled -= syn->generatorX_scaled;
		}
		else{
			syn->totalGeneratorX_scaled = 1;
		}
		break;
	case SLOTEXPANDY:
		syn->totalGeneratorY_scaled += syn->generatorY_scaled;
		break;
	case SLOTSHRINKY:
		if (syn->totalGeneratorY_scaled > 1 + syn->generatorY_scaled)
		{
			syn->totalGeneratorY_scaled -= syn->generatorY_scaled;
		}
		else{
			syn->totalGeneratorY_scaled = 1;
		}
		break;
	default:;
	};

	qDebug() << "-----------------------------------------------------";
	qDebug() << "X: " << "totalGeneratorX: " << syn->totalGeneratorX_scaled;
	qDebug() << "Y: " << "totalGeneratorY: " << syn->totalGeneratorY_scaled;

	if ((syn->totalGeneratorX_scaled > 1) || (syn->totalGeneratorY_scaled > 1)){
		// synthesis if any of syn->expansion_totalGeneratorX and syn->expansion_totalGeneratorY is larger than one
		qDebug() << "Do synthesis.";

		switch (method_now){
		case MODE_SHIFTMAP:
			syn->synthesis_ShiftMap();
			break;
		case MODE_OFFSETSTATISTICS:
			syn->synthesis_OffsetStatistics();
			break;
		case MODE_BB:
			syn->synthesis_BB();
			break;
		default:;
		};

		imgDisp = new QGraphicsPixmapItem(QPixmap::fromImage(*syn->qimgSyn_fullres));
		scene->addItem(imgDisp);
		scene->setSceneRect(0, 0, syn->qimgSyn_fullres->width(), syn->qimgSyn_fullres->height());
		view = new QGraphicsView(scene);
		setCentralWidget(view);
		resize(syn->qimgSyn_fullres->width() + 10, syn->qimgSyn_fullres->height() + 50);
	}
	else{
		// otherwise show the input image 
		qDebug() << "Show input.";
		qDebug() << "colsSyn_scaled: " << syn->qimgInput_scaled->width() << ", rowsSyn_scaled: " << syn->qimgInput_scaled->height();
		imgDisp = new QGraphicsPixmapItem(QPixmap::fromImage(*syn->qimgInput_fullres));
		scene->addItem(imgDisp);
		scene->setSceneRect(0, 0, syn->qimgInput_fullres->width(), syn->qimgInput_fullres->height());
		view = new QGraphicsView(scene);
		setCentralWidget(view);
		resize(syn->qimgInput_fullres->width() + 10, syn->qimgInput_fullres->height() + 50);
	}

}

void ImageViewer::createActions(){
	openAct = new QAction(tr("&Open..."), this);
	openAct->setShortcut(tr("Ctrl+P"));
	connect(openAct, SIGNAL(triggered()), this, SLOT(slotOpen()));

	synExpandXAct = new QAction(tr("&Expand X"), this);
	synExpandXAct->setShortcut(tr("Ctrl+Right"));
	connect(synExpandXAct, SIGNAL(triggered()), this, SLOT(slotExpandX()));

	synShrinkXAct = new QAction(tr("&Shrink X"), this);
	synShrinkXAct->setShortcut(tr("Ctrl+Left"));
	connect(synShrinkXAct, SIGNAL(triggered()), this, SLOT(slotShrinkX()));

	synExpandYAct = new QAction(tr("&Expand Y"), this);
	synExpandYAct->setShortcut(tr("Ctrl+Up"));
	connect(synExpandYAct, SIGNAL(triggered()), this, SLOT(slotExpandY()));

	synShrinkYAct = new QAction(tr("&ShrinkY"), this);
	synShrinkYAct->setShortcut(tr("Ctrl+Down"));
	connect(synShrinkYAct, SIGNAL(triggered()), this, SLOT(slotShrinkY()));

	swithMethod1Act = new QAction(tr("&ShiftMap on/off"), this);
	swithMethod1Act->setShortcut(tr("Ctrl+1"));
	connect(swithMethod1Act, SIGNAL(triggered()), this, SLOT(swithMethod1()));

	swithMethod2Act = new QAction(tr("&Offset on/off"), this);
	swithMethod2Act->setShortcut(tr("Ctrl+2"));
	connect(swithMethod2Act, SIGNAL(triggered()), this, SLOT(swithMethod2()));

	swithMethod3Act = new QAction(tr("&BB on/off"), this);
	swithMethod3Act->setShortcut(tr("Ctrl+3"));
	connect(swithMethod3Act, SIGNAL(triggered()), this, SLOT(swithMethod3()));
}

void ImageViewer::createMenus(){
	fileMenu = new QMenu(tr("&File"), this);
	fileMenu->addAction(openAct);
	editMenu = new QMenu(tr("&Edit"), this);
	editMenu->addAction(synExpandXAct);
	editMenu->addAction(synShrinkXAct);
	editMenu->addAction(synExpandYAct);
	editMenu->addAction(synShrinkYAct);
	editMenu->addAction(swithMethod1Act);
	editMenu->addAction(swithMethod2Act);
	editMenu->addAction(swithMethod3Act);
	menuBar()->addMenu(fileMenu);
	menuBar()->addMenu(editMenu);
}

void ImageViewer::swithMethod1(){
	method_now = 1;
	qDebug() << "method_now: " << method_now;
	doSynthesis(SLOTSWITCHMETHOD);
}

void ImageViewer::swithMethod2(){
	method_now = 2;
	qDebug() << "method_now: " << method_now;
	doSynthesis(SLOTSWITCHMETHOD);
}

void ImageViewer::swithMethod3(){
    method_now = 3;
	qDebug() << "method_now: " << method_now;
	doSynthesis(SLOTSWITCHMETHOD);
}