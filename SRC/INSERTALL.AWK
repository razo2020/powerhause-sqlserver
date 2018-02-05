#! /bin/awk/ -f
BEGIN{
	ARGC = 2 
	FS = "|"
	ARGV[1] = "LISTS.G"
	#Generando array 2 llaves tabla y columna => tipo de dato.
	while((getline < "Indice.L") > 0) _TIPO[$3][$5] = $7
	close("Indice.L")
	#Generar array llave tabla => cantida de filas obtenidas 
	# while((getline < "INDICE.T") > 0) _FIN[$1]=$2
	# close("INDICE.T")
}

#Genrar sentencias SQL INSERT INTO TABLA (COLUMNA1, COLUMNA2, COLUMNA3, ...) VALUES(..., ..., ...);
function SQL(_TABLA, _COLUMN, _INSERT){
	_DIR = "TEMP/"_TABLA".T"
	_ARCHIVO = "SQL/"_TABLA".SQL"
	
	R = 0 #contar lineas
	k = 0 #Lineas dentro del conjunto de sentencias
	
	#Navegamos por el archivo fisico de la tabla.
	while ((getline _DATA<_DIR) > 0) {		
		R++
		if(R==1){
			print _INSERT >_ARCHIVO
			k++
		}
		#Conjunto de insert no mayor a 5000 filas se genera nuevamente insert
		if(k == 0) print _INSERT >>_ARCHIVO
		#Obtenemos los datos de la fila
		split(_DATA,_DATO,"|")
		#Obtenemos las columnas 
		split(_COLUMN,_COL,",")
		
		#Fila de cada sentencia.
		_linea=""
		
		#navegamos por los datos
		for (i in _DATO){
			#Eliminamos corchetes.
			gsub(/\[|\]/,"",_COL[i])
			#Eliminar espacios al inicio y final; tambien comillas simples y dobles.
			gsub(/^[ ]+/,"",_DATO[i])
			gsub(/[\'\"]/,"",_DATO[i])
			gsub(/[ ]+$/,"",_DATO[i])
			
			#TEST resultado 
			# igual=!((_DATO[i]~/[[:alnum:]]/)) 
			# print _TABLA " "_COL[i] " los datos: " _DATO[i] " REV:" igual
			
			if (_DATO[i]=="" || !((_DATO[i]~/[[:alnum:]]/))){
				_DATO[i]="NULL" 
			}else{
				#Obtenemos tamaño del tipo de dato en la variable temp
				temp=_TIPO[_TABLA][_COL[i]]
				#Antes de obtener tamaño del tipo de dato:
				# - revisamos si es numerico
				(temp~/numeric/)? num = 1 : num = 0
				# - Remplazamos "[tipo](" por ""
				gsub(/\[[[:alpha:]]*\]\(/,"",temp)
				# - Remplazamos ",1742.." por ""
				gsub(/,[[:digit:]]+/,"",temp)
				# - Remplazamos ")" por ""
				gsub(/\)/,"",temp)
				
				if(temp < length(_DATO[i])){
					if(num == 1){
						gsub(/[^[:digit:]\.]/,"",_DATO[i])
						#gsub(/[\-\,]*/,"",_DATO[i])
					}else{
						gsub(/[[:punct:]]/,"",_DATO[i])
					}
				}
				# }
				_DATO[i] = "'"_DATO[i]"'"
			}
			
			(_linea=="")? _linea=_DATO[i] : _linea=_linea ", " _DATO[i]
		}
		k++
		_linea = "( "_linea" )"
		if(k < 5000 ){ 
			_linea = _linea ","
		}else{
			_linea = _linea "\n);\n"
			k = 0
		}
		print _linea >>_ARCHIVO		
	}
	
	if (R%5000 != 0){
		print ");" >>_ARCHIVO
	}
	
	if(R > 0) close(_DIR)
}

{	
#$1 - Tabla
#$2 - Columnas
#$3 - Archivo
#$4 - Cantidad de columnas
#$5 - Prefijo de tabla si exedio 6 caracter el largo del nombre.
	
	#Si se encuentra una linea en blanco avanza a la siguiente linea.
	if($0~/^$/) next
	
	#La variable que se va a repetir por al inicio de cada conjunto de filas a insertar.
	_INSERT = "INSERT INTO "$1" ("$2") VALUES("
	#Llamamos a la funcion que va generar las sentencias.
	SQL($1,$2,_INSERT)
}