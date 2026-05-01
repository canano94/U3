import pandas as pd
from sqlalchemy import create_engine, text

#Confivuramos la conexion
ruta = "C:/Users/aleja/OneDrive - uniminuto.edu/Documentos/Universidad/2026 - 1/Administracion Bases de Datos/Entregables/U3/"
usuario = 'root'
contrasena = ''  
host = '127.0.0.1'
nombre_bd = 'autofuturo'

#Almacenamos la llave secretya
LLAVE_AES = '05d549f2c9d734da0bdea71d71466d1dbe00e5d051875a64af7e633422a297a1'

#CReamos el motor de conexion 

engine = create_engine(f'mysql+pymysql://{usuario}:{contrasena}@{host}/{nombre_bd}')

#Cargar los archivos para que Pandas los lea
sedes = pd.read_csv(ruta + 'sedes_limpio.csv')
proveedores = pd.read_csv(ruta + 'proveedores_limpio.csv')
clientes = pd.read_csv(ruta + 'clientes_limpio.csv')
empleados = pd.read_csv(ruta + 'empleados_limpio.csv')
vehiculos = pd.read_csv(ruta + 'vehiculos_limpio.csv')
ventas = pd.read_csv(ruta + 'ventas_limpio.csv')
revisiones = pd.read_csv(ruta + 'revisiones_limpio.csv')

print("COnectado y archivos encontrados")

#Aseguramos que los ID son de tipo Entero
ventas['id_venta'] = ventas['id_venta'].astype(int)
ventas['id_cliente'] = ventas['id_cliente'].astype(int)
ventas['id_vehiculo'] = ventas['id_vehiculo'].astype(int)
ventas['id_empleado'] = ventas['id_empleado'].astype(int)

#Cargar Tablas a SQL (Tablas que no requieren encriptacion)
sedes.to_sql('sedes', con=engine, if_exists='append', index=False)
proveedores.to_sql('proveedores', con=engine, if_exists='append', index=False)
empleados.to_sql('empleados', con=engine, if_exists='append', index=False)

print("Sedes, Proveedores y EMpleados cargados")

#Cargar Tablas a SQL (Tablas con requirimiento de encriptacion)
with engine.connect() as conexion:
    for index, fila in clientes.iterrows(): #metodo para recorrer fila por fila
        query = text("""
            INSERT INTO clientes (id_cliente, nombre, correo, telefono) 
            VALUES (:id, :nom, AES_ENCRYPT(:cor, :llave), AES_ENCRYPT(:tel, :llave))  
        """)# Utoilizamos marcadores para consultas parametrizadas
        conexion.execute(query, {
            "id": fila['id_cliente'], "nom": fila['nombre'], 
            "cor": fila['correo'], "tel": str(fila['telefono']), 
            "llave": LLAVE_AES
        })

    # Cargar Vehículos 
    for index, fila in vehiculos.iterrows():
        query = text("""
            INSERT INTO vehiculos (id_vehiculo, marca, modelo, ano, precio, estado, id_proveedor, placa) 
            VALUES (:id, :marca, :mod, :ano, :precio, :est, :prov, AES_ENCRYPT(:placa, :llave))
        """)
        conexion.execute(query, {
            "id": fila['id_vehiculo'], "marca": fila['marca'], "mod": fila['modelo'],
            "ano": fila['ano'], "precio": fila['precio'], "est": fila['estado'],
            "prov": fila['id_proveedor'], "placa": fila['placa'],
            "llave": LLAVE_AES
        })
        conexion.commit() #Guardamos en la tablas de SQL

print("SedClientes y Vehiculos cargados")

#Cargar Tablas con Transaccionales
ventas.to_sql('ventas', con=engine, if_exists='append', index=False)
revisiones.to_sql('revisiones', con=engine, if_exists='append', index=False)

print("Ventas y Revisiones cargados")