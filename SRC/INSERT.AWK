#! /bin/awk/ -f
BEGIN{
	while ((getline < _TABLA) > 0) {
		if (_ULTIMO < 20 && /^$/){
			n++ 
			_ALTO = _ULTIMO + 1
		}
		_ULTIMO++
	}
	
	gsub(/SRC\/||\.PRN/,"",_TABLA)
	if(length(_TABLA) < 6 ) _TABLA = "CT"_TABLA
	
	
	while ((getline < "LISTS.G") > 0) {
		# if($0~_TABLA) print "si busco"
		split($0,f,"|")
		if(f[1]==_TABLA){
			_TABLA = "INSERT INTO "_TABLA" ("f[2]") VALUES("
			break
		}
	}
	
	_linea = ""
	h=0
	n = n - 1
	k = 0
}
{	
	if(NR <= _ALTO){
		if(NR < 2) next
		if (!(/^$/ )){
			for (i = 1; i <= NF; i++){
				gsub(/^[ ]+||[ ]+$/,"",$i)
				if(length($i) > 3){
					e++
					print "problemas: "$i >> "ERROR-INSERT.R"
				}
			}
		}
		if (e) n++
		e = 0
		next
	}
	if (/^$/ ) {print "Error en la linea: "NR >> "ERROR-INSERT.R"; next}
	
	_linea=_linea$0
	h++
	
	if (h == n){
		
		if(k == 0 || NR == (_ULTIMO+n)) print _TABLA 
		split(_linea,v,"|")
		_linea=""
		for (i in v){
			gsub(/^[ ]+||[ ]+$/,"",v[i])
			(v[i]=="")? v[i]="NULL" : v[i] = "'"v[i]"'"
			(_linea=="")? _linea=v[i] : _linea=_linea ", " v[i]
		}
		k++
		_linea = "( "_linea" )"
		if(k < 5000 && NR < _ULTIMO){ 
			_linea = _linea ","
		}else{
			_linea = _linea "\n);\n"
			k = 0
		}
		h = 0
		print _linea
		_linea = ""
	}
}