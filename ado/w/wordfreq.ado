*! version 1.0
*! November 5, 2017
*! Author: Mehmet F. Dicle, mfdicle@gmail.com
*! Author: Betul Dicle, bkdicle@gmail.com

program define wordfreq, rclass
	
	version 10.0
	
	syntax using/, [min_length(integer 0) nonumbers nogrammar nowww nocommon clear append]
	* wordfreq http://www.cnn.com
	* wordfreq http://www.cnn.com, min_length(3)
	* wordfreq http://www.cnn.com, min_length(3) nonumbers nogrammar nowww nocommon
	
	qui: {
		d, s
		if (r(changed) == 1) & ("`clear'"=="") & ("`append'"=="") {
			noi: di "{err}no, data in memory would be lost"
			exit 4
		}
		if (r(changed) == 0) | ("`clear'"!="") | ("`append'"!="") {
			if ("`append'"!="") {
				save __temp__0000__1111__.dta, replace
			}
			clear 		
			local adres=lower("`using'")
			mata: get_words("`adres'")

			duplicates tag word , generate(freq)
			duplicates drop
			compress

			replace freq=freq+1
			gsort -freq

			drop if strlen(word)<`min_length'

			if ("`numbers'"!="") {
				noi: di "Numbers are excluded"
				destring word, gen(word_num) force
				drop if word_num!=.
				drop word_num
			
				noi: di "Words that contain numbers are excluded"
				gen regex=regexm(word, "[0-9]")
				drop if regex==1
				drop regex
			}		

			if ("`grammar'"!="") {
				noi: di "English grammar related words (ex. is, are, etc.) are excluded."
				mata: get_grammar()
			}		

			if ("`www'"!="") {
				noi: di "Internet related words (ex. html, http, chrome, etc.) are excluded."
				mata: get_www()
			}

			if ("`common'"!="") {
				noi: di "Most common words (ex. over, after, about, etc.) are excluded."
				mata: get_common()
			}
		
			compress
			if ("`append'"!="") {
				append using __temp__0000__1111__.dta
				collapse (sum) freq, by(word)
				erase __temp__0000__1111__.dta
			}
		}
	}
	
end

