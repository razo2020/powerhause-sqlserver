#! /bin/awk/ -f
{
	if ( /&/ ){
		gsub(/[&\']/, " ")
		gsub(/[ \t]*$/, "")
		if(/^\"/){
			b=b$0
		}else{
			if (b=="") {
				b=$0 
			}else {
				b=b"|"$0
			}
		}
	}else{
		if(/^\"/){
			print b$0
		}else{
			print b"|"$0
		}
		b=""
	}
}