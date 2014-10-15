#include "mytype.h"
#include "app.h"
#include <QtCore>

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
//    qDebug() << "before parse: " << datestring ;
    QString str = datestring;

    QString tmp = str.split(" ")[2]; // "28"
//    qDebug() << "tmp: " << tmp ;
    str.remove(7, 3);
    str.insert(3, " " + tmp);        // "Mon 28 Oct 20:00:23 +0800 2013"
    tmp = str.split(" ")[5];         // "2013"
//    qDebug() << "tmp: " << tmp ;
    str.remove(25, 5);
    str.insert(10, " " + tmp);             // "Mon 28 Oct 2013 20:00:23 +0800"
    str.insert(3, ",");              // "Mon, 28 Oct 2013 20:00:23 +0800"
//    QDateTime datetime = QDateTime::fromString(str.replace("+0800 ", "")/*, "ddd MMM dd HH:mm:ss yyyy"*/);
//    qDebug() << "after parse: " << str ;
//    qint64 mtime =
//    mtime.
    return str;
}
