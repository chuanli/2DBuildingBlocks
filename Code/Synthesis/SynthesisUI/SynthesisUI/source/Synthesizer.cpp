#include "Synthesizer.h"
#include <QDebug>

//inline double round( double d )
//{
//	return floor( d + 0.5 );
//}
//
//BBItem::BBItem(int a, int b):idx_s(a), idx_item(b){
//	flag_changed = false;
//	setFlag(ItemIsMovable);
//	setFlag(ItemIsSelectable);
//	setFlag(ItemSendsGeometryChanges);
//	setCacheMode(DeviceCoordinateCache);
//	setZValue(-1);
//}
//
//void BBItem::mousePressEvent(QGraphicsSceneMouseEvent *event)
//{
//	
//	//update();
//	flag_changed = true;
//	QGraphicsPolygonItem::mousePressEvent(event);
//	//qDebug()<<"mouse pressed"<<", x: "<<this->x()<<", y: "<<this->y();
//	qDebug()<<flag_sideselection;
//	if (flag_sideselection)
//	{
//		if (flag_scribble)
//		{
//			//qDebug()<<"to pick up this color";
//			sel_bb_type = bb_type;
//			globalsender->sendsinglechangebbtype();
//		} 
//		else
//		{
//			// add this item to the main scene
//			// need to record i_rep and j_rep and send a signal to mainwindow for update
//			sel_bb_type = bb_type;
//			sel_bb_idx = bb_idx;
//			//qDebug()<<bb_type<<bb_idx;
//			globalsender->sendsignaladditem();
//		}
//
//	}
//}
//
//
//void BBItem::mouseReleaseEvent(QGraphicsSceneMouseEvent *event)
//{
//	if (flag_syn_Y)
//	{
//		updateY(event);
//	} 
//	else
//	{
//		updateX(event);
//	}
//}
//
//void BBItem::updateX(QGraphicsSceneMouseEvent *event){
//
//	qDebug()<<"mouse released"<<", x: "<<this->x()<<", y: "<<this->y();
//	// need to rectify the position of this item
//	// first, the y position should not be changed
//	if (flag_sideselection)
//	{
//
//	} 
//	else
//	{
//		if (flag_multiselection)
//		{
//			// update all selected items
//			QList<QGraphicsItem *> itemSelected = this->scene()->selectedItems();
//			double min_x = 1000000;
//			double max_x = -1;
//			for (int i_item = 0; i_item < itemSelected.size(); i_item++)
//			{
//				QRectF Recttemp = itemSelected[i_item]->boundingRect();
//				min_x = qMin(min_x, round((Recttemp.x() + itemSelected[i_item]->x()) * scalerRes - 1)/scalerRes);
//				max_x = qMax(max_x, round((Recttemp.x() + Recttemp.width() + itemSelected[i_item]->x()) * scalerRes + 1)/scalerRes);
//			}
//			int shift_correction = 0;
//			if (min_x < 0 )
//			{
//				shift_correction = -min_x;
//			} 
//			else if (max_x >= global_colsSyn_fullres)
//			{
//				shift_correction = global_colsSyn_fullres - max_x - 1;
//			}
//
//			qDebug()<<min_x<<max_x<<shift_correction;
//
//			for (int i_item = 0; i_item < itemSelected.size(); i_item++)
//			{
//				int newx = round(((double)itemSelected[i_item]->x() + shift_correction) * scalerRes)/scalerRes;
//				itemSelected[i_item]->setPos(newx, 0);
//			}
//			update();
//			QGraphicsPolygonItem::mouseReleaseEvent(event);
//		}
//		else{
//			// update a single item
//			int newx = round((double)this->x() * scalerRes)/scalerRes;
//			// need to make sure do not cross input image boundary
//			qDebug()<<"before boundary check: "<<newx<<", w_fullres:"<<w_fullres<<", x_fullres: "<<x_fullres<<", x_shift_ori: "<<x_shift_ori/scalerRes;
//
//			if ((newx + x_fullres + x_shift_ori/scalerRes) < 0)
//			{
//				newx = round((double)(-x_fullres - x_shift_ori/scalerRes) * scalerRes + 1)/scalerRes;
//			} 
//			else if (newx + w_fullres + x_fullres + x_shift_ori/scalerRes >= global_colsSyn_fullres)
//			{
//				newx = round((double)(global_colsSyn_fullres - x_fullres - w_fullres - x_shift_ori/scalerRes) * scalerRes - 1)/scalerRes;
//			}
//			qDebug()<<"after boundary check: "<<newx<<", w_fullres:"<<w_fullres<<", x_fullres: "<<x_fullres<<", x_shift_ori: "<<x_shift_ori/scalerRes;
//
//			this->setPos(newx, this->y_start);
//			update();
//			QGraphicsPolygonItem::mouseReleaseEvent(event);
//			globalsender->sendsignal();
//		}
//	}
//	//qDebug()<<"mouse released"<<", x: "<<this->x()<<", y: "<<this->y();
//	// // send signal to QMainwindow
//}
//
//void BBItem::updateY(QGraphicsSceneMouseEvent *event){
//	qDebug()<<"mouse released"<<", x: "<<this->x()<<", y: "<<this->y();
//	// need to rectify the position of this item
//	// first, the y position should not be changed
//	if (flag_sideselection)
//	{
//
//	} 
//	else
//	{
//		if (flag_multiselection)
//		{
//			// update all selected items
//			QList<QGraphicsItem *> itemSelected = this->scene()->selectedItems();
//			double min_y = 1000000;
//			double max_y = -1;
//			for (int i_item = 0; i_item < itemSelected.size(); i_item++)
//			{
//				QRectF Recttemp = itemSelected[i_item]->boundingRect();
//				min_y = qMin(min_y, round((Recttemp.y() + itemSelected[i_item]->y()) * scalerRes - 1)/scalerRes);
//				max_y = qMax(max_y, round((Recttemp.y() + Recttemp.width() + itemSelected[i_item]->y()) * scalerRes + 1)/scalerRes);
//			}
//
//			int shift_correction = 0;
//			if (min_y < 0 )
//			{
//				shift_correction = -min_y;
//			} 
//			else if (max_y >= global_rowsSyn_fullres)
//			{
//				shift_correction = global_rowsSyn_fullres - max_y - 1;
//			}
//
//			qDebug()<<min_y<<max_y<<shift_correction;
//
//			for (int i_item = 0; i_item < itemSelected.size(); i_item++)
//			{
//				int newy = round(((double)itemSelected[i_item]->y() + shift_correction) * scalerRes)/scalerRes;
//				itemSelected[i_item]->setPos(0, newy);
//			}
//
//			update();
//			QGraphicsPolygonItem::mouseReleaseEvent(event);
//		}
//		else{
//			// update a single item
//			int newy = round((double)this->y() * scalerRes)/scalerRes;
//			// need to make sure do not cross input image boundary
//			qDebug()<<"before boundary check: "<<newy<<", h_fullres:"<<h_fullres<<", y_fullres: "<<y_fullres<<", y_shift_ori: "<<y_shift_ori/scalerRes;
//
//			if ((newy + y_fullres + y_shift_ori/scalerRes) < 0)
//			{
//				newy = round((double)(-y_fullres - y_shift_ori/scalerRes) * scalerRes + 1)/scalerRes;
//			} 
//			else if (newy + h_fullres + y_fullres + y_shift_ori/scalerRes >= global_rowsSyn_fullres)
//			{
//				newy = round((double)(global_rowsSyn_fullres - y_fullres - h_fullres - y_shift_ori/scalerRes) * scalerRes - 1)/scalerRes;
//			}
//			qDebug()<<"after boundary check: "<<newy<<", h_fullres:"<<h_fullres<<", y_fullres: "<<y_fullres<<", y_shift_ori: "<<y_shift_ori/scalerRes;
//
//			this->setPos(this->x_start, newy);
//			update();
//			QGraphicsPolygonItem::mouseReleaseEvent(event);
//			globalsender->sendsignal();
//		}
//	}
//	//qDebug()<<"mouse released"<<", x: "<<this->x()<<", y: "<<this->y();
//	// // send signal to QMainwindow
//}
//
////void BBItem::mouseReleaseEvent(QGraphicsSceneMouseEvent *event)
////{
////	qDebug()<<"mouse released"<<", x: "<<this->x()<<", y: "<<this->y();
////	// need to rectify the position of this item
////	// first, the y position should not be changed
////	if (flag_sideselection)
////	{
////
////	} 
////	else
////	{
////		if (flag_multiselection)
////		{
////			// update all selected items
////			QList<QGraphicsItem *> itemSelected = this->scene()->selectedItems();
////			double min_x = 1000000;
////			double max_x = -1;
////			for (int i_item = 0; i_item < itemSelected.size(); i_item++)
////			{
////				QRectF Recttemp = itemSelected[i_item]->boundingRect();
////				min_x = qMin(min_x, round((Recttemp.x() + itemSelected[i_item]->x()) * scalerRes - 1)/scalerRes);
////				max_x = qMax(max_x, round((Recttemp.x() + Recttemp.width() + itemSelected[i_item]->x()) * scalerRes + 1)/scalerRes);
////			}
////
////			int shift_correction = 0;
////			if (min_x < 0 )
////			{
////				shift_correction = -min_x;
////			} 
////			else if (max_x >= global_colsSyn_fullres)
////			{
////				shift_correction = global_colsSyn_fullres - max_x - 1;
////			}
////
////			qDebug()<<min_x<<max_x<<shift_correction;
////
////			for (int i_item = 0; i_item < itemSelected.size(); i_item++)
////			{
////				int newx = round(((double)itemSelected[i_item]->x() + shift_correction) * scalerRes)/scalerRes;
////				itemSelected[i_item]->setPos(newx, 0);
////			}
////
////			update();
////			QGraphicsPolygonItem::mouseReleaseEvent(event);
////		}
////		else{
////			// update a single item
////			int newx = round((double)this->x() * scalerRes)/scalerRes;
////			// need to make sure do not cross input image boundary
////			qDebug()<<"before boundary check: "<<newx<<", w_fullres:"<<w_fullres<<", x_fullres: "<<x_fullres<<", x_shift_ori: "<<x_shift_ori/scalerRes;
////
////			if ((newx + x_fullres + x_shift_ori/scalerRes) < 0)
////			{
////				newx = round((double)(-x_fullres - x_shift_ori/scalerRes) * scalerRes + 1)/scalerRes;
////			} 
////			else if (newx + w_fullres + x_fullres + x_shift_ori/scalerRes >= global_colsSyn_fullres)
////			{
////				newx = round((double)(global_colsSyn_fullres - x_fullres - w_fullres - x_shift_ori/scalerRes) * scalerRes - 1)/scalerRes;
////			}
////			qDebug()<<"after boundary check: "<<newx<<", w_fullres:"<<w_fullres<<", x_fullres: "<<x_fullres<<", x_shift_ori: "<<x_shift_ori/scalerRes;
////
////			this->setPos(newx, this->y_start);
////			update();
////			QGraphicsPolygonItem::mouseReleaseEvent(event);
////			globalsender->sendsignal();
////		}
////	}
////
////
////	//qDebug()<<"mouse released"<<", x: "<<this->x()<<", y: "<<this->y();
////	// // send signal to QMainwindow
////}
//
//void BBItem::mouseMoveEvent(QGraphicsSceneMouseEvent *event)
//{
//	//int newx = round((double)this->x() * scalerRes)/scalerRes;
//	//this->setPos(newx, this->y_start);
//	update();
//	QGraphicsPolygonItem::mouseMoveEvent(event);
//}
//
//
////void BBItem::paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget){  
////	Q_UNUSED(option);  
////    Q_UNUSED(widget);
////	painter->drawRect(0, 0, 10, 10);
////}

