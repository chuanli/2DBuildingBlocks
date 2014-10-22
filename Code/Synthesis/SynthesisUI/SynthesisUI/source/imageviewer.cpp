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



// member functions
ImageViewer::ImageViewer(){
	method_now = 1;

	pen.setStyle(Qt::SolidLine);
	pen.setWidth(3);

	//-------------------------------------------------------------
	// initialization
	//-------------------------------------------------------------


	syn = new Synthesizer;

	switch (method_now){
	case MODE_SHIFTMAP:
		filename_offsetStatisticsInput = "";
		break;
	case MODE_OFFSETSTATISTICS:
		filename_offsetStatisticsInput = filename_offsetStatisticsPixelInput;
		break;
	case MODE_BB:
		filename_offsetStatisticsInput = filename_offsetStatisticsBBInput;
		break;
	default:;
	};

	syn->initialization();

	//-------------------------------------------------------------
	// display input image
	//-------------------------------------------------------------
	scene = new QGraphicsScene();
	scene->clear();
	
	//

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
	method_now = 1;

	filename_imgInput = QFileDialog::getOpenFileName(this, tr("Open image"), QDir::currentPath());
	filename_offsetStatisticsPixelInput = filename_imgInput;
	filename_offsetStatisticsPixelInput.resize(filename_imgInput.size() - 4);
	filename_offsetStatisticsPixelInput += "OffsetStatisticsPixel.txt";
	filename_offsetStatisticsBBInput = filename_imgInput;
	filename_offsetStatisticsBBInput.resize(filename_imgInput.size() - 4);
	filename_offsetStatisticsBBInput += "OffsetStatistics" + append_BB + ".txt";
	filename_offsetStatisticsInput = "";
	filename_repInput = filename_imgInput;
	filename_repInput.resize(filename_imgInput.size() - 4);
	filename_repInput += append_BB + ".txt";
	

	qDebug() << filename_imgInput;
	qDebug() << filename_offsetStatisticsPixelInput;
	qDebug() << filename_offsetStatisticsBBInput;
	qDebug() << filename_repInput;

	delete syn;

	//-------------------------------------------------------------
	// initialization
	//-------------------------------------------------------------
	syn = new Synthesizer;
	syn->initialization();

	//-------------------------------------------------------------
	// display input image
	//-------------------------------------------------------------
	scene = new QGraphicsScene();
	imgDisp = new QGraphicsPixmapItem(QPixmap::fromImage(*syn->qimgInput_fullres));
	scene->clear();
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
		scene->clear();
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
		scene->clear();
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

	showMontageAct = new QAction(tr("&Montage on/off"), this);
	showMontageAct->setShortcut(tr("Ctrl+M"));
	connect(showMontageAct, SIGNAL(triggered()), this, SLOT(showMontage()));
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
	editMenu->addAction(showMontageAct);
	menuBar()->addMenu(fileMenu);
	menuBar()->addMenu(editMenu);
}

void ImageViewer::swithMethod1(){
	method_now = 1;
	switch (method_now){
	case MODE_SHIFTMAP:
		filename_offsetStatisticsInput = "";
		break;
	case MODE_OFFSETSTATISTICS:
		filename_offsetStatisticsInput = filename_offsetStatisticsPixelInput;
		break;
	case MODE_BB:
		filename_offsetStatisticsInput = filename_offsetStatisticsBBInput;
		break;
	default:;
	};

	syn->initialization();
	qDebug() << "method_now: " << method_now;
	doSynthesis(SLOTSWITCHMETHOD);
}

void ImageViewer::swithMethod2(){
	method_now = 2;
	switch (method_now){
	case MODE_SHIFTMAP:
		filename_offsetStatisticsInput = "";
		break;
	case MODE_OFFSETSTATISTICS:
		filename_offsetStatisticsInput = filename_offsetStatisticsPixelInput;
		break;
	case MODE_BB:
		filename_offsetStatisticsInput = filename_offsetStatisticsBBInput;
		break;
	default:;
	};

	syn->initialization();
	qDebug() << "method_now: " << method_now;
	doSynthesis(SLOTSWITCHMETHOD);
}

