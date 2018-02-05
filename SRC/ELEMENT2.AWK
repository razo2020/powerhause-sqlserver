#! /bin/awk/ -f
BEGIN{
	# ARGC = 2
	# ARGV[1] = "TEMPE.T"
	FS = "|"
	# Label=""
	Description=""
	# Help=""

	Element=""
	ElementTipo=""
	Picture=""

	Values=""
	# Error=0
}

function buscar(campo){
	if (campo~/Label /||campo~/Description/||campo~/Help /){
		sub(/Description|Help |Label /,"",campo)
		gsub(/\"\"/," ",campo)
		gsub(/[ ]+/," ",campo)
		gsub(/[\"\'\:]/,"",campo)
		gsub(/^[ \t]+/,"",campo)
		gsub(/[ \t]*$/,"",campo)
		
		if(Description=="") {
			Description=campo
		}else{
			# ignore case
			IGNORECASE = 1
			# print Description "| y |" campo
			if(Description~/campo/) return 1
			if(campo~/Description/){
				Description=campo
			}else{			
				Description=Description" "campo
			}
		}
		return 1
	}
	if (campo~/Element /){
		split(campo,e," ")
		Element=e[2]
		ElementTipo=e[3]
		tipoDato()
		return 1
	}
	if (campo~/Picture /){
		sub(/Picture /,"",campo)
		gsub(/[\"\'%,\-\/\.\(\)]/,"",campo)
		gsub(/^[ \t]*/,"",campo)
		gsub(/[ \t]*$/,"",campo)
		Picture=length(campo)
		return 1
	}
	if (campo~/Values /){
		sub(/Values /,"",campo)
		Values=campo
		check()
		return 1
	}
	return 0
}

function tipoDato(){
	if (ElementTipo~/X/) {
		split(ElementTipo,r,"(")
		gsub(/\)/,"",r[2])
		if(r[2]<=10){
			sub(/X/,"[nchar]",ElementTipo)
		}else{
			sub(/X/,"[nvarchar]",ElementTipo)
		}
		return 1
	}
	if (ElementTipo~/Date/){
		sub(/Date/,"[datetime]",ElementTipo)
		return 1
	}
	sub(/9/,"[numeric]",ElementTipo)
	if(ElementTipo~/V/){
		sub(/V9/,"",ElementTipo)
		split(ElementTipo,r,"(")
		gsub(/\)/,"",r[2])
		gsub(/\)/,"",r[3])
		data=r[2]+r[3]
		sub(/[[:digit:]]+/,data,ElementTipo)
		sub(/\)\(/,",",ElementTipo)
		
		return 1
	}
	return 0
}

function revision(){
	if(Picture > 1){
		temp=ElementTipo
		gsub(/\[[[:alpha:]]*\]\(/,"",temp)
		gsub(/,[[:digit:]]+/,"",temp)
		gsub(/\)/,"",temp)
		if(Picture==temp){
			return 1
		}
		return 0
	}
	return -1
}

function check(){
	if(ElementTipo~/char\]/){
		if (Values~/ TO /){
			gsub(/[\"]/,"",Values)
			sub(/ TO /,"-",Values)
			Values="LIKE '["Values"]'"
		}else{
			gsub(/[\"]/,"'",Values)
			Values="IN ("Values")"
		}
	}else{
		Values=""
	}
}

function iniciar(){
	# Label=""
	Description=""
	# Help=""
	Element=""
	ElementTipo=""
	Picture=""
	Values=""
}

{
	for(i=1; i <= NF; i++){
		buscar($i)
	}
	num=revision()
	#Lista de Element por tipoDato y restriccion
	# if(NR == 1){
		# print Element"|"ElementTipo"|"Values"|"Label" "Description" "Help > "LISTE.T" 
	# }else{
		print Element"|"ElementTipo"|"Values"|"Description >> "LISTE.T"
	# }
	
	# EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de relacion' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ch17_CT1A02-UGI', @level2type=N'COLUMN',@level2name=N'CT1A02_COD-GES'
	# ALTER TABLE [dbo].[ch17_CT1A02-UGI] ADD  CONSTRAINT [DF_ch17_CT1A02-UGI_CT1A02_COD-ZON]  DEFAULT ((0)) FOR [CT1A02_COD-ZON]
	# print "EXEC sys.sp_addextendedproperty @name=N\'MS_Description\', @value=N\'"Label" "Description" "Help"\' , @level0type=N\'SCHEMA\',@level0name=N\'dbo\', @level1type=N\'TABLE\',@level1name=N\'T4B14\', @level2type=N\'COLUMN\',@level2name=N\'"Element"\'\nGO --#"num
	
	#Esto es para actualizar cambios en infraestructura:
	# if(NR == 1) print "ALTER TABLE [dbo].[T4B14] ALTER COLUMN ["Element"] "ElementTipo"; --#"num > "ALTERE.T"
	# print "ALTER TABLE [dbo].[T4B14] ALTER COLUMN ["Element"] "ElementTipo"; --#"num >> "ALTERE.T"
	
	# if (length(Values)>0){
		# print "ALTER TABLE [dbo].[T4B14] ADD  CONSTRAINT [CHK_T4B14_"Element"] CHECK (["Element"] "Values"); --#"num >> "ALTERE.T"
	# }

	if(num == 0){
		# if(Error == 0) {
			# print $0 "\n Error: "Element" "num " // Tipo: "temp " vs Picture: "Picture > "ERRORE.R"
		# }else{
			# Error++
			print $0 "\n Error: "Element" "num " // Tipo: "temp " vs Picture: "Picture >> "ERRORE.R"
		# }
	}
	iniciar()
	
}
# END {
	# for (e in ERRORES) {
		# print ERRORES[e]
	# } 
# }