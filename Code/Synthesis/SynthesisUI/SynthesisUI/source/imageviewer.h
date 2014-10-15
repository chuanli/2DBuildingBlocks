#ifndef IMAGEVIEWER_H
#define IMAGEVIEWER_H

#include <QMainWindow>
#include <QGraphicsView>
#include <QGraphicsScene>
#include <QPrinter>
#include <QString>

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

//private slots:
 
private:
 //   QScrollArea *scrollArea;
 //   double scaleFactor;
 //   QGraphicsScene* scene;
	//QGraphicsView* view;
	//QGraphicsPixmapItem* imgDisp;

protected:

};
//! [0]

#endif