void ImageViewer::swithMethod3(){
    method_now = 3;
	switch (method_now){
	case MODE_SHIFTMAP:
		filename_offsetStatisticsInput = "";
		break;
	case MODE_OFFSETSTATISTICS:
		filename_offsetStatisticsInput = filename_offsetStatisticsPixelInput;
		break;
	case MODE_BB:
		filename_offsetStatisticsInput = filename_offsetStatisticsBBInput;
		break;
	default:;
	};

	syn->initialization();
	qDebug() << "method_now: " << method_now;
	doSynthesis(SLOTSWITCHMETHOD);
}

void ImageViewer::showMontage(){
	if (montage_now == 1)
	{
		montage_now = 0;
		// clear the boxes
		if ((syn->totalGeneratorX_scaled > 1) || (syn->totalGeneratorY_scaled > 1)){
			imgDisp = new QGraphicsPixmapItem(QPixmap::fromImage(*syn->qimgSyn_fullres));
			scene->clear();
			scene->addItem(imgDisp);
			scene->setSceneRect(0, 0, syn->qimgSyn_fullres->width(), syn->qimgSyn_fullres->height());
			view = new QGraphicsView(scene);
			setCentralWidget(view);
			resize(syn->qimgSyn_fullres->width() + 10, syn->qimgSyn_fullres->height() + 50);
		}
		else{
			imgDisp = new QGraphicsPixmapItem(QPixmap::fromImage(*syn->qimgInput_fullres));
			scene->clear();
			scene->addItem(imgDisp);
			scene->setSceneRect(0, 0, syn->qimgInput_fullres->width(), syn->qimgInput_fullres->height());
			view = new QGraphicsView(scene);
			setCentralWidget(view);
			resize(syn->qimgInput_fullres->width() + 10, syn->qimgInput_fullres->height() + 50);
		}
	}
	else{
		montage_now = 1;
		// add boxes
		vector<QGraphicsRectItem*> montage;
		montage.resize(syn->totalShiftsXY_fullres);
		for (int i = 0; i < syn->totalShiftsXY_fullres; i++){
			montage[i] = new QGraphicsRectItem(syn->list_shiftXY_fullres[i]->x, syn->list_shiftXY_fullres[i]->y, syn->colsInput_fullres, syn->rowsInput_fullres);
			montage[i]->setPen(pen);
			montage[i]->setBrush(Qt::NoBrush);
		}

		resize(syn->qimgSyn_fullres->width() + 10, syn->qimgSyn_fullres->height() + 50);

		if ((syn->totalGeneratorX_scaled > 1) || (syn->totalGeneratorY_scaled > 1)){
			imgDisp = new QGraphicsPixmapItem(QPixmap::fromImage(*syn->qimgSyn_fullres));
			scene->clear();
			scene->addItem(imgDisp);
			for (int i = 0; i < syn->totalShiftsXY_fullres; i++){
				scene->addItem(montage[i]);
			}
			scene->setSceneRect(0, 0, syn->qimgSyn_fullres->width(), syn->qimgSyn_fullres->height());
			view = new QGraphicsView(scene);
			setCentralWidget(view);
			resize(syn->qimgSyn_fullres->width() + 10, syn->qimgSyn_fullres->height() + 50);
		}
		else{
			imgDisp = new QGraphicsPixmapItem(QPixmap::fromImage(*syn->qimgInput_fullres));
			scene->clear();
			scene->addItem(imgDisp);
			scene->setSceneRect(0, 0, syn->qimgInput_fullres->width(), syn->qimgInput_fullres->height());
			view = new QGraphicsView(scene);
			setCentralWidget(view);
			resize(syn->qimgInput_fullres->width() + 10, syn->qimgInput_fullres->height() + 50);
		}



	}
}