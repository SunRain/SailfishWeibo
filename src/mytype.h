#ifndef MYTYPE_H
#define MYTYPE_H

#include <QObject>

class MyType : public QObject
{
    Q_OBJECT
    Q_PROPERTY( QString key READ key )
    Q_PROPERTY( QString secret READ secret )
    Q_PROPERTY( QString path READ path )
    Q_PROPERTY( int isARM READ isARM )

public:
    explicit MyType(QObject *parent = 0);
    ~MyType();

protected:
    QString _key;
    QString key() { return _key; }

    QString _secret;
    QString secret() { return _secret; }

    QString _path;
    QString path() { return _path; }

    int _isARM;
    int isARM() { return _isARM; }

public slots:
    QString dateParse(const QString &datestring);

};

#endif // MYTYPE_H
