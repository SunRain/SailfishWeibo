
#include "Settings.h"

#include <QSettings>
#include <QDir>
#include <QStandardPaths>
#include <QCoreApplication>
#include <QStringList>
#include <QDebug>
#include <QMutex>
#include <QScopedPointer>
#include <QVariant>

//static const char *KEY_ACCESS_TOKEN = "access_token";
//static const char *KEY_EXPIRE_DATA = "expire_data";
//static const char *KEY_UID = "uid";
//static const char *KEY_REFRESH_TOKEN = "refresh_token";

Settings::Settings(QObject *parent)
    : QObject(parent)
{
    m_settings = new QSettings(qApp->organizationName(), qApp->applicationName(), parent);

//    m_refreshToken = m_settings->value (KEY_REFRESH_TOKEN, QVariant()).toString ();
//    m_uid = m_settings->value (KEY_UID, QVariant()).toString ();
//    m_expiresData = m_settings->value (KEY_EXPIRE_DATA, QVariant()).toString ();
//    m_accessToken = m_settings->value (KEY_ACCESS_TOKEN, QVariant()).toString ();

}

Settings::~Settings()
{
    m_settings->sync ();
    m_settings->deleteLater ();
}

//void Settings::setRefreshToken(const QString &value)
//{
//    if (m_refreshToken == value)
//        return;
//    m_refreshToken = value;
//    m_settings->setValue (KEY_REFRESH_TOKEN, value);
//    m_settings->sync ();
//    emit refreshTokenChanged ();
//}

//QString Settings::refreshToken() const
//{
//    return m_refreshToken;
//}

//void Settings::setUid(const QString &value)
//{
//    if (m_uid == value)
//        return;
//    m_uid = value;
//    m_settings->setValue (KEY_UID, value);
//    m_settings->sync ();
//    emit uidChanged ();
//}

//QString Settings::uid() const
//{
//    return m_uid;
//}

//void Settings::setExpiresData(const QString &value)
//{
//    if (m_expiresData == value)
//        return;
//    m_expiresData = value;
//    m_settings->setValue (KEY_EXPIRE_DATA, value);
//    m_settings->sync ();
//    emit expiresDataChanged ();
//}

//QString Settings::expiresData() const
//{
//    return m_expiresData;
//}

//void Settings::setAccessToken(const QString &value)
//{
//    if (m_accessToken == value)
//        return;
//    m_accessToken = value;
//    m_settings->setValue (KEY_ACCESS_TOKEN, value);
//    m_settings->sync ();
//    emit accessTokenChanged ();
//}

//QString Settings::accessToken() const
//{
//    return m_accessToken;
//}

QVariant Settings::getValue(const QString &key, const QVariant &defaultValue)
{
    return m_settings->value (key, defaultValue);
}

void Settings::setValue(const QString &key, const QVariant &value)
{
    m_settings->setValue (key, value);
    m_settings->sync ();
}

//Settings *Settings::instance()
//{
//    static QMutex mutex;
//    static QScopedPointer<Settings> scp;
//    if (Q_UNLIKELY(scp.isNull())) {
//        mutex.lock();
//        scp.reset(new Settings(0));
//        mutex.unlock();
//    }
//    return scp.data();
//}


