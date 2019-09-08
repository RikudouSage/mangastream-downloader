#ifndef MISCTOOLS_H
#define MISCTOOLS_H

#include <QObject>
#include <QString>
#include <QVersionNumber>
#include <QDir>
#include <QDesktopServices>
#include <QUrl>
#include <QFile>
#include <QLocale>
#include <QSettings>
#include <QUrl>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QEventLoop>
#include <QSslSocket>

class MiscTools : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString appPath READ getAppPath CONSTANT)
    Q_PROPERTY(QString filePrefix READ getFilePrefix)
public:
    Q_INVOKABLE bool openDirectory(QString directory);
    QString getAppPath();
    QString getFilePrefix();
    Q_INVOKABLE bool isWindows();
    Q_INVOKABLE QString getLanguage();
    Q_INVOKABLE void setLanguage(QString language);
    Q_INVOKABLE void checkNewVersion();

signals:
    void settingsFileNotWritable();
    void languageChanged();
    void newVersionAvailable(QString newVersion);

private:
    QString language = "";
    const QString settingsFile = "./appSettings.ini";
    const QVersionNumber version = QVersionNumber(1, 2, 1);
};

#endif // MISCTOOLS_H
