#include <QtGui>
#include "imageviewer.h"

using namespace std;

// member functions
ImageViewer::ImageViewer(){
	method_now = 1;
	pen.setStyle(Qt::SolidLine);
	pen.setWidth(3);

	//-------------------------------------------------------------
	// parse input files and initialize data structures
	//-------------------------------------------------------------
	syn = new Synthesizer;
	switch (method_now){
	case MODE_SHIFTMAP:
		filename_offsetStatisticsInput = "offset statistics file";
		break;
	case MODE_OFFSETSTATISTICS:
		if (flag_MW){
			filename_offsetStatisticsInput = filename_offsetStatisticsPixelMWInput;
		}
		else{
			filename_offsetStatisticsInput = filename_offsetStatisticsPixelInput;
		}
		break;
	case MODE_BB:
		if (flag_MW){
			filename_offsetStatisticsInput = filename_offsetStatisticsPixelMWInput;
		}
		else{
			filename_offsetStatisticsInput = filename_offsetStatisticsPixelInput;
		}
		break;
	default:;
	};
	syn->parsingInput();
	syn->initialization();

	//-------------------------------------------------------------
	// display input image
	//-------------------------------------------------------------
	scene = new QGraphicsScene();
	scene->clear();

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

void ImageViewer::slotOpen(){
	method_now = 1;
	filename_imgInput = QFileDialog::getOpenFileName(this, tr("Open image"), QDir::currentPath());
	filename_offsetStatisticsPixelInput = filename_imgInput;
	filename_offsetStatisticsPixelInput.resize(filename_imgInput.size() - 4);
	filename_offsetStatisticsPixelInput += "OffsetStatisticsPixel.txt";
	filename_offsetStatisticsPixelMWInput = filename_imgInput;
	filename_offsetStatisticsPixelMWInput.resize(filename_imgInput.size() - 4);
	filename_offsetStatisticsPixelMWInput += "OffsetStatisticsPixelMW.txt";
	filename_offsetStatisticsBBInput = filename_imgInput;
	filename_offsetStatisticsBBInput.resize(filename_imgInput.size() - 4);
	filename_offsetStatisticsBBInput += "OffsetStatistics" + name_detection + ".txt";
	filename_offsetStatisticsBBMWInput = filename_imgInput;
	filename_offsetStatisticsBBMWInput.resize(filename_imgInput.size() - 4);
	filename_offsetStatisticsBBMWInput += "OffsetStatistics" + name_detection + "MW.txt";
	filename_offsetStatisticsInput = "offset statistics file";
	filename_repInput = filename_imgInput;
	filename_repInput.resize(filename_imgInput.size() - 4);
	filename_repInput += name_detection + ".txt";
	
	filename_imgMask = filename_imgInput;
	filename_imgMask.resize(filename_imgInput.size() - 4);
	filename_imgMask += "_mask.bmp";
	//qDebug() << filename_imgInput;
	//qDebug() << filename_offsetStatisticsPixelInput;
	//qDebug() << filename_offsetStatisticsBBInput;
	//qDebug() << filename_repInput;

	delete syn;

	//-------------------------------------------------------------
	// initialization
	//-------------------------------------------------------------
	syn = new Synthesizer;
	syn->parsingInput();
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

void ImageViewer::slotSave(){
	filename_imgOutput = filename_imgInput;
	filename_imgOutput.resize(filename_imgInput.size() - 4);
	filename_imgOutput += "_syn_" + QString::number(method_now) + ".png";
	qDebug() << filename_imgOutput;
	if ((syn->totalGeneratorX_scaled > 1) || (syn->totalGeneratorY_scaled > 1)){
		syn->qimgSyn_fullres->save(filename_imgOutput);
	}
	else{
		syn->qimgInput_fullres->save(filename_imgOutput);
	}
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
	qDebug() << "method_now: " << method_now;
	qDebug() << "flag_MW: " << flag_MW;
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
		case MODE_NONELOCAL:
			syn->synthesis_Nonelocal();
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

void ImageViewer::doHoleFilling(const int method_now){

	qDebug() << "-----------------------------------------------------";
	qDebug() << "method_now: " << method_now;
	qDebug() << "flag_MW: " << flag_MW;

	syn->totalGeneratorX_scaled = 1;
	syn->totalGeneratorY_scaled = 1;
	switch (method_now){
	case MODE_SHIFTMAP:
		syn->fill_ShiftMap();
		break;
	case MODE_OFFSETSTATISTICS:
		syn->fill_OffsetStatistics();
		break;
	case MODE_BB:
		syn->fill_BB();
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

void ImageViewer::createActions(){
	openAct = new QAction(tr("&Open..."), this);
	openAct->setShortcut(tr("Ctrl+P"));
	connect(openAct, SIGNAL(triggered()), this, SLOT(slotOpen()));

	saveAct = new QAction(tr("&Save..."), this);
	saveAct->setShortcut(tr("Ctrl+S"));
	connect(saveAct, SIGNAL(triggered()), this, SLOT(slotSave()));

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

	switchMethod1Act = new QAction(tr("&ShiftMap on/off"), this);
	switchMethod1Act->setShortcut(tr("Ctrl+1"));
	connect(switchMethod1Act, SIGNAL(triggered()), this, SLOT(slotSwitchSynMethod1()));

	switchMethod2Act = new QAction(tr("&Offset on/off"), this);
	switchMethod2Act->setShortcut(tr("Ctrl+2"));
	connect(switchMethod2Act, SIGNAL(triggered()), this, SLOT(slotSwitchSynMethod2()));

	switchMethod3Act = new QAction(tr("&BB on/off"), this);
	switchMethod3Act->setShortcut(tr("Ctrl+3"));
	connect(switchMethod3Act, SIGNAL(triggered()), this, SLOT(slotSwitchSynMethod3()));

	switchMethod4Act = new QAction(tr("&Nonelocal on/off"), this);
	switchMethod4Act->setShortcut(tr("Ctrl+4"));
	connect(switchMethod4Act, SIGNAL(triggered()), this, SLOT(slotSwitchSynMethod4()));

	showMontageAct = new QAction(tr("&Montage on/off"), this);
	showMontageAct->setShortcut(tr("Ctrl+M"));
	connect(showMontageAct, SIGNAL(triggered()), this, SLOT(slotShowMontage()));

	switchMWAct = new QAction(tr("MW on/off"), this);
	switchMWAct->setShortcut(tr("Ctrl+R"));
	connect(switchMWAct, SIGNAL(triggered()), this, SLOT(slotSwitchMW()));

	holeFillingAct = new QAction(tr("&Hole Filling"), this);
	holeFillingAct->setShortcut(tr("Ctrl+F"));
	connect(holeFillingAct, SIGNAL(triggered()), this, SLOT(slotHoleFilling()));

}

void ImageViewer::createMenus(){
	fileMenu = new QMenu(tr("&File"), this);
	fileMenu->addAction(openAct);
	fileMenu->addAction(saveAct);
	editMenu = new QMenu(tr("&Edit"), this);
	editMenu->addAction(synExpandXAct);
	editMenu->addAction(synShrinkXAct);
	editMenu->addAction(synExpandYAct);
	editMenu->addAction(synShrinkYAct);
	editMenu->addAction(switchMethod1Act);
	editMenu->addAction(switchMethod2Act);
	editMenu->addAction(switchMethod3Act);
	editMenu->addAction(switchMethod4Act);
	editMenu->addAction(showMontageAct);
	editMenu->addAction(holeFillingAct);
	editMenu->addAction(switchMWAct);
	menuBar()->addMenu(fileMenu);
	menuBar()->addMenu(editMenu);
}

void ImageViewer::slotSwitchSynMethod1(){
	method_now = 1;
    filename_offsetStatisticsInput = "offset statistics file";
	syn->parsingInput();
	syn->initialization();
	doSynthesis(SLOTSWITCHMETHOD);
}

void ImageViewer::slotSwitchSynMethod2(){
	method_now = 2;
	if (flag_MW){
		filename_offsetStatisticsInput = filename_offsetStatisticsPixelMWInput;
	}
	else{
		filename_offsetStatisticsInput = filename_offsetStatisticsPixelInput;
	}
	syn->parsingInput();
	syn->initialization();
	doSynthesis(SLOTSWITCHMETHOD);
}

void ImageViewer::slotSwitchSynMethod3(){
    method_now = 3;
	if (flag_MW){
		filename_offsetStatisticsInput = filename_offsetStatisticsBBMWInput;
		
	}
	else{
		filename_offsetStatisticsInput = filename_offsetStatisticsBBInput;
	}
	syn->parsingInput();
	syn->initialization();
	doSynthesis(SLOTSWITCHMETHOD);
}

void ImageViewer::slotSwitchSynMethod4(){
	//method_now = 4;
	//filename_offsetStatisticsInput = filename_offsetStatisticsPixelInput;
	//syn->initialization();
	//qDebug() << "method_now: " << method_now;
	//doSynthesis(SLOTSWITCHMETHOD);
}

void ImageViewer::slotShowMontage(){
	if (montage_now == 1)
	{
		montage_now = 0;
		// clear the boxes
		//if ((syn->totalGeneratorX_scaled > 1) || (syn->totalGeneratorY_scaled > 1)){
			imgDisp = new QGraphicsPixmapItem(QPixmap::fromImage(*syn->qimgSyn_fullres));
			scene->clear();
			scene->addItem(imgDisp);
			scene->setSceneRect(0, 0, syn->qimgSyn_fullres->width(), syn->qimgSyn_fullres->height());
			view = new QGraphicsView(scene);
			setCentralWidget(view);
			resize(syn->qimgSyn_fullres->width() + 10, syn->qimgSyn_fullres->height() + 50);
		//}
		//else{
		//	imgDisp = new QGraphicsPixmapItem(QPixmap::fromImage(*syn->qimgInput_fullres));
		//	scene->clear();
		//	scene->addItem(imgDisp);
		//	scene->setSceneRect(0, 0, syn->qimgInput_fullres->width(), syn->qimgInput_fullres->height());
		//	view = new QGraphicsView(scene);
		//	setCentralWidget(view);
		//	resize(syn->qimgInput_fullres->width() + 10, syn->qimgInput_fullres->height() + 50);
		//}
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

		//if ((syn->totalGeneratorX_scaled > 1) || (syn->totalGeneratorY_scaled > 1)){
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
		//}
		//else{
		//	imgDisp = new QGraphicsPixmapItem(QPixmap::fromImage(*syn->qimgInput_fullres));
		//	scene->clear();
		//	scene->addItem(imgDisp);
		//	scene->setSceneRect(0, 0, syn->qimgInput_fullres->width(), syn->qimgInput_fullres->height());
		//	view = new QGraphicsView(scene);
		//	setCentralWidget(view);
		//	resize(syn->qimgInput_fullres->width() + 10, syn->qimgInput_fullres->height() + 50);
		//}



	}
}

void ImageViewer::slotHoleFilling(){
	flag_MW = false;
	switch (method_now){
	case MODE_SHIFTMAP:
		filename_offsetStatisticsInput = "offset statistics file";
		break;
	case MODE_OFFSETSTATISTICS:
		if (flag_MW){
			filename_offsetStatisticsInput = filename_offsetStatisticsPixelMWInput;
		}
		else{
			filename_offsetStatisticsInput = filename_offsetStatisticsPixelInput;
		}
		break;
	case MODE_BB:
		if (flag_MW){
			filename_offsetStatisticsInput = filename_offsetStatisticsBBMWInput;
		}
		else{
			filename_offsetStatisticsInput = filename_offsetStatisticsBBInput;
		}
		break;
	default:;
	};

	syn->parsingInput();
	syn->initialization();
	doHoleFilling(method_now);
}

void ImageViewer::slotSwitchMW(){
	if (flag_MW == true){
		flag_MW = false;
	}
	else{
		flag_MW = true;
	}
	syn->parsingInput();
	syn->initialization();
	doSynthesis(SLOTSWITCHMETHOD);
}