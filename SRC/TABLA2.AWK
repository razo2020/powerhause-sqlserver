#! /bin/awk/ -f
BEGIN{
	ARGC = 2 
	FS = "|"
	ARGV[1] = "Indice.L"
	print ";SET NOSPACE" > "TABLAS.QZS"

	_Report=""
	_TABLA=""
	_name=""
	_Lista=""
}

function cabecera(){
	_LAR = length($3)
	_IND = ""
	if (_LAR > 6){
		_IND = substr($3,0,2)
		_name = substr($3,3,_LAR-2)
	}else{
		_name = $3
	}
	_name = "SRC/"_name
	print "SET REP LIM 9000000 DEV DISC NAME \""_name"\" &\nPAG WID 240 NOHEAD">> "TABLAS.QZS"
	print "ACC "$3>> "TABLAS.QZS"
	_Report = "REPORT "
	_Lista = ""
}

function cuerpo(){
	split(_Report,v," &")
	for (y in v) n = length(v[y]) #Pendiente se necesita el largo del ultimo valor del array
	if (n > 66) _Report = _Report" &\n"
	_Report = _Report $5 "\"|\""
	(_Lista != "")? _Lista = _Lista",["$5"]" : _Lista = "["$5"]"
}

{
	#_TABLA es igual a valor tomado del Indice.l
	if(_TABLA == $3){
		cuerpo()
		P++
	}else{
		#"|" al final remplazar por \nGO en _Report	
		gsub(/\"\|\"$/,"\nGO",_Report)	
		if(_Lista != ""){
			_Lista = _TABLA"|"_Lista "|" _name ".PRN|" P "|" _IND
			print _Lista >> "LISTS.G"
		}
		print _Report >> "TABLAS.QZS"
		_TABLA = $3
		cabecera()
		cuerpo()
		P=1
	}
}
END{
	gsub(/\"\|\"$/,"\nGO",_Report)
	_Lista = _TABLA"|"_Lista "|" _name ".PRN|" P "|" _IND
	print _Lista >> "LISTS.G"
	print _Report >> "TABLAS.QZS"
}