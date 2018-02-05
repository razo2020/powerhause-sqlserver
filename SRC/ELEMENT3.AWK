#! /bin/awk/ -f
BEGIN{
	# ARGC = 2 
	# ARGV[1] = "LISTE.T"
	# ARGV[2] = "LISTF.T"
	# ARGV[2] = "TEMPR.T"
	Redefined="" #End
	Constraint=""
	Ban=0
	num=0
	contred=0
	com=0
	w=0
	
	while ((getline < "LISTE.T") > 0) {
		split($0,f,"|")
		TipoDato[f[1]] = f[2]
		Check[f[1]] = f[3]
		DescE[f[1]] = f[4]
	}
	
	while ((getline < "LISTF.T") > 0) {
		split($0,f,"|")
		Tablas[f[1]] = f[2]
		DescF[f[1]] = f[3]
	}
	
}

function const(){
	# print "================================"
	# print "numeros de const: "contred
	# print "Contiene: "
	# for (f in Ccuerpo) print Ccuerpo[f]
	# print "================================"
	r=0
	es="const"
	for (key in Ccuerpo){
		if(Ccuerpo[key]~/CONSTRAINT/ || Ccuerpo[key]~/CREATE/) {
			r++
			Constraint=""
			tempk=key
			Constraint=Ccuerpo[key] 
			if (Ccuerpo[key]~/CREATE/) es="create"
			continue
		}
		if(Ccuerpo[key]~/End/){
			gsub(/,$/,"",Constraint)
			Constraint=Constraint"\n)"
			delete Ccuerpo[tempk]
			delete Ccuerpo[key]
			if (r==1) {
				for(l=tempk+1;l < key; l++){
					delete Ccuerpo[l]
				}
			}
			break
		}
		Constraint=Constraint Ccuerpo[key] ","
	}
	
	if (es=="const" && Constraint~/./) {
		constr[w++] = Constraint" ON [PRIMARY]"
	} else {
		create[w++] = Constraint
	}
	Constraint=""
	return 1
}

function imprimir(){
	for( i= 1; i <= contred; i++) const()
	for(c in constr){
		com--
		(com > 0) ? coma="," : coma=""
		print constr[c]coma
	}
	# if (FNR > 1) 
	print ") ON [PRIMARY]" 
	for(c in create) print create[c]
	# if (FNR > 1) 
	for(c in Lista) print Lista[c]
	print "END\nGO\n"
	delete constr
	delete create
	delete Lista
	contred=0
	num = 0
	com=0
	w=0
	p=0
}

function generar(campo){
	if(campo~/Record/){
		if(Norecord=="SI") imprimir()
		split(campo,Record," ")
		if(Tablas[Record[2]]~/TABLE/){
			print "SET ANSI_NULLS ON \n\
GO\n\
SET QUOTED_IDENTIFIER ON\n\
GO\n\
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].["Record[2]"]') AND type in (N'U'))\n\
BEGIN\n\
CREATE "Tablas[Record[2]]" [dbo].["Record[2]"]("
			Lista[p++]="EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'"DescF[Record[2]]"' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'"Tablas[Record[2]]"',@level1name=N'"Record[2]"'"
			Norecord="SI"
		}else{
			Norecord="NO"
		}
		return 1
	}

	if(Norecord=="NO") next

	if(campo~/End/){
		Ban--
		Ccuerpo[num++]="End"
	}

	if(campo~/Item/){
		split(campo,Item," ")
		if((getline Redefined) > 0){
			if(Redefined~/Redefined/){
				Ban++
				contred++
				# print "==========================="
				# print "Numero de Ban: "Ban
				# print "Antes de clave: "campo
				_clave=clave(campo)
				# print "Clave: "_clave
				# print "==========================="
				if(_clave~/PRIMARY/){
					Ccuerpo[num++]="CONSTRAINT [PK_"Record[2]"_"Item[2]"]"_clave" CLUSTERED ("
					com++
				}
				if(_clave~/UNIQUE/){
					Ccuerpo[num++]="CONSTRAINT [UQ_"Record[2]"_"Item[2]"]"_clave" NONCLUSTERED ("
					com++
				}
				if(_clave~/INDEX/){
					Ccuerpo[num++]="CREATE NONCLUSTERED"_clave" [IX_"Record[2]"_"Item[2]"] on ["Record[2]"] ("
				}
				# print "==========================="
				# print "Numero de Constraint: "Ban
				# for (d in Ccuerpo) print Ccuerpo[d]
				# print "============================"
				next
			}
		}else{
			Redefined = ""
		}
		if (Redefined~/Item/|| com >0){
			coma=","
		}else {
			coma=""
		}
		(Check[Item[2]]~/./)? ch=" CHECK (["Item[2]"] "Check[Item[2]]")" : ch=""
		if(Ban > 0){
			print "\t["Item[2]"] "TipoDato[Item[2]] ch","
			Ccuerpo[num++]="\n\t["Item[2]"]"
		}else{
			_clave=clave(campo)
			if(_clave~/INDEX/){
				print "\t["Item[2]"] "TipoDato[Item[2]] ch coma
				create[w++] = "CREATE"_clave" [IX_"Record[2]"_"Item[2]"] on ["Record[2]"] (["Item[2]"])"
			}else{
				print "\t["Item[2]"] "TipoDato[Item[2]] _clave ch coma
			}
		}
		Lista[p++]="EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'"DescE[Item[2]]"' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'"Tablas[Record[2]]"',@level1name=N'"Record[2]"', @level2type=N'COLUMN',@level2name=N'"Item[2]"'"
		Lista2[y++]=BASE"|"DESCB"|"Record[2]"|"DescF[Record[2]]"|"Item[2]"|"DescE[Item[2]]"|"TipoDato[Item[2]]

		generar(Redefined)
		return 1
	}
	return 0
}

function clave(Element){
	if(Element~/Key/){
		if(Element~/Repeating/){
			return " INDEX"
		}
		if(Element~/Primary/){
			if(Ban>1) return " UNIQUE"
			return " PRIMARY KEY"
		}
		if(Element~/Unique/){
			return " UNIQUE"
		}
	}
	if(Ban>0) return " INDEX"
	return ""
}

{
	generar($0)
}
END{
	if(Norecord=="SI") imprimir()
	# asort(Lista2)
	for(L in Lista2){
		# if(L==1){
			# print Lista2[L] > "Indice.L"
		# }else{
			print Lista2[L] >> "INDICE.L"
		# }
	}
}