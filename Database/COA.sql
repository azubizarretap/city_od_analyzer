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
	CALLE TEXT NOT NULL,
	NUM_CALLE TEXT,
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
	ID_EVENTO_ORIG TEXT NOT NULL,
	NOMBRE TEXT NOT NULL,
	FECHA_INICIO DATE,
	HORA_INICIO TIME,
	FECHA_FIN DATE,
	FECHA_PROXIMO_EVENTO DATE,
	FECHA_APROXIMADA TEXT,
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
	ID_UBICACION_ORIG TEXT,
	NOMBRE TEXT NOT NULL,
	CALLE TEXT,
	NUMERO INTEGER,
	LATITUD NUMERIC NOT NULL,
	LONGITUD NUMERIC NOT NULL,
	THE_GEOM GEOMETRY,
	ID_DISTRITO INTEGER,
	CONSTRAINT PK_UBICACION_EVENTO PRIMARY KEY (ID_UBICACION_EVENTO),
	CONSTRAINT FK_ID_DISTRITO FOREIGN KEY (ID_DISTRITO) REFERENCES D_DISTRITO (ID_DISTRITO)
);

--Dimension Ubicaciones_Eventos
CREATE TABLE COA.D_UBICACIONES_EVENTOS (
	ID_UBICACIONES_EVENTOS SERIAL NOT NULL,
	ID_UBICACION_EVENTO INTEGER,
	ID_EVENTO INTEGER,
	CONSTRAINT PK_D_UBICACIONES_EVENTOS PRIMARY KEY (ID_UBICACIONES_EVENTOS),
	CONSTRAINT FK_ID_UBICACION_EVENTO FOREIGN KEY (ID_UBICACION_EVENTO) REFERENCES D_UBICACION_EVENTO (ID_UBICACION_EVENTO),
	CONSTRAINT FK_ID_EVENTO FOREIGN KEY (ID_EVENTO) REFERENCES D_EVENTO (ID_EVENTO)
);

--Tabla de hecho paradas
CREATE TABLE COA.D_PARADA (
	ID_PARADA SERIAL NOT NULL,
	LATITUD NUMERIC NOT NULL,
	LONGITUD NUMERIC NOT NULL,
	THE_GEOM GEOMETRY,
	ID_BARRIO INTEGER,
	ID_TRANSPORTE INTEGER,
	CONSTRAINT PK_D_PARADA PRIMARY KEY (ID_PARADA),
	CONSTRAINT FK_ID_BARRIO FOREIGN KEY (ID_BARRIO) REFERENCES D_BARRIO (ID_BARRIO),
	CONSTRAINT FK_ID_TRANSPORTE FOREIGN KEY (ID_TRANSPORTE) REFERENCES D_TRANSPORTE (ID_TRANSPORTE)
);

--Dimension Paradas_Eventos
CREATE TABLE COA.F_PARADAS_EVENTOS (
	ID_PARADAS_EVENTOS SERIAL NOT NULL,
	ID_UBICACION_EVENTO INTEGER,
	ID_PARADA INTEGER,
	NUM_EVENTOS INTEGER DEFAULT 0,
	DURACION_EVENTO INTEGER DEFAULT 1,
	CONSTRAINT PK_F_PARADAS_EVENTOS PRIMARY KEY (ID_PARADAS_EVENTOS),
	CONSTRAINT FK_ID_UBICACION_EVENTO FOREIGN KEY (ID_UBICACION_EVENTO) REFERENCES D_UBICACION_EVENTO (ID_UBICACION_EVENTO),
	CONSTRAINT FK_ID_PARADA FOREIGN KEY (ID_PARADA) REFERENCES D_PARADA (ID_PARADA)
);

--Generamos vista donde se relacionan los transportes con los eventos

CREATE OR REPLACE VIEW COA.V_TRANSPORTE_EVENTOS AS

SELECT	DISTINCT E.Nombre As Nombre ,UE.Latitud As Latitud,UE.Longitud As Longitud, 'Evento' As Tipo
FROM
	COA.D_NIVEL_EVENTO NE,
	COA.D_EVENTO E,
	COA.D_UBICACIONES_EVENTOS UES,
	COA.D_UBICACION_EVENTO UE,
	COA.F_PARADAS_EVENTOS PE
WHERE
	NE.ID_NIVEL_EVENTO = E.ID_NIVEL_EVENTO
	AND E.ID_EVENTO = UES.ID_EVENTO
	AND UES.ID_UBICACION_EVENTO = UE.ID_UBICACION_EVENTO
	AND UE.ID_UBICACION_EVENTO = PE.ID_UBICACION_EVENTO
