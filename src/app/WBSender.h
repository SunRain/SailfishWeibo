#ifndef WBSENDER_H
#define WBSENDER_H

#include <QObject>

class WBSender : public QObject
{
    Q_OBJECT
public:
    enum WBSendType {
        TYPE_DEFAULT = 0x0,
        TYEP_REPOST,
        TYPE_COMMENT,
        TYPE_REPLY
    };

    explicit WBSender(QObject *parent = 0);

};

#endif // WBSENDER_H
