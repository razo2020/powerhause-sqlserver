#! /bin/awk/ -f
BEGIN{
	ARGC = 2 
	FS = "|"
	ARGV[1] = "Indice.L"
	print ";SET NOSPACE" > "TABLAS.QZS"
	# while ((getline < "Indice.L") > 0) _Colum[$3][$5] = $7
	_Report=""
	_TABLA=""
	_name=""
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
}

function cuerpo(){
	split(_Report,v," &")
	for (y in v) n = length(v[y]) #Pendiente se necesita el largo del ultimo valor del array
	if (n > 66) _Report = _Report" &\n"
	_Report = _Report $5 "\"|\""
}

{
	if(_TABLA == $3){
		cuerpo()
		($3 in _Lista)? _Lista[$3] = _Lista[$3]",["$5"]" : _Lista[$3] = "["$5"]"
		P++
	}else{
		gsub(/\"\|\"$/,"\nGO",_Report)
		if(_TABLA!="")
			_Lista[_TABLA] = _Lista[_TABLA] "|" _name ".PRN|" P "|" _IND
		print _Report >> "TABLAS.QZS"
		_TABLA = $3
		cabecera()
		cuerpo()
		($3 in _Lista)? _Lista[$3] = _Lista[$3]",["$5"]" : _Lista[$3] = "["$5"]"
		P=1
	}
}
END{
	gsub(/\"\|\"$/,"\nGO",_Report)
	_Lista[_TABLA] = _Lista[_TABLA] "|" _name ".PRN|" P "|" _IND
	print _Report >> "TABLAS.QZS"
	for(g in _Lista) print g "|" _Lista[g]  >> "LISTS.G"
}