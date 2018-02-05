#! /bin/awk/ -f
BEGIN{
	# ARGC = 2
	# ARGV[1] = "TEMPF.T"
	FS = "|"
	File=""
	Open=""
	Description=""
	Diseno=""
	# Error=0
}

function buscar(campo) {
	if(campo~/^File/){
		split(campo,r," ")
		File=r[2]
		return 1
	}
	if(campo~/^Open/){
		split(campo,r,"\"")
		Open=r[2]
		return 1
	}
	if(campo~/^Description/){
		sub(/Description/,"",campo)
		gsub(/\"\"/," ",campo)
		gsub(/[ ]+/," ",campo)
		gsub(/[\"\']/,"",campo)
		gsub(/[ \t]*$/,"",campo)
		# print campo
		Description=campo
		return 1
	}
	if(campo~/^Create/){
		Diseno="TABLE"
		return 1
	}
	if(campo~/^Nocreate/){
		Diseno="VIEW"
	}
	return 0
}

function iniciar(){
	File=""
	Open=""
	Description=""
	Diseno=""
	# Error=0
}

{
	for(i=1; i <= NF; i++){
		buscar($i)
	}
	
	#Lista Tabla por tipoDato y restriccion
	# if(NR == 1){
		# print File"|"Diseno"|"Open" "Description > "LISTF.T" 
	# }else{
		print File"|"Diseno"|"Open" "Description >> "LISTF.T"
	# }
	
	# EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'DATA\IN1A01T TABLA ALTERNA PARA IMPRESION DE RECIBOS2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IN1A01T' GO --#Create
	# print "EXEC sys.sp_addextendedproperty @name=N\'MS_Description\', @value=N\'"Open" "Description"\' , @level0type=N\'SCHEMA\',@level0name=N\'dbo\', @level1type=N\'"Diseno"\',@level1name=N\'"File"\'\nGO"
	
	if (!(Open~/^data/) && (Diseno=="TABLE")){
		# if(Error==0){
			print $0 "\nError Fisico: " Open " //por creacion de tabla: "Diseno > "ERRORF.R"
		# }else{
			# Error++
			# print $0 "\nError Fisico: " Open " //por creacion de tabla: "Diseno >> "ERRORF.R"
		# }
	}
	iniciar()
	
}