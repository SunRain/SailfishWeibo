#ifndef WBCONTENTPARSER_H
#define WBCONTENTPARSER_H

#include <QObject>
#include "SingletonPointer.h"

class Emoticons;
class WBContentParser : public QObject
{
    Q_OBJECT
    DECLARE_SINGLETON_POINTER(WBContentParser)
public:
    virtual ~WBContentParser();

    //解析微博内容，替换表情/链接等
    Q_INVOKABLE QString parseWeiboContent(const QString &weiboContent,
                                          const QString &contentColor,
                                          const QString &userColor,
                                          const QString &linkColor);

    ///
    /// \brief strToLink set str to url link
    /// \param str the str
    /// \param url the link url
    /// \param linkColor link color
    /// \return like this <a href="url"><font color="linkColor">str</font></a>
    static QString strToLink(const QString &str, const QString &url, const QString &linkColor);
private:
    QString parseHackLoginWeiboContent(const QString &weiboContent,
                                       const QString &contentColor,
                                       const QString &userColor,
                                       const QString &linkColor);
    QString parseEmoticons(const QString &pattern,const QString &emoticonStr);
private:
    Emoticons *m_emoticons;
};

#endif // WBCONTENTPARSER_H
