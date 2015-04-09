
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

static const char *KEY_ACCESS_TOKEN = "access_token";
static const char *KEY_EXPIRE_DATA = "expire_data";
static const char *KEY_UID = "uid";
static const char *KEY_REFRESH_TOKEN = "refresh_token";

Settings::Settings(QObject *parent)
    : QObject(parent)
{
    mSettings = new QSettings(qApp->organizationName(), qApp->applicationName(), parent);

    mRefreshToken = mSettings->value (KEY_REFRESH_TOKEN, QVariant()).toString ();
    mUID = mSettings->value (KEY_UID, QVariant()).toString ();
    mExpiresData = mSettings->value (KEY_EXPIRE_DATA, QVariant()).toString ();
    mAccessToken = mSettings->value (KEY_ACCESS_TOKEN, QVariant()).toString ();

}

Settings::~Settings()
{
    mSettings->sync ();
    mSettings->deleteLater ();
}

void Settings::setRefreshToken(const QString &value)
{
    if (mRefreshToken == value)
        return;
    mRefreshToken = value;
    mSettings->setValue (KEY_REFRESH_TOKEN, value);
    mSettings->sync ();
    emit refreshTokenChanged ();
}

QString Settings::refreshToken() const
{
    return mRefreshToken;
}

void Settings::setUid(const QString &value)
{
    if (mUID == value)
        return;
    mUID = value;
    mSettings->setValue (KEY_UID, value);
    mSettings->sync ();
    emit uidChanged ();
}

QString Settings::uid() const
{
    return mUID;
}

void Settings::setExpiresData(const QString &value)
{
    if (mExpiresData == value)
        return;
    mExpiresData = value;
    mSettings->setValue (KEY_EXPIRE_DATA, value);
    mSettings->sync ();
    emit expiresDataChanged ();
}

QString Settings::expiresData() const
{
    return mExpiresData;
}

void Settings::setAccessToken(const QString &value)
{
    if (mAccessToken == value)
        return;
    mAccessToken = value;
    mSettings->setValue (KEY_ACCESS_TOKEN, value);
    mSettings->sync ();
    emit accessTokenChanged ();
}

QString Settings::accessToken() const
{
    return mAccessToken;
}

QVariant Settings::getValue(const QString &key, const QVariant defaultValue)
{
    return mSettings->value (key, defaultValue);
}

void Settings::setValue(const QString &key, const QVariant &value)
{
    mSettings->setValue (key, value);
    mSettings->sync ();
}

Settings *Settings::instance()
{
    static QMutex mutex;
    static QScopedPointer<Settings> scp;
    if (Q_UNLIKELY(scp.isNull())) {
        mutex.lock();
        scp.reset(new Settings(0));
        mutex.unlock();
    }
    return scp.data();
}


