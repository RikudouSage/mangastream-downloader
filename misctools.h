#ifndef MISCTOOLS_H
#define MISCTOOLS_H

#include <QObject>
#include <QString>
#include <QGuiApplication>

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

signals:
    void settingsFileNotWritable();
    void languageChanged();

private:
    QString language = "";
    const QString settingsFile = "./appSettings.ini";
};

#endif // MISCTOOLS_H
