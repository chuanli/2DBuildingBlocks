/****************************************************************************
** Meta object code from reading C++ file 'imageviewer.h'
**
** Created by: The Qt Meta Object Compiler version 63 (Qt 4.8.6)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../source/imageviewer.h"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'imageviewer.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 63
#error "This file was generated using the moc from 4.8.6. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_ImageViewer[] = {

 // content:
       6,       // revision
       0,       // classname
       0,    0, // classinfo
      12,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: signature, parameters, type, tag, flags
      13,   12,   12,   12, 0x08,
      24,   12,   12,   12, 0x08,
      35,   12,   12,   12, 0x08,
      49,   12,   12,   12, 0x08,
      63,   12,   12,   12, 0x08,
      77,   12,   12,   12, 0x08,
      91,   12,   12,   12, 0x08,
     114,   12,   12,   12, 0x08,
     137,   12,   12,   12, 0x08,
     160,   12,   12,   12, 0x08,
     183,   12,   12,   12, 0x08,
     201,   12,   12,   12, 0x08,

       0        // eod
};

static const char qt_meta_stringdata_ImageViewer[] = {
    "ImageViewer\0\0slotOpen()\0slotSave()\0"
    "slotExpandX()\0slotShrinkX()\0slotExpandY()\0"
    "slotShrinkY()\0slotSwitchSynMethod1()\0"
    "slotSwitchSynMethod2()\0slotSwitchSynMethod3()\0"
    "slotSwitchSynMethod4()\0slotShowMontage()\0"
    "slotHoleFilling()\0"
};

void ImageViewer::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        Q_ASSERT(staticMetaObject.cast(_o));
        ImageViewer *_t = static_cast<ImageViewer *>(_o);
        switch (_id) {
        case 0: _t->slotOpen(); break;
        case 1: _t->slotSave(); break;
        case 2: _t->slotExpandX(); break;
        case 3: _t->slotShrinkX(); break;
        case 4: _t->slotExpandY(); break;
        case 5: _t->slotShrinkY(); break;
        case 6: _t->slotSwitchSynMethod1(); break;
        case 7: _t->slotSwitchSynMethod2(); break;
        case 8: _t->slotSwitchSynMethod3(); break;
        case 9: _t->slotSwitchSynMethod4(); break;
        case 10: _t->slotShowMontage(); break;
        case 11: _t->slotHoleFilling(); break;
        default: ;
        }
    }
    Q_UNUSED(_a);
}

const QMetaObjectExtraData ImageViewer::staticMetaObjectExtraData = {
    0,  qt_static_metacall 
};

const QMetaObject ImageViewer::staticMetaObject = {
    { &QMainWindow::staticMetaObject, qt_meta_stringdata_ImageViewer,
      qt_meta_data_ImageViewer, &staticMetaObjectExtraData }
};

#ifdef Q_NO_DATA_RELOCATION
const QMetaObject &ImageViewer::getStaticMetaObject() { return staticMetaObject; }
#endif //Q_NO_DATA_RELOCATION

const QMetaObject *ImageViewer::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->metaObject : &staticMetaObject;
}

void *ImageViewer::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_ImageViewer))
        return static_cast<void*>(const_cast< ImageViewer*>(this));
    return QMainWindow::qt_metacast(_clname);
}

int ImageViewer::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QMainWindow::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 12)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 12;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
