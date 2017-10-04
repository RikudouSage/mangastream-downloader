#include "headers/mangastream.h"

QString MangaStream::getContentOfUrl(QString url) {
    QUrl dUrl(url);
    QNetworkRequest request(dUrl);
    QNetworkAccessManager mgr;
    QNetworkReply * reply = mgr.get(request);

    QEventLoop evtLoop;
    QObject::connect(&mgr,SIGNAL(finished(QNetworkReply*)), &evtLoop, SLOT(quit()));
    evtLoop.exec();

    QString answer = reply->readAll();
    return answer;
}

QStringList MangaStream::getListOfManga() {
    QStringList ret;

    QString answer = getContentOfUrl("http://mangastream.com/manga");

    int startPos = answer.indexOf("<table class=\"table table-striped\">");
    int endPos = answer.indexOf("</table>", startPos);
    int length = endPos - startPos;

    QString table = answer.mid(startPos, length);

    int pos = 0;
    while(true) {
        QRegularExpression regexp("<td><strong><a href=\"(.+)\">(.+?)</a></strong></td>");
        int start = table.indexOf(regexp, pos);
        if(start < 0) {
            break;
        }
        int end = table.indexOf("</td>", start) + 5;
        int len = end - start;
        QString line = table.mid(start, len);

        QRegularExpressionMatch matches = regexp.match(line);

        QString url = matches.captured(1);
        QString name = matches.captured(2);

        ret << url << name;

        pos = end;
    }

    return ret;
}

QStringList MangaStream::getListOfChapters(QString url) {
    QStringList ret;

    QString answer = getContentOfUrl(url);

    int startPos = answer.indexOf("<table class=\"table table-striped\">");
    int endPos = answer.indexOf("</table>", startPos);
    int length = endPos - startPos;

    QString table = answer.mid(startPos, length);

    int pos = 0;
    while(true) {
        QRegularExpression regexp("<td><a href=\"(.+)\">(.+?)</a></td>");
        int start = table.indexOf(regexp, pos);
        if(start < 0) {
            break;
        }
        int end = table.indexOf("</td>", start) + 5;
        int len = end - start;
        QString line = table.mid(start, len);
        QRegularExpressionMatch matches = regexp.match(line);

        QString url = matches.captured(1);
        QString name = matches.captured(2);

        ret << url << name;

        pos = end;
    }

    return ret;
}

QStringList MangaStream::getImages(QString url) {
    QStringList ret;
    QString chapter = url.split("/").at(5);

    QString currentChapter = chapter;
    QString currentUrl = url;

    while(currentChapter == chapter) {
        QString answer = getContentOfUrl(currentUrl);
        QString searchString("<div class=\"page\">");
        int startPos = answer.indexOf(searchString) + searchString.length();
        int endPos = answer.indexOf("</div>", startPos);
        int length = endPos - startPos;

        QString line = answer.mid(startPos, length);

        QRegularExpression regexp("<a href=\"(.+)\"><img id=\"manga-page\" src=\"(.+)\" /></a>");

        QRegularExpressionMatch matches = regexp.match(line);

        if(matches.captured(2).length() > 0) {
            ret << "http:"+matches.captured(2);
        }

        currentUrl = matches.captured(1);
        if(currentUrl.split("/").length() > 5) {
            currentChapter = currentUrl.split("/").at(5);
        } else {
            currentChapter = "";
        }
    }

    return ret;
}
