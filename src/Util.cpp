
#include <QSettings>
#include <QGuiApplication>

#include "MyNetworkAccessManagerFactory.h"
#include "Util.h"

Util *Util::getInstance()
{
    static Util u;
    return &u;
}

Util::~Util()
{
    m_Settings->deleteLater();
}

void Util::setEngine(QQmlEngine *engine)
{
    this->m_Engine = engine;
}

void Util::setValue(const QString &key, const QVariant &value)
{
    if (m_Map.value(key) != value) {
        m_Map.insert(key, value);
        m_Settings->setValue(key, value);
    }
}

QVariant Util::getValue(const QString &key, const QVariant defaultValue)
{
    if (m_Map.contains(key)){
        return m_Map.value(key);
    } else {
        return m_Settings->value(key, defaultValue);
    }
}

bool Util::saveToCache(const QString &remoteUrl, const QString &dirName, const QString &fileName)
{
    if (m_Engine.isNull()) {
        return false;
    }
    MyNetworkAccessManager *manage = (MyNetworkAccessManager*)m_Engine->networkAccessManager();

    QAbstractNetworkCache *diskCache = manage->cache();

    if (diskCache == 0) {
        return false;
    }
    QIODevice *data = diskCache->data(QUrl(remoteUrl));
    if (data == 0) {
        return false;
    }
    //QString path = dir;
    QDir dir(dirName);
    if (!dir.exists()) dir.mkpath(dirName);
    QFile file(dirName + QDir::separator() + fileName);
    if (file.open(QIODevice::WriteOnly)){
        file.write(data->readAll());
        file.close();
        data->deleteLater();
        return true;
    }
	data->deleteLater();
    return false;
}

QString Util::parseImageUrl(const QString &remoteUrl)
{
    QString cachePath = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    QByteArray byteArray = remoteUrl.toLocal8Bit().toBase64();
    QString fileName(byteArray);
    QString filePath = QString("%1%2%3").arg(cachePath).arg(QDir::separator()).arg(fileName);
    QFile file(filePath);
    if (file.exists()) {
        qDebug()<<"url [" + remoteUrl + "] from local : " +filePath;
        return filePath;
    }
    qDebug()<<"url [" + remoteUrl + "] from remote";
    return remoteUrl;
    
}

void Util::saveRemoteImage(const QString &remoteUrl)
{
    QString cachePath = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    QByteArray byteArray = remoteUrl.toLocal8Bit().toBase64();
    QString fileName(byteArray);
    QString filePath = QString("%1%2%3").arg(cachePath).arg(QDir::separator()).arg(fileName);
    QFile file(filePath);
    if (file.exists()) {
        return;
    }
    saveToCache(remoteUrl, cachePath,fileName);
}

Util::Util(QObject *parent) :
    QObject(parent)
{
    m_Settings = new QSettings(qApp->organizationName(), qApp->applicationName());
}
