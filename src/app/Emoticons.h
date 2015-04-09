#ifndef EMOTICONS_H
#define EMOTICONS_H

#include <QObject>
#include <QHash>

class Emoticons : public QObject
{
    Q_OBJECT
public:
    static Emoticons *getInstance();
    virtual ~Emoticons();
    QString getEmoticonName(const QString &name);
private:
    explicit Emoticons(QObject *parent = 0);
    void initData();
    
    QHash<QString, QString> mEmoticonsHash;
};

#endif // EMOTICONS_H
