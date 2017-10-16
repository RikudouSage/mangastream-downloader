#ifndef IMAGEDOWNLOADER_H
#define IMAGEDOWNLOADER_H

#include <QObject>
#include <QString>

class ImageDownloader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString path READ getPath WRITE setPath NOTIFY pathChanged)
public:
    Q_INVOKABLE bool download(const QString url, QString manga, const QString chapter, QString savePath);
    Q_INVOKABLE void reset();
    QString getPath();
    void setPath(QString newPath);

signals:
    void downloadComplete();
    void invalidCharacters();
    void pathChanged();

private:
    int i = 1;
    QString path;
    QString validateFilename(QString filename);
};

#endif // IMAGEDOWNLOADER_H
