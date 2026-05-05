#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>

#include "Controllers/databasemanager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    DatabaseManager databaseManager;
    databaseManager.openDatabase();

    QQuickStyle::setStyle("Basic");

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("databaseManager", &databaseManager);
    // engine.rootContext()->setContextProperty("database", databaseObject);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection
        );

    engine.loadFromModule("Basic_Qt_Cashier", "Main");

    return app.exec();
}