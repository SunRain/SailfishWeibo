#include "WBContentParser.h"

#include <QDebug>
#include <QJsonParseError>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonValue>
#include <QDateTime>

#include "sailfishapp.h"

#include "TokenProvider.h"
#include "Emoticons.h"

#include "htmlcxx/html/tree.h"
#include "htmlcxx/html/ParserDom.h"
#include "htmlcxx/html/Node.h"

using namespace QWeiboSDK;
using namespace htmlcxx;
using namespace std;

#define DBG_HTMLPARSER 0

#define TO_QSTR(x) QString::fromStdString (x)

WBContentParser::WBContentParser(QObject *parent)
    : QObject(parent)
    , m_emoticons(new Emoticons(this))
{

}


WBContentParser::~WBContentParser()
{
    if (m_emoticons)
        m_emoticons->deleteLater ();
    m_emoticons = nullptr;
}

QString WBContentParser::parseWeiboContent(const QString &weiboContent,
                                              const QString &contentColor,
                                              const QString &userColor,
                                              const QString &linkColor)
{
    if (TokenProvider::instance ()->useHackLogin ()) {
        return parseHackLoginWeiboContent (weiboContent, contentColor, userColor, linkColor);
    }

    QString tmp = weiboContent;

    //注意这几行代码的顺序不能乱，否则会造成多次替换
    tmp.replace("&","&amp;");
    tmp.replace(">","&gt;");
    tmp.replace("<","&lt;");
    tmp.replace("\"","&quot;");
    tmp.replace("\'","&#39;");
    tmp.replace(" ","&nbsp;");
    tmp.replace("\n","<br>");
    tmp.replace("\r","<br>");

    //'<font color="' +aa +'">aa + </font> <img src="' + '../emoticons/cool_org.png"' + '> <b>Hello</b> <i>World! ddddddddddddddddddddddddddd</i>'
    //设置主要字体
    QString content = QString("<font color=\"%1\">%2</font>").arg(contentColor).arg(tmp);

    //替换网页链接
    tmp = QString();
    int pos = -1;
    QString reText;

    QRegExp urlRE("http://[\\w+&@#/%?=~_\\\\-|!:,\\\\.;]*[\\w+&@#/%=~_|]");
                  //("http://[a-zA-Z0-9+&@#/%?=~_\\-|!:,\\.;]*[a-zA-Z0-9+&@#/%=~_|]");
                 //("http://([\\w-]+\\.)+[\\w-]+(/[A-Za-z0-9]*)");
    while((pos = urlRE.indexIn(content, pos+1)) != -1) {
        tmp = urlRE.cap(0);
//        reText = QString("<a href=\"%1\"><font color=\"%2\">%3</font></a>").arg(tmp).arg(linkColor).arg(tmp);
        reText = strToLink (tmp, tmp, linkColor);
                // "<a href=\"" +urlRE.cap(0) +"\">"+urlRE.cap(0)+"</a>";
        content.replace(pos, tmp.length(), reText);
        pos += reText.length();
    }

    //替换@用户
    pos = -1;
    reText = QString();
    tmp = QString();

    //"@[\\w\\p{InCJKUnifiedIdeographs}-]{1,26}"
    QRegExp atRE("@[\\w\\p{InCJKUnifiedIdeographs}-]{1,26}");

    while((pos = atRE.indexIn(content, pos+1)) != -1) {
        tmp = atRE.cap(0).replace("@", "@:");
//        reText = QString("<a href=\"%1\"><font color=\"%2\">%3</font></a>").arg(tmp).arg(userColor).arg(atRE.cap(0));
                //"<a href=\"" +atRE.cap(0) +"\">"+atRE.cap(0)+"</a>";
        reText = strToLink (atRE.cap(0), tmp, userColor);
        content.replace(pos, atRE.cap(0).length(), reText);
        pos += reText.length();
    }

    //替换表情符号
    content = parseEmoticons("\\[(\\S{1,2})\\]", content);
    content = parseEmoticons("\\[(\\S{3,4})\\]", content);
    return content;
}

QString WBContentParser::strToLink(const QString &str, const QString &url, const QString &linkColor)
{
    if (str.isEmpty ())
        return str;
//    if (TokenProvider::instance ()->useHackLogin ())
//        return QString("<a href=\\\"%1\\\"><font color=\\\"%2\\\">%3</font></a>").arg(url).arg(linkColor).arg(str);
    return QString("<a href=\"%1\"><font color=\"%2\">%3</font></a>").arg(url).arg(linkColor).arg(str);
}