mata:
	void get_words (string scalar adres)
	{	
		icerik = file_get_contents(adres)		
		kalan = strlower (icerik)
		kalan = clean_up(kalan)
		kalan = clean_non_chars(kalan)
		move_to_stata(kalan)
	}

	void get_www ()
	{	
		icerik_www = "html#script#thumbnail#com#url#jpg#jpeg#gif#png#www#nbsp#js#http#https#href#async#var#idx#src#ad#ads#br#app#doc#xls#docx#xlsx#gen#get#img#lib#mod#pkg#tag#explorer#google#chrome#apache#mozilla#file#meta#null#site#default#indexof#more…#section#index#video#videos#pagetop#pageload#pagetype#getrefdom#homepage#homepage1#homepage2#homepage3#homepage4#homepage5#javascript#scriptname#insertbefore#registryfile#scriptelement#layout#headline#icontype#function#true#false#refdom#font#root"	
		satir_www = tokens(icerik_www, "#")			
		_cols = cols(satir_www)		
		for (i=1; i<=_cols; i++) {
			if (satir_www[1,i]!="#") {
				stata("drop if (word==" + char(34) + satir_www[1,i] + char(34) + ")")
			}
		}
	}

	void get_grammar ()
	{	
		icerik_grammar = "i#me#mine#you#your#yours#your's#he#him#his#she#her#hers#it#its#it's#we#us#our#our's#they#their#their's#them#these#and#if#to#is#isn't#are#aren't#was#wasn't#were#weren't#has#hasn't#have#haven't#had#hadn't#have#haven't#been#would#wouldn't#should#shouldn't#shall#can#cannot#can't#could#couldn't#who#whom#how#what#where#which#when#why#with#while#that#this#there#the#of#in#into#on#onto#at#near#next#for#a#an#out#from#as#not#by#be#or#but#by#so"
		satir_grammar = tokens(icerik_grammar, "#")			
		_cols = cols(satir_grammar)		
		for (i=1; i<=_cols; i++) {
			if (satir_grammar[1,i]!="#") {
				stata("drop if (word==" + char(34) + satir_grammar[1,i] + char(34) + ")")
			}
		}
	}

	void get_common ()
	{	
		icerik_common = "the#be#to#of#and#a#in#that#have#i#it#for#not#on#with#he#as#you#do#at#this#but#his#by#from#they#we#say#her#she#or#an#will#my#one#all#would#there#their#what#so#up#out#if#about#who#get#which#go#me#when#make#can#like#time#no#just#him#know#take#people#into#year#your#good#some#could#them#see#other#than#then#now#look#only#come#its#over#think#also#back#after#use#two#how#our#work#first#well#way#even#new#want#because#any#these#give#day#most#us#time#person#year#way#day#thing#man#world#life#hand#part#child#eye#woman#place#work#week#case#point#government#company#number#group#problem#fact#be#have#do#say#get#make#go#know#take#see#come#think#look#want#give#use#find#tell#ask#work#seem#feel#try#leave#call#good#new#first#last#long#great#little#own#other#old#right#big#high#different#small#large#next#early#young#important#few#public#bad#same#able#to#of#in#for#on#with#at#by#from#up#about#into#over#after#beneath#under#above#the#and#a#that#I#it#not#he#as#you#this#but#his#they#her#she#or#an#will#my#one#all#would#there#their#title#name#desc#window#field#path#width#height#data#clear#clean#meta#metasize#news#type#link#test#more#size#image#style#date#quote#list#lang#wrapper#page#search#icon#change#auto#start#end#view#timeout#config#whole#help#keyword#topic#comment#align#quotes#info#information#bottom#top#very#much#many#header#footer#content"	
		satir_common = tokens(icerik_common, "#")			
		_cols = cols(satir_common)		
		for (i=1; i<=_cols; i++) {
			if (satir_common[1,i]!="#") {
				stata("drop if (word==" + char(34) + satir_common[1,i] + char(34) + ")")
			}
		}
	}

	// get contents of a file as a string
	string file_get_contents (string scalar raw)
	{
		fh = fopen(raw, "r")
		raw=""
		while ((line=fget(fh))!=J(0,0,"")) {
			raw=raw+line
		}
		fclose(fh)
		return (raw)
	}

	// clean inside the tags. i.e. <td height="3"> to <td>
	string clean_tags (string scalar raw, string scalar tag)
	{
		while (strpos(raw, "<" + tag + " ")) {
			bas_pos = strpos(raw, "<" + tag + " ")
			bas_txt = substr (raw, 1, bas_pos - 1 + strlen("<" + tag))
			
			son_txt = substr (raw, bas_pos + strlen("<" + tag), .)
			son_pos = strpos(son_txt, ">")
			son_txt = substr (son_txt, son_pos, .)
			
			raw = bas_txt + son_txt
		}
		return (raw)
	}

	// replace all non-characters with space
	string clean_non_chars (string scalar raw)
	{
		for (i=0; i<48; i++) {
			raw = subinstr(raw, char(i), " ")
		}
		for (i=58; i<65; i++) {
			raw = subinstr(raw, char(i), " ")
		}
		for (i=91; i<97; i++) {
			raw = subinstr(raw, char(i), " ")
		}
		for (i=123; i<128; i++) {
			raw = subinstr(raw, char(i), " ")
		}
		for (i=169; i<181; i++) {
			raw = subinstr(raw, char(i), " ")
		}
		for (i=184; i<189; i++) {
			raw = subinstr(raw, char(i), " ")
		}
		for (i=191; i<198; i++) {
			raw = subinstr(raw, char(i), " ")
		}
		for (i=200; i<210; i++) {
			raw = subinstr(raw, char(i), " ")
		}
		for (i=213; i<214; i++) {
			raw = subinstr(raw, char(i), " ")
		}
		for (i=217; i<222; i++) {
			raw = subinstr(raw, char(i), " ")
		}
		for (i=223; i<224; i++) {
			raw = subinstr(raw, char(i), " ")
		}
		for (i=231; i<232; i++) {
			raw = subinstr(raw, char(i), " ")
		}
		for (i=238; i<251; i++) {
			raw = subinstr(raw, char(i), " ")
		}
		for (i=254; i<255; i++) {
			raw = subinstr(raw, char(i), " ")
		}
		return (raw)
	}

	string clean_up (string scalar raw)
	{
		tags=("a","abbr","acronym","address","applet","area","article","aside","audio","b","base","basefont","bdi","bdo","big","blockquote","body","br","button","canvas","caption","center","cite","code","col","colgroup","datalist","dd","del","details","dfn","dialog","dir","div","dl","dt","em","embed","fieldset","figcaption","figure","font","footer","form","frame","frameset","h1","h2","h3","h4","h5","h6","head","header","hr","html","i","iframe","img","input","ins","kbd","keygen","label","legend","li","link","main","map","mark","menu","menuitem","meta","meter","nav","noframes","noscript","object","ol","optgroup","option","output","p","param","picture","pre","progress","q","rp","rt","ruby","s","samp","script","section","select","small","source","span","strike","strong","style","sub","summary","sup","table","tbody","td","textarea","tfoot","th","thead","time","title","tr","track","tt","u","ul","var","video","wbr")
		for (i=1; i<=122; i++) {
			tag = tags[1,i]
			raw = clean_tags (raw, tag)		
			raw = subinstr(raw, "<" + tag + ">", "  ")
			raw = subinstr(raw, "</" + tag + ">", "  ")
		}
		return (raw)
	}


	void move_to_stata (string scalar raw)
	{
		satir = tokens(raw, " ")			
		sutun=satir'
		st_addvar("str244", "word")
		st_addobs(rows(sutun))
		st_sstore(.,"word",sutun)
	}
	
end



