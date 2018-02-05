#! /bin/awk/ -f
BEGIN{
	# ARGC = 2 
	FS = "|"
	# ARGV[1] = "LISTS.G"
}

function FILA(_DIR, _TABLA, _CANT){
	_ARCHIVO = "TEMP/"_TABLA".T"
	# _CABEZA = "-- "_TABLA
	# print _CABEZA > _ARCHIVO
	_linea = ""
	n = 0 #contar saltos
	h = 0 #sumar cantidad de columnas por fila
	p = 0
	R = 0
	
	while ((getline _DATA<_DIR) > 0) {
		#Error de fila vacia si no es el ultimo.
		if (_DATA~/^$/ ) {print _TABLA " Error en la linea: "R >> "ERROR-INSERT.R"; continue}
		R++
		#concatenamos filas segun los saltos realizados.
		_lineaD=_linea
		_linea=_linea _DATA
		#print _TABLA ": "p " y n: "n" registro H y Cant: " h " : " _CANT
		if(p==0){
			split(_linea,_Dato,"|")
			for(i in _Dato) h++

			#Comparamos si aun no llegamos a la cantidad Establecido en LISTS.G
			if(h < _CANT){h=0;continue}
			
			if(n==0){n=1;h=0;continue}
			
			if(h == _CANT){
				p=R
				n=1
				print _linea >> _ARCHIVO
				_linea=""
			}else{
				p=R-1
				_linea = _DATA
				n=2
				print _lineaD >> _ARCHIVO
			}
			
		}else{
			if(p > n){
				n++
				continue
			}
			if(p == n){
				n=1
				print _linea >> _ARCHIVO
				_linea=""
			}
			if(p < n){
				_linea = _DATA
				n=2
				print _lineaD >> _ARCHIVO
			}
		}

	}
	if(R>0){
		if(p>0){ h=R/p}
		print _TABLA ": "R " tamaño: "h
		print _TABLA "|" h >> "INDICE.T"
		if(n==2) print _linea >> _ARCHIVO
		close(_DIR)
	}
}

{	
	if($0~/^$/) next

	FILA(_DIR,$1,$4)
}