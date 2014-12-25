#include "mytype.h"
#include "app.h"
#include <QtCore>
#include <QStringList>
#include <QDateTime>

MyType::MyType(QObject *parent) :
    QObject(parent),
    _key(APPKEY), _secret(APPSECRET)
{
    this->_path = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation);
    this->_isARM = -1;
#ifdef Q_PROCESSOR_ARM
    this->_isARM = 1;
#endif
#ifdef Q_PROCESSOR_X86
    this->_isARM = 0;
#endif
}

MyType::~MyType() {

}

QString MyType::dateParse(const QString &datestring) // "Mon Oct 28 20:00:23 +0800 2013"
{
    QString str = datestring;
    QStringList dateList = str.split(" ");
    QStringList timeList = dateList[3].split(":");

    //Mon Oct 28 20:00:23 +0800 2013"
    //MM,dd,yyyy,HH,mm,ss
    //Oct,28 ,2013,20,00,23,"
    QString tmp = QString("%1,%2,%3,%4,%5,%6")
            .arg(dateList[1]) //moth
            .arg(dateList[2]) //day
            .arg(dateList[5]) //yyyy
            .arg(timeList[0]) //hh
            .arg(timeList[1]) //mm
            .arg(timeList[2]); //ss
    return tmp;
}
