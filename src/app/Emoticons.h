#ifndef EMOTICONS_H
#define EMOTICONS_H

#include <QObject>
#include <QHash>

class Emoticons : public QObject
{
    Q_OBJECT
public:
    explicit Emoticons(QObject *parent = 0);
    virtual ~Emoticons();
    QString getEmoticonName(const QString &name);
private:
    void initData();
    
    QHash<QString, QString> m_emoticonsList;
};

#endif // EMOTICONS_H
