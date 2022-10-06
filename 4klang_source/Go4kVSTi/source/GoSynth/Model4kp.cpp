#include "Model4kp.h"
#include "Go4kVSTiCore.h"

Model4kp::Model4kp(QObject *parent) 
    : QAbstractItemModel(parent)
    , _synthObject(Go4kVSTi_GetSynthObject())
{
    Go4kVSTi_Init();
    Go4kVSTi_ResetPatch();
    Go4kVSTi_ResetGlobal();
}

Model4kp::~Model4kp()
{
}

void Model4kp::load(QString filename) {
    Go4kVSTi_LoadPatch((char *)filename.toStdString().c_str());
}

QModelIndex Model4kp::index(int row, int column, const QModelIndex &parent) const {
    if(!hasIndex(row, column, parent)) {
        return QModelIndex();
    }

    if(!parent.isValid()) {
        
    }

}

QModelIndex Model4kp::parent(const QModelIndex &index) const {
    return QModelIndex();
}

int Model4kp::rowCount(const QModelIndex &parent) const {
    return 0;
}

int Model4kp::columnCount(const QModelIndex &parent) const {
    return 0;
}

QVariant Model4kp::data(const QModelIndex &index, int role) const {
    return QVariant();
}

bool Model4kp::setData(const QModelIndex &index, const QVariant &value, int role) {
    return false;
}

Qt::ItemFlags Model4kp::flags(const QModelIndex &index) const {
    return Qt::ItemIsEditable;
}

QVariant Model4kp::headerData(int section, Qt::Orientation orientation, int role) const {
    return QVariant();
}

// QModelIndex Model4kp::createIndex(int row, int column, void *ptr) const {
//     return QModelIndex();
// }
