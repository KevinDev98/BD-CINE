CREATE OR ALTER TRIGGER TG_INSERT_BOLETOS
ON dbo.BOLETOS
AFTER INSERT
AS
BEGIN
	BEGIN TRY
		INSERT INTO HIST_LOG_ACTIVIDADES(TABLA,ACCION,USUARIO_HOST)
		VALUES('BOLETOS', 'SE INSERTO UN NUEVO REGISTRO',
		(SELECT TOP 1 CONCAT('USUARIO "', login_name, '" DEL SERVIDOR ', host_name, ' ',
		(SELECT client_net_address FROM sys. dm_exec_connections WHERE session_id = @@SPID) )
		FROM sys.dm_exec_sessions WHERE host_name is not null AND session_id=@@SPID ) )
		
		BEGIN TRY
			DECLARE @MONTO_IND AS DECIMAL(9,2)=0.0
			DECLARE @MONTO_FINAL AS DECIMAL(9,2)=0.0
			DECLARE CURSOR_MONTOS CURSOR FOR 
			SELECT  (SELECT TOP 1 PRECIO_FINAL FROM PRECIOS_BOLETOS WHERE ID_PRECIO=BL.FK_PRECIO_BOLETO) FROM dbo.VENTAS VT
				JOIN dbo.BOLETOS BL ON  VT.ID_VENTA=BL.FK_VENTA
				--JOIN dbo.PRECIOS_BOLETOS  PB ON PB.ID_PRECIO=BL.FK_PRECIO_BOLETO
				WHERE BL.FK_VENTA=VT.ID_VENTA
				AND VT.ESTATUS_VENTA=0
				AND VT.ID_VENTA=(SELECT ID_BOLETO FROM INSERTED)
			OPEN CURSOR_MONTOS FETCH CURSOR_MONTOS INTO @MONTO_IND
			WHILE @@FETCH_STATUS=0
			BEGIN
				SET @MONTO_FINAL=@MONTO_FINAL+@MONTO_IND
				FETCH CURSOR_MONTOS INTO @MONTO_IND
			END
			CLOSE CURSOR_MONTOS
			DEALLOCATE CURSOR_MONTOS
	 
			UPDATE VT SET MONTO_TOTAL=@MONTO_FINAL
			FROM dbo.VENTAS VT JOIN dbo.BOLETOS BL ON  VT.ID_VENTA=BL.FK_VENTA
			WHERE BL.ID_BOLETO=(SELECT ID_BOLETO FROM INSERTED)
			AND BL.ESTAUS_BOLETO=1
			AND VT.ID_VENTA=(SELECT ID_BOLETO FROM INSERTED)
		END TRY
		BEGIN CATCH
			INSERT INTO HIST_LOG_ACTIVIDADES(TABLA,ACCION,USUARIO_HOST)
			VALUES('BOLETOS', CONCAT('INSERT ERROR DURANTE LA TRANSACCIÓN', ERROR_MESSAGE()),
			(SELECT TOP 1 CONCAT('USUARIO "', login_name, '" DEL SERVIDOR ', host_name, ' ',
			(SELECT client_net_address FROM sys. dm_exec_connections WHERE session_id = @@SPID) )
			FROM sys.dm_exec_sessions WHERE host_name is not null AND session_id=@@SPID ) )
			CLOSE CURSOR_MONTOS
			DEALLOCATE CURSOR_MONTOS
		END CATCH		

		PRINT 'Boleto registrado correctamente'
	END TRY
	BEGIN CATCH
	END CATCH
END
GO

CREATE OR ALTER TRIGGER TG_UPDATE_BOLETOS
ON dbo.BOLETOS
AFTER UPDATE
AS
BEGIN
	BEGIN TRY
		INSERT INTO HIST_LOG_ACTIVIDADES(TABLA,ACCION,USUARIO_HOST)
		VALUES('BOLETOS', 'DATO ACTUALIZADO',
		(SELECT TOP 1 CONCAT('USUARIO "', login_name, '" DEL SERVIDOR ', host_name, ' ',
		(SELECT client_net_address FROM sys. dm_exec_connections WHERE session_id = @@SPID) )
		FROM sys.dm_exec_sessions WHERE host_name is not null AND session_id=@@SPID ) )
		PRINT 'Boleto actualizado correctamente'
	END TRY
	BEGIN CATCH
		INSERT INTO HIST_LOG_ACTIVIDADES(TABLA,ACCION,USUARIO_HOST)
			VALUES('BOLETOS', CONCAT('UPDATE ERROR DURANTE LA TRANSACCIÓN', ERROR_MESSAGE()),
			(SELECT TOP 1 CONCAT('USUARIO "', login_name, '" DEL SERVIDOR ', host_name, ' ',
			(SELECT client_net_address FROM sys. dm_exec_connections WHERE session_id = @@SPID) )
			FROM sys.dm_exec_sessions WHERE host_name is not null AND session_id=@@SPID ) )
	END CATCH
