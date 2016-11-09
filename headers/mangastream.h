#ifndef MANGASTREAM_H
#define MANGASTREAM_H

#include "isdebug.h"
#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QStringList>
#include <QUrl>
#include <QEventLoop>
#include <QByteArray>
#include <QIODevice>
#include <QRegularExpression>

class MangaStream : public QObject {
    Q_OBJECT
public:
    Q_INVOKABLE QStringList getListOfManga();
    Q_INVOKABLE QStringList getListOfChapters(QString url);
    Q_INVOKABLE QStringList getImages(QString url);
private:
    QString getContentOfUrl(QString url);
};

#endif // MANGASTREAM_H