UNION
SELECT	DISTINCT T.Equipamiento As Nombre ,P.Latitud As Latitud,P.Longitud As Longitud, AT.Nombre As Tipo
FROM
	COA.D_PARADA P,
	COA.D_TRANSPORTE T,
	COA.A_TIPO_TRANSPORTE AT,
	COA.D_ESTACION_BICING EB,
	COA.F_PARADAS_EVENTOS PE
WHERE
	PE.ID_PARADA = P.ID_PARADA
	AND P.ID_TRANSPORTE = T.ID_TRANSPORTE
	AND T.ID_TIPO_TRANSPORTE = AT.ID_TIPO_TRANSPORTE
UNION
SELECT	DISTINCT EB.Calle As Nombre ,P.Latitud As Latitud,P.Longitud As Longitud, AT.Nombre As Tipo
FROM
	COA.D_PARADA P,
	COA.D_TRANSPORTE T,
	COA.A_TIPO_TRANSPORTE AT,
	COA.D_ESTACION_BICING EB,
	COA.F_PARADAS_EVENTOS PE
WHERE
	PE.ID_PARADA = P.ID_PARADA
	AND P.ID_TRANSPORTE = T.ID_TRANSPORTE
	AND T.ID_ESTACION_BICING = EB.ID_ESTACION_BICING
	AND T.ID_TIPO_TRANSPORTE = AT.ID_TIPO_TRANSPORTE;

CREATE OR REPLACE VIEW COA.V_EVENTOS_BARRIO_DISTRITO AS
SELECT	DISTINCT E.Nombre As Nombre ,UE.Latitud As Latitud,UE.Longitud As Longitud, B.Nombre As Barrio, D.Nombre As Distrito, E.Tipo_Evento As Tipo
FROM
	COA.D_EVENTO E,
	COA.D_UBICACIONES_EVENTOS UES,
	COA.D_UBICACION_EVENTO UE,
	COA.D_DISTRITO D,
	COA.D_BARRIO B
WHERE
	E.ID_EVENTO = UES.ID_EVENTO
	AND UES.ID_UBICACION_EVENTO = UE.ID_UBICACION_EVENTO
	AND UE.ID_DISTRITO = D.ID_DISTRITO
	AND D.ID_DISTRITO = B.ID_DISTRITO;

CREATE OR REPLACE VIEW COA.V_ESTACION_BICING_EVENTO AS
SELECT	E.ID_Evento As ID, E.Nombre As Nombre ,UE.Latitud As Latitud,UE.Longitud As Longitud, 'Evento' As Tipo
FROM
	COA.D_NIVEL_EVENTO NE,
	COA.D_EVENTO E,
	COA.D_UBICACIONES_EVENTOS UES,
	COA.D_UBICACION_EVENTO UE,
	COA.F_PARADAS_EVENTOS PE
WHERE
	NE.ID_NIVEL_EVENTO = E.ID_NIVEL_EVENTO
	AND E.ID_EVENTO = UES.ID_EVENTO
	AND UES.ID_UBICACION_EVENTO = UE.ID_UBICACION_EVENTO
	AND UE.ID_UBICACION_EVENTO = PE.ID_UBICACION_EVENTO
UNION

SELECT	EB.ID_ESTACION_BICING As ID, T.Equipamiento As Nombre,P.Latitud As Latitud, P.Longitud As Longitud, 'Estacion_Bicing' As Tipo
FROM
	COA.D_TRANSPORTE T,
	COA.D_ESTACION_BICING EB,
	COA.D_PARADA P,
	COA.F_PARADAS_EVENTOS PE
WHERE
	T.ID_ESTACION_BICING = EB.ID_ESTACION_BICING
	AND P.ID_TRANSPORTE = T.ID_TRANSPORTE
	AND PE.ID_PARADA=P.ID_PARADA;

CREATE VIEW V_NUMERO_EVENTOS_POR_PARADA AS
SELECT PE.Num_Eventos As Numero_Eventos,P.Latitud As Latitud, P.Longitud As Longitud, P.ID_Parada As ID, D.Nombre As Distrito
FROM
	COA.F_PARADAS_EVENTOS PE,
	COA.D_PARADA P,
	COA.D_BARRIO B,
	COA.D_DISTRITO D
WHERE
	PE.ID_PARADA = P.ID_PARADA
	AND P.ID_BARRIO = B.ID_BARRIO
	AND B.ID_DISTRITO = D.ID_DISTRITO;