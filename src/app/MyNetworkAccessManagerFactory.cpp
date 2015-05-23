
#include "MyNetworkAccessManagerFactory.h"

#include <QtDebug>
#include <QDir>
#include <QScopedPointer>

#include "Util.h"
#include "Settings.h"

static const char *DOMAIN_IMAGE = ".sinaimg.cn/";

MyNetworkAccessManagerFactory::MyNetworkAccessManagerFactory() :
    QQmlNetworkAccessManagerFactory()
{
}

QNetworkAccessManager* MyNetworkAccessManagerFactory::create(QObject *parent)
{
    QMutexLocker lock(&mutex);
    Q_UNUSED(lock);
    QNetworkAccessManager* manager = new MyNetworkAccessManager(parent);

    bool useDiskCache = true;

    if (useDiskCache){
        QNetworkDiskCache* diskCache = new QNetworkDiskCache(parent);
        //QString dataPath = QDesktopServices::storageLocation(QDesktopServices::CacheLocation);
        //QString dataPath = QString("%1/%2").arg(qApp->organizationName()).arg(qApp->applicationName());
        QString dataPath = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
        
        QDir dir(dataPath);
        
       //qDebug() <<"dataPath " <<dataPath <<" dirPath "<< dir.absolutePath();
                
        if (!dir.exists()) dir.mkpath(dir.absolutePath());

        diskCache->setCacheDirectory(dataPath);
        diskCache->setMaximumCacheSize(3*1024*1024);
        manager->setCache(diskCache);
    }

    QNetworkCookieJar* cookieJar = MyNetworkCookieJar::GetInstance();
    manager->setCookieJar(cookieJar);
    cookieJar->setParent(0);

    return manager;
}

MyNetworkAccessManager::MyNetworkAccessManager(QObject *parent) :
    QNetworkAccessManager(parent)
{
}

QNetworkReply *MyNetworkAccessManager::createRequest(Operation op, const QNetworkRequest &request, QIODevice *outgoingData)
{
    QNetworkRequest req(request);
    // set user-agent
    if (op == PostOperation){
        req.setRawHeader("User-Agent", "IDP");
    } else {
        req.setRawHeader("User-Agent", "Mozilla/5.0 (iPhone; CPU iPhone OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53");
    }
    QByteArray urldata = req.url().toString().toLocal8Bit();//toAscii();
    
   // qDebug()<<"=== urldata is "<<urldata;
    
    if (urldata.contains(DOMAIN_IMAGE)) {
        req.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::PreferCache);
    }
    QNetworkReply *reply = QNetworkAccessManager::createRequest(op, req, outgoingData);
    return reply;
}

MyNetworkCookieJar::MyNetworkCookieJar(QObject *parent) :
    QNetworkCookieJar(parent)
{
    keepAliveCookie = QNetworkCookie("ka", "open");
    load();
}

MyNetworkCookieJar::~MyNetworkCookieJar()
{
    save();
}

MyNetworkCookieJar* MyNetworkCookieJar::GetInstance()
{
    static QMutex mutex;
    static QScopedPointer<MyNetworkCookieJar> scp;
    if (Q_UNLIKELY(scp.isNull())) {
        mutex.lock();
        scp.reset(new MyNetworkCookieJar(0));
        mutex.unlock();
    }
    return scp.data();
}

void MyNetworkCookieJar::clearCookies()
{
    QList<QNetworkCookie> emptyList;
    setAllCookies(emptyList);
}

QList<QNetworkCookie> MyNetworkCookieJar::cookiesForUrl(const QUrl &url) const
{
    QMutexLocker lock(&mutex);
    Q_UNUSED(lock);
    QList<QNetworkCookie> cookies = QNetworkCookieJar::cookiesForUrl(url);

    if (!cookies.contains(keepAliveCookie))
        cookies.prepend(keepAliveCookie);
    return cookies;
}

bool MyNetworkCookieJar::setCookiesFromUrl(const QList<QNetworkCookie> &cookieList, const QUrl &url)
{
    QMutexLocker lock(&mutex);
    Q_UNUSED(lock);
    return QNetworkCookieJar::setCookiesFromUrl(cookieList, url);
}

void MyNetworkCookieJar::save()
{
    QMutexLocker lock(&mutex);
    Q_UNUSED(lock);
    QList<QNetworkCookie> list = allCookies();
    QByteArray data;
    foreach (QNetworkCookie cookie, list) {      
        if (!cookie.isSessionCookie()){
            QString domain = cookie.domain();
            //qDebug() <<" === domain "<<domain;
            if (domain.contains(DOMAIN_IMAGE)){
                data.append(cookie.toRawForm());
                data.append("\n");
                
                //qDebug()<<"cookie data "<<cookie.toRawForm();
            }
        }
    }
//    Util::getInstance()->setValue("cookies", data);
    Settings::instance ()->setValue ("cookies", data);
}

void MyNetworkCookieJar::load()
{
    QMutexLocker lock(&mutex);
    Q_UNUSED(lock);
//    QByteArray data = Util::getInstance()->getValue("cookies").toByteArray();
    QByteArray data = Settings::instance ()->getValue ("cookies").toByteArray ();
    setAllCookies(QNetworkCookie::parseCookies(data));
}
