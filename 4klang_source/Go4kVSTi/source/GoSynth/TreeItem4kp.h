#pragma once

#include <QObject>
#include <QList>
#include <QString>

typedef enum {
    Patch,
    Instrument,
    Unit
} TreeItemType;

class TreeItem4kp : public QObject {
    Q_OBJECT
    
    QString _name;
    TreeItemType _type;
    QList<QObject *> _children;
    QObject *_parent;
    void *_4klang_data;

    public:
    TreeItem4kp(QObject *parent = nullptr);
    virtual ~TreeItem4kp();

    QObject *child(int index);
    void setChild(int index, QObject *newChild);
    QObject *parent();
    int childCount();
    int row();
    QString name();
    void *data4klang();
    TreeItemType type();
    QString treeKey();
    QObject *childByTreeKey(QString treeKey);
};