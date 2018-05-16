﻿--Generamos el esquema en el cual trabajaremos

DROP SCHEMA IF EXISTS COA CASCADE;

CREATE SCHEMA COA;

SET search_path TO COA,public;

--Generamos las dimensiones

--Dimension Distrito
CREATE TABLE COA.D_DISTRITO (
	ID_DISTRITO INTEGER NOT NULL,
	NOMBRE TEXT NOT NULL,
	CONSTRAINT PK_DISTRITO PRIMARY KEY (ID_DISTRITO)
);

--Dimension Barrio
CREATE TABLE COA.D_BARRIO (
	ID_BARRIO SERIAL NOT NULL,
	NOMBRE TEXT NOT NULL,
	ID_DISTRITO INTEGER,
	CONSTRAINT PK_BARRIO PRIMARY KEY (ID_BARRIO),
	CONSTRAINT FK_DISTRITO FOREIGN KEY (ID_DISTRITO) REFERENCES D_DISTRITO (ID_DISTRITO)
);

--Dimension Estaciones_Bicing
CREATE TABLE COA.D_ESTACION_BICING (
	ID_ESTACION_BICING SERIAL NOT NULL,
	ESTADO TEXT NOT NULL,
	PLAZAS INTEGER NOT NULL,
	ESTACIONES_CERCANAS TEXT NOT NULL,
	UNIDADES_DISPONIBLES INTEGER NOT NULL,
	CONSTRAINT PK_ESTACION_BICING PRIMARY KEY (ID_ESTACION_BICING)
);

--Auxiliar Tipo_Transporte
CREATE TABLE COA.A_TIPO_TRANSPORTE (
	ID_TIPO_TRANSPORTE SERIAL NOT NULL,
	NOMBRE TEXT NOT NULL,
	CONSTRAINT PK_TIPO_TRANSPORTE PRIMARY KEY (ID_TIPO_TRANSPORTE)
);

--Dimension Transporte
CREATE TABLE COA.D_TRANSPORTE (
	ID_TRANSPORTE SERIAL NOT NULL,
	EQUIPAMIENTO TEXT NOT NULL,
	ID_ESTACION_BICING INTEGER,
	ID_TIPO_TRANSPORTE INTEGER,
	CONSTRAINT PK_TRANSPORTE PRIMARY KEY (ID_TRANSPORTE),
	CONSTRAINT FK_ESTACION_BICING FOREIGN KEY (ID_ESTACION_BICING) REFERENCES D_ESTACION_BICING (ID_ESTACION_BICING),
	CONSTRAINT FK_TIPO_TRANSPORTE FOREIGN KEY (ID_TIPO_TRANSPORTE) REFERENCES A_TIPO_TRANSPORTE (ID_TIPO_TRANSPORTE)
);

--Dimension Nivel_Evento
CREATE TABLE COA.D_NIVEL_EVENTO (
	ID_NIVEL_EVENTO SERIAL NOT NULL,
	NOMBRE TEXT NOT NULL,
	CONSTRAINT PK_NIVEL_EVENTO PRIMARY KEY (ID_NIVEL_EVENTO)
);

--Dimension Evento
CREATE TABLE COA.D_EVENTO (
	ID_EVENTO SERIAL NOT NULL,
	NOMBRE TEXT NOT NULL,
	FECHA_INICIO DATE,
	HORA_INICIO TIME,
	FECHA_FIN DATE,
	FECHA_PROXIMO_EVENTO DATE,
	FECHA_APROXIMADA DATE,
	FECHA_RELATIVA DATE,
	TIPO_EVENTO TEXT,
	ESTADO TEXT,
	CICLO_ESTADO TEXT,
	ID_NIVEL_EVENTO INTEGER,
	CONSTRAINT PK_EVENTO PRIMARY KEY (ID_EVENTO),
	CONSTRAINT FK_NIVEL_EVENTO FOREIGN KEY (ID_NIVEL_EVENTO) REFERENCES D_NIVEL_EVENTO (ID_NIVEL_EVENTO)
);

--Dimension Ubicacion_Evento
CREATE TABLE COA.D_UBICACION_EVENTO (
	ID_UBICACION_EVENTO SERIAL,
	NOMBRE TEXT NOT NULL,
	CALLE TEXT NOT NULL,
	NUMERO INTEGER,
	LATITUD NUMERIC NOT NULL,
	LONGITUD NUMERIC NOT NULL,
	THE_GEOM GEOMETRY,
	ID_DISTRITO INTEGER NOT NULL,
	ID_EVENTO INTEGER NOT NULL,
	CONSTRAINT PK_UBICACION_EVENTO PRIMARY KEY (ID_UBICACION_EVENTO),
	CONSTRAINT FK_ID_DISTRITO FOREIGN KEY (ID_DISTRITO) REFERENCES D_DISTRITO (ID_DISTRITO),
	CONSTRAINT FK_ID_EVENTO FOREIGN KEY (ID_EVENTO) REFERENCES D_EVENTO (ID_EVENTO)
);

--Tabla de hecho paradas
CREATE TABLE COA.F_PARADA (
	ID_PARADA SERIAL NOT NULL,
	LATITUD NUMERIC NOT NULL,
	LONGITUD NUMERIC NOT NULL,
	THE_GEOM GEOMETRY,
	NUM_SALIDAS INTEGER NOT NULL,
	ID_BARRIO INTEGER NOT NULL,
	ID_TRANSPORTE INTEGER,
	CONSTRAINT PK_F_PARADA PRIMARY KEY (ID_PARADA),
	CONSTRAINT FK_ID_BARRIO FOREIGN KEY (ID_BARRIO) REFERENCES D_BARRIO (ID_BARRIO),
	CONSTRAINT FK_ID_TRANSPORTE FOREIGN KEY (ID_TRANSPORTE) REFERENCES D_TRANSPORTE (ID_TRANSPORTE)
);

--Dimension Paradas_Eventos
CREATE TABLE COA.D_PARADAS_EVENTO (
	ID_PARADAS_EVENTO SERIAL NOT NULL,
	ID_UBICACION_EVENTO INTEGER,
	ID_PARADA INTEGER,
	CONSTRAINT PK_F_PARADAS_EVENTO PRIMARY KEY (ID_PARADAS_EVENTO),
	CONSTRAINT FK_ID_UBICACION_EVENTO FOREIGN KEY (ID_UBICACION_EVENTO) REFERENCES D_UBICACION_EVENTO (ID_UBICACION_EVENTO),
	CONSTRAINT FK_ID_PARADA FOREIGN KEY (ID_PARADA) REFERENCES F_PARADA (ID_PARADA)
);