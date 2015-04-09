#ifndef MYNETWORKACCESSMANAGERFACTORY_H
#define MYNETWORKACCESSMANAGERFACTORY_H

#include <QQmlNetworkAccessManagerFactory>
#include <QtNetwork>

////
/// \brief The MyNetworkAccessManagerFactory class
///
class MyNetworkAccessManagerFactory : public QQmlNetworkAccessManagerFactory
{
public:
    explicit MyNetworkAccessManagerFactory();
    virtual QNetworkAccessManager* create(QObject *parent);

private:
    QMutex mutex;
};

////
/// \brief The MyNetworkAccessManager class
///
class MyNetworkAccessManager : public QNetworkAccessManager
{
    Q_OBJECT
public:
    explicit MyNetworkAccessManager(QObject *parent = 0);

protected:
    QNetworkReply *createRequest(Operation op, const QNetworkRequest &request, QIODevice *outgoingData);
};

///
/// \brief The MyNetworkCookieJar class
///
class MyNetworkCookieJar : public QNetworkCookieJar
{
public:
    static MyNetworkCookieJar* GetInstance();
    ~MyNetworkCookieJar();

    void clearCookies();

    virtual QList<QNetworkCookie> cookiesForUrl(const QUrl &url) const;
    virtual bool setCookiesFromUrl(const QList<QNetworkCookie> &cookieList, const QUrl &url);

private:
    explicit MyNetworkCookieJar(QObject *parent = 0);
    void save();
    void load();
    mutable QMutex mutex;
    QNetworkCookie keepAliveCookie;
};

#endif // MYNETWORKACCESSMANAGERFACTORY_H
