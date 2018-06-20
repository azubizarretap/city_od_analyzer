# Proyecto de analisis de eventos y trafico de la ciudad de Barcelona (UOC)

El objetivo del presente proyecto es el de diseñar una plataforma para poder analizar los datos de eventos y transporte de la ciudad de Barcelona para asi identificar cuales son las mejores opciones de transporte publico que ofrece la ciudad para llegar a los eventos que nos interesen.

Los requisitos para poder utilizar la plataforma son:

* Xubuntu 16.04 (o cualquier derivado de Ubuntu) - http://ftp.dei.uc.pt/pub/linux/xubuntu/releases/16.04/release/
* Postgresql 9.5
* PgAdmin
* PostGis 2.2 - https://postgis.net/install/
* Pentaho Data Integration 7.1 - https://sourceforge.net/projects/pentaho/files/Data%20Integration/7.1/
* Tableau Desktop 2018.1 - https://www.tableau.com/es-es/products/desktop

Para utilizar el proyecto basta con generar el data warehouse usando el script .sql que se encuentra en el directorio Database del proyecto.

Una vez cargada la base de datos, abrir el fichero Main_Job.kjb del directorio ETL usando Pentaho PDI 7.1. 

Lanzar el job para descargar los datos y cargar la informacion del data warehouse.

Por ultimo, abrir el libro de trabajo Transporte_Eventos_Barcelona del directorio Dashboard con Tableau 2018.1 y comenzar la explotacion de datos.