QString WBContentParser::parseHackPrivateMessageNoteList(const QString &content)
{
    if (content.isEmpty ())
        return QString();

    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson (content.toUtf8 (), &error);
    if (error.error != QJsonParseError::NoError) {
        qDebug()<<Q_FUNC_INFO<<"Parse main json content error ["<<error.errorString ()<<"]";
        return QString();
    }
    if (doc.isNull () || doc.isEmpty ()) {
        qDebug()<<Q_FUNC_INFO<<"Parse main json content, result isNull or isEmpty";
        return QString();
    }
    QJsonObject topObj = doc.object ();
    if (topObj.isEmpty ()) {
        qDebug()<<Q_FUNC_INFO<<"Convert to top object error";
        return QString();
    }
    QJsonObject mainObj = topObj.value ("data").toObject ();
    if (mainObj.isEmpty ()) {
        qDebug()<<Q_FUNC_INFO<<"Convert to main object error";
        return QString();
    }
    QList<QJsonObject> objList;
    foreach (QString key, mainObj.keys ()) {
        QJsonObject o;
        QJsonObject sub = mainObj.value (key).toObject ();
        o.insert ("id", key);
        o.insert ("data", sub);
        objList.append (o);
    }
    //sort array by data.time
    qStableSort(objList.begin (), objList.end (),
                [](const QJsonObject &a, const QJsonObject &b) ->bool {
        QString astr = a.value ("data").toObject ().value ("time").toString ();
//        qDebug()<<Q_FUNC_INFO<<" astr "<<astr;
        //eg. 2015-12-24 18:28
        QDateTime da = QDateTime::fromString (astr, "yyyy-MM-dd hh:mm");
        if (!da.isValid () || da.isNull ()) {
            //eg. 02-05 20:27
            QString str = QString("%1-%2").arg (QDateTime::currentDateTime ().date ().year ()).arg (astr);
//            qDebug()<<Q_FUNC_INFO<<" new astr "<<str;
            da = QDateTime::fromString (str, "yyyy-MM-dd hh:mm");
        }

        QString bstr = b.value ("data").toObject ().value ("time").toString ();
//        qDebug()<<Q_FUNC_INFO<<" bstr "<<bstr;
        //eg. 2015-12-24 18:28
        QDateTime db = QDateTime::fromString (bstr, "yyyy-MM-dd hh:mm");
        if (!db.isValid () || db.isNull ()) {
            //eg. 02-05 20:27
            QString str = QString("%1-%2").arg (QDateTime::currentDateTime ().date ().year ()).arg (bstr);
//            qDebug()<<Q_FUNC_INFO<<" new bstr "<<str;
            db = QDateTime::fromString (str, "yyyy-MM-dd hh:mm");
        }
        return da > db;
    });
    QJsonArray retArray;
    foreach (QJsonObject obj, objList) {
        retArray.append (obj);
    }
    QJsonDocument d(retArray);
    return d.toJson ();
}

QString WBContentParser::parseHackPrivateMessageToken(const QString &content)
{
    HTML::ParserDom parser;
    tree<HTML::Node> dom = parser.parseTree(content.toStdString ());

    tree<HTML::Node>::iterator it = dom.begin();
    tree<HTML::Node>::iterator end = dom.end();


    for (; it != end; ++it) {
        (*it).parseAttributes ();

        if ((*it).isTag ()) {
            if ((*it).tagName () == "script") { //script
                QString id = TO_QSTR((*it).attribute ("id").second);
                QString type = TO_QSTR((*it).attribute ("type").second);
                if (id.isEmpty () && type.isEmpty ()) {
                    (*++it).parseAttributes ();
                    QString text = TO_QSTR((*it).text ());
                    if (text.contains ("CONFIG.exp=")) {
                        QStringList list = text.split (";");
                        foreach (QString str, list) {
                            if (str.contains ("$CONFIG.exp=")) {
                                QString s = str.replace ("$CONFIG.exp=", "");
                                qDebug()<<"str value ["<<s<<"]";
                                QJsonParseError error;
                                QJsonDocument doc = QJsonDocument::fromJson (s.toUtf8 (), &error);
                                if (error.error != QJsonParseError::NoError) {
//                                    qDebug()<<Q_FUNC_INFO<<"Parse json content error ["<<error.errorString ()<<"]";
                                    continue;
                                }
                                if (doc.isNull () || doc.isEmpty ()) {
//                                    qDebug()<<Q_FUNC_INFO<<"Parse json content, result isNull or isEmpty";
                                    continue;
                                }
                                QJsonObject obj = doc.object ();
                                if (obj.isEmpty ()) {
//                                    qDebug()<<Q_FUNC_INFO<<"Convert to object error";
                                    continue;
                                }
                                QString token = obj.value ("st").toString ();
                                if (!token.isEmpty ())
                                    return token;
                                continue;
                            }
                        }
                        break;
                    }
                }
            }
        }
    }
    return QString();
}