END
GO

CREATE OR ALTER TRIGGER TG_DELETE_BOLETOS
ON dbo.BOLETOS
FOR DELETE
AS 
BEGIN
	PRINT 'No es posible eliminar boletos'
	ROLLBACK;
	INSERT INTO HIST_LOG_ACTIVIDADES(TABLA,ACCION,USUARIO_HOST)
	VALUES('BOLETOS', 'Se intento eliminar registro',
	(SELECT TOP 1 CONCAT('USUARIO "', login_name, '" DEL SERVIDOR ', host_name, ' ',
	(SELECT client_net_address FROM sys. dm_exec_connections WHERE session_id = @@SPID) )
	FROM sys.dm_exec_sessions WHERE host_name is not null AND session_id=@@SPID ) )
		
END
GO
----------------------------------------EMPLEADOS
CREATE OR ALTER TRIGGER TG_INSERT_EMPLEADOS
ON dbo.EMPLEADOS
AFTER INSERT
AS
BEGIN
	BEGIN TRY
		INSERT INTO HIST_LOG_ACTIVIDADES(TABLA,ACCION,USUARIO_HOST)
		VALUES('EMPLEADOS', 'SE INSERTO UN NUEVO REGISTRO',
		(SELECT TOP 1 CONCAT('USUARIO "', login_name, '" DEL SERVIDOR ', host_name, ' ',
		(SELECT client_net_address FROM sys. dm_exec_connections WHERE session_id = @@SPID) )
		FROM sys.dm_exec_sessions WHERE host_name is not null AND session_id=@@SPID ) )

		PRINT 'Empleado registrado correctamente'
	END TRY
	BEGIN CATCH
		INSERT INTO HIST_LOG_ACTIVIDADES(TABLA,ACCION,USUARIO_HOST)
			VALUES('EMPLEADOS', CONCAT('INSERT ERROR DURANTE LA TRANSACCIÓN', ERROR_MESSAGE()),
			(SELECT TOP 1 CONCAT('USUARIO "', login_name, '" DEL SERVIDOR ', host_name, ' ',
			(SELECT client_net_address FROM sys. dm_exec_connections WHERE session_id = @@SPID) )
			FROM sys.dm_exec_sessions WHERE host_name is not null AND session_id=@@SPID ) )
	END CATCH
END
GO

CREATE OR ALTER TRIGGER TG_UPDATE_EMPLEADOS
ON dbo.EMPLEADOS
AFTER UPDATE
AS
BEGIN
	BEGIN TRY
		INSERT INTO HIST_LOG_ACTIVIDADES(TABLA,ACCION,USUARIO_HOST)
		VALUES('EMPLEADOS', 'DATO ACTUALIZADO',
		(SELECT TOP 1 CONCAT('USUARIO "', login_name, '" DEL SERVIDOR ', host_name, ' ',
		(SELECT client_net_address FROM sys. dm_exec_connections WHERE session_id = @@SPID) )
		FROM sys.dm_exec_sessions WHERE host_name is not null AND session_id=@@SPID ) )
		PRINT 'Empleado actualizado correctamente'
	END TRY
	BEGIN CATCH
		INSERT INTO HIST_LOG_ACTIVIDADES(TABLA,ACCION,USUARIO_HOST)
			VALUES('EMPLEADOS', CONCAT('UPDATE ERROR DURANTE LA TRANSACCIÓN', ERROR_MESSAGE()),
			(SELECT TOP 1 CONCAT('USUARIO "', login_name, '" DEL SERVIDOR ', host_name, ' ',
			(SELECT client_net_address FROM sys. dm_exec_connections WHERE session_id = @@SPID) )
			FROM sys.dm_exec_sessions WHERE host_name is not null AND session_id=@@SPID ) )
	END CATCH
END
GO

CREATE OR ALTER TRIGGER TG_DELETE_EMPLEADOS
ON dbo.EMPLEADOS
FOR DELETE
AS 
BEGIN
	PRINT 'No es posible eliminar empleados'
	ROLLBACK;
	INSERT INTO HIST_LOG_ACTIVIDADES(TABLA,ACCION,USUARIO_HOST)
	VALUES('EMPLEADOS', 'Se intento eliminar registro',
	(SELECT TOP 1 CONCAT('USUARIO "', login_name, '" DEL SERVIDOR ', host_name, ' ',
	(SELECT client_net_address FROM sys. dm_exec_connections WHERE session_id = @@SPID) )
	FROM sys.dm_exec_sessions WHERE host_name is not null AND session_id=@@SPID ) )
