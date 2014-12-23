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
    QStringList list = str.split(" ");

    //month dd,yyyy hh:mm:ss
    //Oct 28 ,2013 20:00:23"
    QString tmp = QString("%1,%2,%3,%4")
            .arg(list[1]) //moth
            .arg(list[2]) //day
            .arg(list[5]) //yyyy
            .arg(list[3]); //hh:mm:ss
    QDateTime datetime = QDateTime::fromString(tmp, "MMM,dd,yyyy,HH:mm:ss");
    return datetime.toString("MM,dd,yyyy,HH,mm,ss");
}