QString WBContentParser::parseHackLoginWeiboContent(const QString &weiboContent,
                                                       const QString &contentColor,
                                                       const QString &userColor,
                                                       const QString &linkColor)
{
#if DBG_HTMLPARSER
    qDebug()<<Q_FUNC_INFO<<" >>>>>>>>>>>>>>>>>>>>> begin parser <<<<<<<<<<<<<<<<< ";
    qDebug()<<"Origin text ["<<weiboContent<<"]";
#endif
    HTML::ParserDom parser;
    tree<HTML::Node> dom = parser.parseTree(weiboContent.toStdString ());

    tree<HTML::Node>::iterator it = dom.begin();
    tree<HTML::Node>::iterator end = dom.end();

    QStringList retList;

    for (; it != end; ++it) {
        (*it).parseAttributes ();
#if DBG_HTMLPARSER
        if ((*it).isTag ()) {
            qDebug()<<"<TAG> [tagname ="<<TO_QSTR ((*it).tagName ())
                   <<"] [text="<<TO_QSTR ((*it).text ())<<"]";
        } else if ((*it).isComment ()){
            qDebug()<<"<Comment> [tagname ="<<TO_QSTR ((*it).tagName ())
                   <<"] [text="<<TO_QSTR ((*it).text ())<<"]";
        } else {
            qDebug()<<"<TEXT> [tagname ="<<TO_QSTR ((*it).tagName ())
                   <<"] [text="<<TO_QSTR ((*it).text ())<<"]";
        }
#endif
        if ((*it).isTag ()) {
            if ((*it).tagName () == "a") { //link
                QString cls = TO_QSTR((*it).attribute ("class").second);
#if DBG_HTMLPARSER
                qDebug()<<"tagName a , class name "<<cls;
#endif
                if (!cls.isEmpty ()) {
                    if (cls == "k") { // k for topic
                        //TODO add topic link
                        QString link = TO_QSTR((*it).attribute ("href").second);
                        (*++it).parseAttributes ();
                        QString text = TO_QSTR((*it).text ());
#if DBG_HTMLPARSER
                        qDebug()<<"topic text value "<<text;
#endif
                        QString tmp = QString("LinkTopic||%1").arg (link);
                        text = this->strToLink (text, tmp, linkColor);
#if DBG_HTMLPARSER
                        qDebug()<<"link is "<<text;
#endif
                        retList.append (text);
                    }
                    //TODO more types
                    else { // not for topic
                        QString link = TO_QSTR((*it).attribute ("href").second);
                        (*++it).parseAttributes ();
                        QString text = TO_QSTR((*it).text ());
#if DBG_HTMLPARSER
                        qDebug()<<"text value "<<text;
#endif
                        QString tmp = QString("LinkUnknow||%1").arg (link);
                        text = this->strToLink (text, tmp, linkColor);
#if DBG_HTMLPARSER
                        qDebug()<<"link is "<<text;
#endif
                        retList.append (text);
                    }
                } else { //class is empty
                    /******************** for video,eg. ********************/
/*
     <a data-url=\"http://t.cn/Rb8GALn\" href=\"http://m.weibo.cn/p/230444a77d0dc292d1b77904fc07593edb3680?&ep=Djd8tnoET%2C2678120877%2CDjd8tnoET%2C2678120877\">
        <i class=\"iconimg iconimg-xs\">
            <img src=\"http://h5.sinaimg.cn/upload/2015/09/25/3/timeline_card_small_video_default.png\">
        </i>
        <span class=\"surl-text\">
        秒拍视频
        </span>
    </a>
*/
                    /******************* for web link ,eg. *********************/
/*
    <a data-url=\"http://t.cn/RGCVGv8\" href=\"http://weibo.cn/sinaurl?u=http%3A%2F%2Fandroid-developers.blogspot.com%2F2016%2F02%2Fandroid-support-library-232.html&ep=Djrgcz8vq%2C1503535883%2CDjrgcz8vq%2C1503535883\">
        <i class=\"iconimg iconimg-xs\">
            <img src=\"http://h5.sinaimg.cn/upload/2015/09/25/3/timeline_card_small_web_default.png\">
        </i>
        <span class=\"surl-text\">
        网页链接
        </span>
    </a>
  */
                    QString dtUrl = TO_QSTR((*it).attribute ("data-url").second);
#if DBG_HTMLPARSER
                    qDebug()<<"tagName a , dtUrl name "<<dtUrl;
#endif
                    if (!dtUrl.isEmpty ()) { //for video or web link
                        (*++it).parseAttributes ();
                        if ((*it).tagName () == "i")
                            (*++it).parseAttributes ();
                        QString videoImg = TO_QSTR((*it).text ());
#if DBG_HTMLPARSER
                        qDebug()<<"tagName a , videoImg "<<videoImg;
#endif
                        (*++it).parseAttributes ();
                        if ((*it).tagName () == "span")
                            (*++it).parseAttributes ();
                        (*it).parseAttributes ();
                        QString text = TO_QSTR((*it).text ());
#if DBG_HTMLPARSER
                        qDebug()<<"tagName a , video text is "<<text;
#endif
                        QString tmp = QString("LinkWebOrVideo||%1").arg (dtUrl);
                        text = QString("%1%2").arg (videoImg).arg (text);
                        text = this->strToLink (text, tmp, linkColor);
#if DBG_HTMLPARSER
                        qDebug()<<"link is "<<text;
#endif
                        retList.append (text);
                    } else { //for at someone
                        QString link = TO_QSTR((*it).attribute ("href").second);
                        (*++it).parseAttributes ();
                        QString text = TO_QSTR((*it).text ());
#if DBG_HTMLPARSER
                        qDebug()<<"tagName a , at text is "<<text;
#endif
                        //update for HackPrivateMessageNoteList
                        if (!link.startsWith ("http")) { //for weibo content @ text
                            QString tmp = QString("LinkAt||%1").arg (link);
                            text = this->strToLink (text, tmp, userColor);
                        } else { //for HackPrivateMessageNoteList
                            text = this->strToLink (text, link, linkColor);
                        }
#if DBG_HTMLPARSER
                        qDebug()<<"link is "<<text;
#endif
                        retList.append (text);
                    }
                }
            } else if ((*it).tagName () == "i") { //i is for face ?
#if DBG_HTMLPARSER
                QString cls = TO_QSTR((*it).attribute ("class").second);
                qDebug()<<"tagName i , class name "<<cls;
#endif
                (*++it).parseAttributes ();
                QString text = TO_QSTR((*it).text ());
#if DBG_HTMLPARSER
                qDebug()<<"face text value "<<text;
#endif
                retList.append (text);
            } else {
                qWarning()<<Q_FUNC_INFO<<"tagName is a, but we don't know other attributes!!";
                continue;
            }
        } else { // tag is a text
            QString text = TO_QSTR((*it).text ());
#if DBG_HTMLPARSER
            qDebug()<<"simple text value "<<text;
#endif
            retList.append (text);
        }
    }
#if DBG_HTMLPARSER
    QString ret = retList.join ("");
    qDebug()<<Q_FUNC_INFO<<"ret is "<<ret;
    qDebug()<<Q_FUNC_INFO<<" >>>>>>>>>>>>>>>>>>>>>  end of parser <<<<<<<<<<<<<< ";
#endif
    return retList.join ("");
}

QString WBContentParser::parseEmoticons(const QString &pattern, const QString &emoticonStr)
{
    QString tmp = emoticonStr;

    int  pos = 0;
    QString reText;
    QString emoticons;
    QRegExp emoticonRE(pattern);
    if (!m_emoticons)
        m_emoticons = new Emoticons(this);

    while((pos = emoticonRE.indexIn(tmp, pos)) != -1) {
        emoticons = emoticonRE.cap(0);
        emoticons = m_emoticons->getEmoticonName (emoticons);
        if (emoticons.isEmpty()) {
            pos += emoticonRE.cap(0).length();
            continue;
        }
        emoticons = SailfishApp::pathTo(QString("qml/emoticons/%1").arg(emoticons)).toString();
        ///FIXME 似乎以file:///path 形式的路径在qml里面显示有问题，所以去掉file：///，直接使用绝对路径
//        emoticons = emoticons.replace("file:///", "/");
        reText = QString("<img src=\"%1\">").arg(emoticons);
        tmp.replace(pos, emoticonRE.cap(0).length(), reText);
        pos += reText.length();
    }

    return tmp;
}