END
GO

-----------------------------------------FUNCIONES
CREATE OR ALTER TRIGGER TG_INSERT_FUNCIONES
ON dbo.FUNCIONES
AFTER INSERT
AS
BEGIN
	BEGIN TRY
		INSERT INTO HIST_LOG_ACTIVIDADES(TABLA,ACCION,USUARIO_HOST)
		VALUES('FUNCIONES', 'SE INSERTO UN NUEVO REGISTRO',
		(SELECT TOP 1 CONCAT('USUARIO "', login_name, '" DEL SERVIDOR ', host_name, ' ',
		(SELECT client_net_address FROM sys. dm_exec_connections WHERE session_id = @@SPID) )
		FROM sys.dm_exec_sessions WHERE host_name is not null AND session_id=@@SPID ) )

		PRINT 'Función registrada correctamente'
	END TRY
	BEGIN CATCH
	INSERT INTO HIST_LOG_ACTIVIDADES(TABLA,ACCION,USUARIO_HOST)
			VALUES('FUNCIONES', CONCAT('INSERT ERROR DURANTE LA TRANSACCIÓN', ERROR_MESSAGE()),
			(SELECT TOP 1 CONCAT('USUARIO "', login_name, '" DEL SERVIDOR ', host_name, ' ',
			(SELECT client_net_address FROM sys. dm_exec_connections WHERE session_id = @@SPID) )
			FROM sys.dm_exec_sessions WHERE host_name is not null AND session_id=@@SPID ) )
	END CATCH
END
GO

CREATE OR ALTER TRIGGER TG_UPDATE_FUNCIONES
ON dbo.FUNCIONES
AFTER UPDATE
AS
BEGIN
	BEGIN TRY
		INSERT INTO HIST_LOG_ACTIVIDADES(TABLA,ACCION,USUARIO_HOST)
		VALUES('FUNCIONES', 'DATO ACTUALIZADO',
		(SELECT TOP 1 CONCAT('USUARIO "', login_name, '" DEL SERVIDOR ', host_name, ' ',
		(SELECT client_net_address FROM sys. dm_exec_connections WHERE session_id = @@SPID) )
		FROM sys.dm_exec_sessions WHERE host_name is not null AND session_id=@@SPID ) )
		PRINT 'Función actualizado correctamente'
	END TRY
	BEGIN CATCH
		INSERT INTO HIST_LOG_ACTIVIDADES(TABLA,ACCION,USUARIO_HOST)
			VALUES('FUNCIONES', CONCAT('UPDATE ERROR DURANTE LA TRANSACCIÓN', ERROR_MESSAGE()),
			(SELECT TOP 1 CONCAT('USUARIO "', login_name, '" DEL SERVIDOR ', host_name, ' ',
			(SELECT client_net_address FROM sys. dm_exec_connections WHERE session_id = @@SPID) )
			FROM sys.dm_exec_sessions WHERE host_name is not null AND session_id=@@SPID ) )
	END CATCH
END
GO

CREATE OR ALTER TRIGGER TG_DELETE_FUNCIONES
ON dbo.FUNCIONES
FOR DELETE
AS 
BEGIN
	PRINT 'No es posible eliminar Funciones'
	ROLLBACK;
	INSERT INTO HIST_LOG_ACTIVIDADES(TABLA,ACCION,USUARIO_HOST)
	VALUES('FUNCIONES', 'Se intento eliminar registro',
	(SELECT TOP 1 CONCAT('USUARIO "', login_name, '" DEL SERVIDOR ', host_name, ' ',
	(SELECT client_net_address FROM sys. dm_exec_connections WHERE session_id = @@SPID) )
	FROM sys.dm_exec_sessions WHERE host_name is not null AND session_id=@@SPID ) )
END
GO
-----------------------------------VENTAS
CREATE OR ALTER TRIGGER TG_INSERT_VENTAS
ON dbo.VENTAS
AFTER INSERT
AS
BEGIN
	BEGIN TRY
		INSERT INTO HIST_LOG_ACTIVIDADES(TABLA,ACCION,USUARIO_HOST)
		VALUES('VENTAS', 'SE INSERTO UN NUEVO REGISTRO',
		(SELECT TOP 1 CONCAT('USUARIO "', login_name, '" DEL SERVIDOR ', host_name, ' ',
		(SELECT client_net_address FROM sys. dm_exec_connections WHERE session_id = @@SPID) )
		FROM sys.dm_exec_sessions WHERE host_name is not null AND session_id=@@SPID ) )

		PRINT 'Ventas registrada correctamente'
	END TRY
	BEGIN CATCH
		INSERT INTO HIST_LOG_ACTIVIDADES(TABLA,ACCION,USUARIO_HOST)
			VALUES('VENTAS', CONCAT('INSERT ERROR DURANTE LA TRANSACCIÓN', ERROR_MESSAGE()),
			(SELECT TOP 1 CONCAT('USUARIO "', login_name, '" DEL SERVIDOR ', host_name, ' ',
			(SELECT client_net_address FROM sys. dm_exec_connections WHERE session_id = @@SPID) )
			FROM sys.dm_exec_sessions WHERE host_name is not null AND session_id=@@SPID ) )
	END CATCH
