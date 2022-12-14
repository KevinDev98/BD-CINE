CREATE OR ALTER PROCEDURE SP_UPDATE_DATA
@FASE INT
AS
BEGIN
	IF @FASE=0  ----ACTUALIZA EL HORARIO DE LAS PELICULAS
	BEGIN
		UPDATE FUNCIONES SET ESTATUS_FUNCION=CASE WHEN HORARIO<GETDATE() THEN 0 ELSE 1 END
		WHERE ESTATUS_FUNCION=1

		INSERT INTO HIST_LOG_ACTIVIDADES(TABLA,ACCION,USUARIO_HOST)
		VALUES('SP', 'EJECUCION DE STORED PROCEDURE 0',
		(SELECT TOP 1 CONCAT('USUARIO "', login_name, '" DEL SERVIDOR ', host_name, ' ',
		(SELECT client_net_address FROM sys. dm_exec_connections WHERE session_id = @@SPID) )
		FROM sys.dm_exec_sessions WHERE host_name is not null AND session_id=@@SPID ) )
	END
	IF @FASE=1  ---ACTUALIZA MONTOS
	BEGIN
		UPDATE BL SET BL.ESTAUS_BOLETO=0
		FROM dbo.VENTAS VT JOIN dbo.BOLETOS BL ON  VT.ID_VENTA=BL.FK_VENTA
		JOIN dbo.PRECIOS_BOLETOS  PB ON PB.ID_PRECIO=BL.FK_PRECIO_BOLETO
		WHERE BL.FK_VENTA=VT.ID_VENTA
		AND VT.ESTATUS_VENTA=0

		UPDATE VT SET MONTO_TOTAL=dbo.FN_MONTO_VENTA(vt.ID_VENTA)		
		FROM dbo.VENTAS VT 
		WHERE VT.ESTATUS_VENTA=1

		INSERT INTO HIST_LOG_ACTIVIDADES(TABLA,ACCION,USUARIO_HOST)
		VALUES('SP', 'EJECUCION DE STORED PROCEDURE 1',
		(SELECT TOP 1 CONCAT('USUARIO "', login_name, '" DEL SERVIDOR ', host_name, ' ',
		(SELECT client_net_address FROM sys. dm_exec_connections WHERE session_id = @@SPID) )
		FROM sys.dm_exec_sessions WHERE host_name is not null AND session_id=@@SPID ) )
	END
	IF @FASE=2
	BEGIN
		UPDATE PRECIOS_BOLETOS SET MONTO_DESC=(PRECIO_INIT*PORCENT_DESC)
		UPDATE PRECIOS_BOLETOS SET PRECIO_FINAL=(PRECIO_INIT-MONTO_DESC)
		INSERT INTO HIST_LOG_ACTIVIDADES(TABLA,ACCION,USUARIO_HOST)

		VALUES('SP', 'EJECUCION DE STORED PROCEDURE 2',
		(SELECT TOP 1 CONCAT('USUARIO "', login_name, '" DEL SERVIDOR ', host_name, ' ',
		(SELECT client_net_address FROM sys. dm_exec_connections WHERE session_id = @@SPID) )
		FROM sys.dm_exec_sessions WHERE host_name is not null AND session_id=@@SPID ) )
	END
END 