int Synthesizer::rowsInput_scaled;
int Synthesizer::colsInput_scaled;
vector<Point2i*> Synthesizer::list_shiftXY_scaled;
vector<Point2i*> Synthesizer::gcoNodes;
Mat1b Synthesizer::imgInputGray_scaled;
Mat1b Synthesizer::imgInputlabel_scaled;
Mat1d Synthesizer::imgInputlabelinterX_scaled;
Mat1d Synthesizer::imgInputlabelinterY_scaled;

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

Synthesizer::Synthesizer(void){
	// input 
	qimgInput_fullres = new QImage;
    qimgInput_scaled = new QImage;
	qlabelInput_fullres = new QLabel;
	qlabelInput_scaled = new QLabel;

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
	qlabelSyn_fullres = new QLabel;
	qlabelSyn_scaled = new QLabel;
	qlabelSynlabelColor_fullres = new QLabel;
	qimgInputlabelinterX_fullres = new QImage;
	qimgInputlabelinterX_scaled = new QImage;
	qimgInputlabelinterY_fullres = new QImage;
	qimgInputlabelinterY_scaled = new QImage;

	generatorX_scaled = 0.05; // a regular generator for expansion in X direction, in percentage
	generatorY_scaled = 0.05; // a regular generator for expansion in Y direction, in percentage
	totalGeneratorX_scaled = 1.0; // the total expansion in X direction, in percentage
	totalGeneratorY_scaled = 1.0; // the total expansion in Y direction, in percentage
	shiftsPerGenerator_scaled = 2; // a regular generator for expansion, in the resolution of shifts
	totalShiftsX_scaled = 1; // the total number of shifts in X direction 
	totalShiftsY_scaled = 1; // the total number of shifts in Y direction


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
    qlabelInput_fullres->setPixmap(QPixmap::fromImage(*qimgInput_fullres));
	*qimgInput_scaled = qimgInput_fullres->scaled(qimgInput_fullres->size() * scalerRes, Qt::KeepAspectRatio, Qt::SmoothTransformation);
	qlabelInput_scaled->setPixmap(QPixmap::fromImage(*qimgInput_scaled));

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
	for (int i_rep = 0; i_rep < numRep; i_rep++)
	{
		for (int j_rep = 0; j_rep < sizeRep[i_rep]; j_rep++)
		{
			cv::Mat1d X, Y;
			meshgridTest(cv::Range(0, repW_scaled[i_rep][j_rep] - 1), cv::Range(0, repH_scaled[i_rep][j_rep] - 1), X, Y);
			X = X * ((double)1 / (double)max(1, repW_scaled[i_rep][j_rep]));
			Y = Y * ((double)1 / (double)max(1, repH_scaled[i_rep][j_rep]));
			X.copyTo(imgInputlabelinterX_scaled(Range(repY_scaled[i_rep][j_rep], repY_scaled[i_rep][j_rep] + repH_scaled[i_rep][j_rep]), Range(repX_scaled[i_rep][j_rep], repX_scaled[i_rep][j_rep] + repW_scaled[i_rep][j_rep])));
			Y.copyTo(imgInputlabelinterY_scaled(Range(repY_scaled[i_rep][j_rep], repY_scaled[i_rep][j_rep] + repH_scaled[i_rep][j_rep]), Range(repX_scaled[i_rep][j_rep], repX_scaled[i_rep][j_rep] + repW_scaled[i_rep][j_rep])));
		}
	}

	// make maps for rep internal labels
	imgInputlabelinterX_fullres = Mat1d::zeros(rowsInput_fullres, colsInput_fullres);
	imgInputlabelinterY_fullres = Mat1d::zeros(rowsInput_fullres, colsInput_fullres);
	for (int i_rep = 0; i_rep < numRep; i_rep++)
	{
		for (int j_rep = 0; j_rep < sizeRep[i_rep]; j_rep++)
		{
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
	gc = new GCoptimizationGridGraph(colsSyn_scaled, rowsSyn_scaled, totalShiftsXY_scaled);

	// set unary cost
	gc->setDataCost(&unary_ShiftMap);

	// set smoothness cost
	gc->setSmoothCost(&smooth_ShiftMap);

	// optimize
	qDebug() << "Before optimization energy is " << gc->compute_energy();
	for (int i = 0; i < 2; i++){
		gc->expansion(1);// run expansion for 2 iterations. For swap use gc->swap(num_iterations);
		qDebug() << "after expansion energy is " << gc->compute_energy();
		gc->swap(1);// run expansion for 2 iterations. For swap use gc->swap(num_iterations);
		qDebug() << "after swap energy is " << gc->compute_energy();
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
	gcolabelSyn_scaled = Mat1b::zeros(rowsSyn_scaled, colsSyn_scaled);
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

// Offset Statistics
void Synthesizer::synthesis_OffsetStatistics(){
	qDebug() << "Synthesis starts (Offset Statistics) ... ";

	// Prepare shifts
	prepareShifts_OffsetStatistics();


	// setup graph cut problem
	//qDebug() << "colsSyn_scaled: " << colsSyn_scaled << ", rowsSyn_scaled: " << rowsSyn_scaled << ", totalShiftsXY_scaled: " << totalShiftsXY_scaled;
	gc = new GCoptimizationGridGraph(colsSyn_scaled, rowsSyn_scaled, totalShiftsXY_scaled);

	// set unary cost
	gc->setDataCost(&unary_OffsetStatistics);
	//gc->setDataCost(&unary_BB);

	// set smoothness cost
	gc->setSmoothCost(&smooth_OffsetStatistics);
	//gc->setSmoothCost(&smooth_BB);

	// optimize
	qDebug() << "Before optimization energy is " << gc->compute_energy();
	for (int i = 0; i < 4; i++){
		gc->expansion(1);// run expansion for 2 iterations. For swap use gc->swap(num_iterations);
		qDebug() << "after expansion energy is " << gc->compute_energy();
		gc->swap(1);// run expansion for 2 iterations. For swap use gc->swap(num_iterations);
		qDebug() << "after swap energy is " << gc->compute_energy();
	}

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
	gcolabelSyn_scaled = Mat1b::zeros(rowsSyn_scaled, colsSyn_scaled);


	// find the generator zone (the expansion zone spanned by one generator at each corner)
	std::vector<int> zone_expansion_x;
	std::vector<int> zone_expansion_y;
	std::vector<int> zone_generator_x;
	std::vector<int> zone_generator_y;
	zone_expansion_x.resize(4);
	zone_expansion_y.resize(4);
	zone_expansion_x[0] = 0;
	zone_expansion_x[1] = colsSyn_scaled - colsInput_scaled;
	zone_expansion_x[2] = colsSyn_scaled - colsInput_scaled;
	zone_expansion_x[3] = 0;
	zone_expansion_y[0] = 0;
	zone_expansion_y[1] = rowsSyn_scaled - rowsInput_scaled;
	zone_expansion_y[2] = 0;
	zone_expansion_y[3] = rowsSyn_scaled - rowsInput_scaled;
	zone_generator_x.resize(16);
	zone_generator_y.resize(16);
	for (int i = 0; i < 4; i++){
		zone_generator_x[i * 4] = zone_expansion_x[i] - generatorsOS_scaled[0]->x + generatorsOS_scaled[1]->x;
		zone_generator_x[i * 4 + 1] = zone_expansion_x[i] + generatorsOS_scaled[0]->x + generatorsOS_scaled[1]->x;
		zone_generator_x[i * 4 + 2] = zone_expansion_x[i] + generatorsOS_scaled[0]->x - generatorsOS_scaled[1]->x;
		zone_generator_x[i * 4 + 3] = zone_expansion_x[i] - generatorsOS_scaled[0]->x - generatorsOS_scaled[1]->x;
		zone_generator_y[i * 4] = zone_expansion_y[i] - generatorsOS_scaled[0]->y + generatorsOS_scaled[1]->y;
		zone_generator_y[i * 4 + 1] = zone_expansion_y[i] + generatorsOS_scaled[0]->y + generatorsOS_scaled[1]->y;
		zone_generator_y[i * 4 + 2] = zone_expansion_y[i] + generatorsOS_scaled[0]->y - generatorsOS_scaled[1]->y;
		zone_generator_y[i * 4 + 3] = zone_expansion_y[i] - generatorsOS_scaled[0]->y - generatorsOS_scaled[1]->y;
	}
	int min_x = *min_element(zone_generator_x.begin(), zone_generator_x.end());
	int min_y = *min_element(zone_generator_y.begin(), zone_generator_y.end());
	int max_x = *max_element(zone_generator_x.begin(), zone_generator_x.end());
	int max_y = *max_element(zone_generator_y.begin(), zone_generator_y.end());

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
			if (intersect_x >= 0 && intersect_y >= 0)
			{
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
					if (list_shiftXY_scaled[z]->x == x && list_shiftXY_scaled[z]->y == y)
					{
						flag_in = true;
						break;
					}
				}
				if (!flag_in)
				{
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

// Building Blocks
void Synthesizer::synthesis_BB(){
	qDebug() << "Synthesis starts (Building blocks) ... ";

	// Prepare shifts
	prepareShifts_BB();

	// setup graph cut problem
	gc = new GCoptimizationGridGraph(colsSyn_scaled, rowsSyn_scaled, totalShiftsXY_scaled);

	// set unary cost
	gc->setDataCost(&unary_BB);
	//gc->setDataCost(&unary_OffsetStatistics);

	// set smoothness cost
	gc->setSmoothCost(&smooth_BB);
	//gc->setSmoothCost(&smooth_OffsetStatistics);

	// optimize
	qDebug() << "Before optimization energy is " << gc->compute_energy();
	for (int i = 0; i < 4; i++){
		gc->expansion(1);// run expansion for 2 iterations. For swap use gc->swap(num_iterations);
		qDebug() << "after expansion energy is " << gc->compute_energy();
		gc->swap(1);// run expansion for 2 iterations. For swap use gc->swap(num_iterations);
		qDebug() << "after swap energy is " << gc->compute_energy();
	}

	// prepare results
	label2result();
}

void Synthesizer::prepareShifts_BB(){

	prepareShifts_OffsetStatistics();
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

			int diff1 = imgInputGray_scaled(x1_s_a.y, x1_s_a.x) - imgInputGray_scaled(x1_s_b.y, x1_s_b.x);
			int diff2 = imgInputGray_scaled(x2_s_a.y, x2_s_a.x) - imgInputGray_scaled(x2_s_b.y, x2_s_b.x);

			double diffRep1 = 50 * (imgInputlabel_scaled(x1_s_a.y, x1_s_a.x) != imgInputlabel_scaled(x1_s_b.y, x1_s_b.x));
			double diffRep2 = 50 * (imgInputlabel_scaled(x2_s_a.y, x2_s_a.x) != imgInputlabel_scaled(x2_s_b.y, x2_s_b.x));

			bool indicator1 = imgInputlabel_scaled(x1_s_a.y, x1_s_a.x) == imgInputlabel_scaled(x1_s_b.y, x1_s_b.x);
			bool indicator2 = imgInputlabel_scaled(x2_s_a.y, x2_s_a.x) == imgInputlabel_scaled(x2_s_b.y, x2_s_b.x);
			double diffRepinter1X = 8 * (imgInputlabelinterX_scaled(x1_s_a.y, x1_s_a.x) - imgInputlabelinterX_scaled(x1_s_b.y, x1_s_b.x));
			double diffRepinter1Y = 8 * (imgInputlabelinterY_scaled(x1_s_a.y, x1_s_a.x) - imgInputlabelinterY_scaled(x1_s_b.y, x1_s_b.x));
			double diffRepinter2X = 8 * (imgInputlabelinterX_scaled(x2_s_a.y, x2_s_a.x) - imgInputlabelinterX_scaled(x2_s_b.y, x2_s_b.x));
			double diffRepinter2Y = 8 * (imgInputlabelinterY_scaled(x2_s_a.y, x2_s_a.x) - imgInputlabelinterY_scaled(x2_s_b.y, x2_s_b.x));

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

void Synthesizer::label2result(){
	// prepare results
	imgSyn_scaled = Mat3b::zeros(rowsSyn_scaled, colsSyn_scaled);
	gcolabelSyn_scaled = Mat1b::zeros(rowsSyn_scaled, colsSyn_scaled);
	for (int i = 0; i < numPixelSyn_scaled; i++){
		int label = gc->whatLabel(i);
		int newX = -list_shiftXY_scaled[label]->x + gcoNodes[i]->x;
		int newY = -list_shiftXY_scaled[label]->y + gcoNodes[i]->y;
		if (newX >= 0 && newX < colsInput_scaled && newY >= 0 && newY < rowsInput_scaled){
			imgSyn_scaled(gcoNodes[i]->y, gcoNodes[i]->x) = imgInput_scaled(newY, newX);
			gcolabelSyn_scaled(gcoNodes[i]->y, gcoNodes[i]->x) = label;
		}
	}

	totalShiftsXY_fullres = totalShiftsXY_scaled;
	list_shiftXY_fullres.resize(totalShiftsXY_fullres);
	for (int xy = 0; xy < totalShiftsXY_fullres; xy++){
		list_shiftXY_fullres[xy] = new Point2i(list_shiftXY_scaled[xy]->x / scalerRes, list_shiftXY_scaled[xy]->y / scalerRes);
	}
	rowsSyn_fullres = rowsSyn_scaled / scalerRes;
	colsSyn_fullres = colsSyn_scaled / scalerRes;
	gcolabelSyn_fullres = Mat1b::zeros(rowsSyn_fullres, colsSyn_fullres);
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
}

bool Synthesizer::isValid(int x, int y){
	if (x >= 0 && y >= 0 && x < colsInput_scaled && y < rowsInput_scaled){
		return true;
	}
	return false;
}