END
GO

CREATE OR ALTER TRIGGER TG_UPDATE_VENTAS
ON dbo.VENTAS
AFTER UPDATE
AS
BEGIN
	BEGIN TRY
		INSERT INTO HIST_LOG_ACTIVIDADES(TABLA,ACCION,USUARIO_HOST)
		VALUES('VENTAS', 'DATO ACTUALIZADO',
		(SELECT TOP 1 CONCAT('USUARIO "', login_name, '" DEL SERVIDOR ', host_name, ' ',
		(SELECT client_net_address FROM sys. dm_exec_connections WHERE session_id = @@SPID) )
		FROM sys.dm_exec_sessions WHERE host_name is not null AND session_id=@@SPID ) )
		PRINT 'Venta actualizado correctamente'

		UPDATE BL SET BL.ESTAUS_BOLETO=0
		FROM dbo.VENTAS VT JOIN dbo.BOLETOS BL ON  VT.ID_VENTA=BL.FK_VENTA
		JOIN dbo.PRECIOS_BOLETOS  PB ON PB.ID_PRECIO=BL.FK_PRECIO_BOLETO
		WHERE VT.ESTATUS_VENTA=0		
	END TRY
	BEGIN CATCH
		INSERT INTO HIST_LOG_ACTIVIDADES(TABLA,ACCION,USUARIO_HOST)
			VALUES('INSERT', CONCAT('UPDATE ERROR DURANTE LA TRANSACCIÓN', ERROR_MESSAGE()),
			(SELECT TOP 1 CONCAT('USUARIO "', login_name, '" DEL SERVIDOR ', host_name, ' ',
			(SELECT client_net_address FROM sys. dm_exec_connections WHERE session_id = @@SPID) )
			FROM sys.dm_exec_sessions WHERE host_name is not null AND session_id=@@SPID ) )
	END CATCH
END
GO

CREATE OR ALTER TRIGGER TG_DELETE_VENTAS
ON dbo.VENTAS
FOR DELETE
AS 
BEGIN
	PRINT 'No es posible eliminar Ventas'
	ROLLBACK;
	INSERT INTO HIST_LOG_ACTIVIDADES(TABLA,ACCION,USUARIO_HOST)
	VALUES('VENTAS', 'Se intento eliminar registro',
	(SELECT TOP 1 CONCAT('USUARIO "', login_name, '" DEL SERVIDOR ', host_name, ' ',
	(SELECT client_net_address FROM sys. dm_exec_connections WHERE session_id = @@SPID) )
	FROM sys.dm_exec_sessions WHERE host_name is not null AND session_id=@@SPID ) )
	BEGIN TRY		
		UPDATE BL SET BL.ESTAUS_BOLETO=0
		FROM dbo.VENTAS VT JOIN dbo.BOLETOS BL ON  VT.ID_VENTA=BL.FK_VENTA
		JOIN dbo.PRECIOS_BOLETOS  PB ON PB.ID_PRECIO=BL.FK_PRECIO_BOLETO
		WHERE VT.ESTATUS_VENTA=0		
	END TRY
	BEGIN CATCH
		INSERT INTO HIST_LOG_ACTIVIDADES(TABLA,ACCION,USUARIO_HOST)
			VALUES('VENTAS', CONCAT('DELETE ERROR DURANTE LA TRANSACCIÓN', ERROR_MESSAGE()),
			(SELECT TOP 1 CONCAT('USUARIO "', login_name, '" DEL SERVIDOR ', host_name, ' ',
			(SELECT client_net_address FROM sys. dm_exec_connections WHERE session_id = @@SPID) )
			FROM sys.dm_exec_sessions WHERE host_name is not null AND session_id=@@SPID ) )
	END CATCH	
END
GO

CREATE OR ALTER TRIGGER safety   
ON DATABASE   
FOR DROP_TABLE
AS
BEGIN
	PRINT 'No es posible eliminar la tabla'
	ROLLBACK;
END
