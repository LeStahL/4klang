#include "TreeItem4kp.h"

TreeItem4kp::TreeItem4kp(QObject *parent)
    : QObject(parent)
    , _name(QString(""))
    , _type(TreeItemType::Patch)
    , _parent(nullptr)
    , _4klang_data(nullptr)
{

}

TreeItem4kp::~TreeItem4kp()
{

}

QObject *TreeItem4kp::child(int index) {
    return _children.at(index);
}

void TreeItem4kp::setChild(int index, QObject *newChild) {
    _children[index] = newChild;
}

QObject *TreeItem4kp::parent() {
    return QObject::parent();
}

int TreeItem4kp::childCount() {
    return _children.size();
}

int TreeItem4kp::row() {
    // TODO: implement
    return 0;
}

QString TreeItem4kp::name() {
    return _name;
}

void *TreeItem4kp::data4klang() {
    return _4klang_data;
}

TreeItemType TreeItem4kp::type() {
    return _type;
}

QString TreeItem4kp::treeKey() {
    // TODO: implement
    return QString("");
}

QObject *TreeItem4kp::childByTreeKey(QString treeKey) {
    // TODO: implement
    return nullptr;
}
