
#include "Emoticons.h"

#include <sailfishapp.h>
#include <QScopedPointer>
#include <QMutex>
#include <QFile>
#include <QStringList>

Emoticons *Emoticons::getInstance()
{
    static QMutex mutex;
    static QScopedPointer<Emoticons> scp;
    if (Q_UNLIKELY(scp.isNull())) {
        mutex.lock();
        scp.reset(new Emoticons(0));
        mutex.unlock();
    }
    return scp.data();
}

Emoticons::~Emoticons()
{
    if (!mEmoticonsHash.isEmpty()) {
        mEmoticonsHash.clear();
    }
}

QString Emoticons::getEmoticonName(const QString &name)
{
    QString key = name;
    if (key.contains("[")) key.replace("[", "");
    if (key.contains("]")) key.replace("]", "");
    return mEmoticonsHash.value(key, "");
}

Emoticons::Emoticons(QObject *parent)
    :QObject(parent)
{
    initData();
}

void Emoticons::initData()
{
    if (!mEmoticonsHash.isEmpty()) {
        mEmoticonsHash.clear();
    }
    QString path = SailfishApp::pathTo(QString("qml/emoticons/emoticons.dat")).toString().replace("file:///", "/");
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return;
    }
    QString line;
    QStringList list;
    while(!file.atEnd()) {
        line = file.readLine().trimmed();
        if (line.length() > 0 && line.contains("||")) {
            list = line.split("||");
            mEmoticonsHash.insert(list.at(0), list.at(1));
        }
    }
}

