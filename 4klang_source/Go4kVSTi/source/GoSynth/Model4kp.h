#pragma once

#include <QAbstractItemModel>
#include <QModelIndex>
#include <QVariant>
#include <QUndoStack>

#include "Go4kVSTiCore.h"
#include "TreeItem4kp.h"
#include "Model4kp.h"

class Model4kp : public QAbstractItemModel {
    Q_OBJECT

    SynthObjectP _synthObject;
    TreeItem4kp *_rootItem;

    public:
    Model4kp(QObject *parent = nullptr);
    virtual ~Model4kp();

    void load(QString filename);

    QModelIndex index(int row, int column, const QModelIndex &parent = QModelIndex()) const;
    QModelIndex parent(const QModelIndex &index) const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    int columnCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole);
    Qt::ItemFlags flags(const QModelIndex &index) const;
    QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const;
    // QModelIndex createIndex(int row, int column, void *ptr = nullptr) const;
};
