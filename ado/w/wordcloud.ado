*! version 1.0
*! November 5, 2017
*! Author: Mehmet F. Dicle, mfdicle@gmail.com
*! Author: Betul Dicle, bkdicle@gmail.com

program define wordcloud, rclass
	
	version 10.0
	
	syntax varlist(min=2 max=2), [min_length(integer 0) nonumbers nogrammar nowww nocommon style(integer 1) showcommand *]
	
	qui: {	
		local wordvar = word("`varlist'",1)
		local freqvar = word("`varlist'",2)

		if (substr("`:type `wordvar''" , 1, 3) != "str") {
			noi: di "{err}First variable is the word and needs to be a string variable."
			exit
		}
		if (substr("`:type `freqvar''" , 1, 3) == "str") {
			noi: di "{err}Second variable is the frequency and needs to be a numeric variable."
			exit
		}

		gen insample=1
		replace insample = 0 if strlen(word)<`min_length'

		if ("`numbers'"!="") {
			noi: di "Numbers are excluded"
			destring word, gen(word_num) force
			replace insample = 0 if word_num!=.
			drop word_num
			
			noi: di "Words that contain numbers are excluded"
			gen regex=regexm(word, "[0-9]")
			replace insample = 0 if regex==1
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
		
		if (`style'==1) {
			capture: drop x y insample
			local obs=_N			
			gen x = runiformint(1, `obs')
			gen y = runiformint(1, `obs')
			twoway (scatter x y if freq>=0 & freq<2, mlabel(word) mlabsize(minuscule) mcolor(white) mlabgap(-2))(scatter x y if freq>=2 & freq<4, mlabel(word) mlabsize(quarter_tiny) mcolor(white) mlabgap(-2))(scatter x y if freq>=4 & freq<6, mlabel(word) mlabsize(third_tiny) mcolor(white) mlabgap(-2))(scatter x y if freq>=6 & freq<8, mlabel(word) mlabsize(half_tiny) mcolor(white) mlabgap(-2))(scatter x y if freq>=8 & freq<12, mlabel(word) mlabsize(tiny) mcolor(white) mlabgap(-2))(scatter x y if freq>=12 & freq<16, mlabel(word) mlabsize(vsmall) mcolor(white) mlabgap(-2))(scatter x y if freq>=16 & freq<20, mlabel(word) mlabsize(small) mcolor(white) mlabgap(-2))(scatter x y if freq>=25 & freq<35, mlabel(word) mlabsize(medsmall) mcolor(white) mlabgap(-2))(scatter x y if freq>=35 & freq<45, mlabel(word) mlabsize(medium) mcolor(white) mlabgap(-2))(scatter x y if freq>=45 & freq<65, mlabel(word) mlabsize(medlarge) mcolor(white) mlabgap(-2))(scatter x y if freq>=65 & freq<85, mlabel(word) mlabsize(large) mcolor(white) mlabgap(-2))(scatter x y if freq>=85 & freq<90, mlabel(word) mlabsize(vlarge) mcolor(white) mlabgap(-2))(scatter x y if freq>=95 & freq<100, mlabel(word) mlabsize(huge) mcolor(white) mlabgap(-2))(scatter x y if freq>=100, mlabel(word) mlabsize(vhuge) mcolor(white) mlabgap(-2)), legend(off) xlabel(0(1)`obs', nolabels noticks nogrid) ylabel(0(1)`obs', nolabels noticks nogrid) xtitle("") ytitle("") yscale(noline) xscale(noline) graphregion(fcolor(white) lcolor(white) lpattern(blank) ifcolor(white) ilcolor(white) ilpattern(blank)) plotregion(fcolor(none) lcolor(none) lpattern(blank) ifcolor(white) ilcolor(white) ilpattern(blank)) `options'
			if ("`showcommand'"!="") {
				noi: di "Following commands are provided for users' convenience to modify the wordcloud"
				noi: di "gen x = runiformint(1, `obs')"
				noi: di "gen y = runiformint(1, `obs')"
				noi: di "twoway (scatter x y if freq>=0 & freq<2, mlabel(word) mlabsize(minuscule) mcolor(white) mlabgap(-2))(scatter x y if freq>=2 & freq<4, mlabel(word) mlabsize(quarter_tiny) mcolor(white) mlabgap(-2))(scatter x y if freq>=4 & freq<6, mlabel(word) mlabsize(third_tiny) mcolor(white) mlabgap(-2))(scatter x y if freq>=6 & freq<8, mlabel(word) mlabsize(half_tiny) mcolor(white) mlabgap(-2))(scatter x y if freq>=8 & freq<12, mlabel(word) mlabsize(tiny) mcolor(white) mlabgap(-2))(scatter x y if freq>=12 & freq<16, mlabel(word) mlabsize(vsmall) mcolor(white) mlabgap(-2))(scatter x y if freq>=16 & freq<20, mlabel(word) mlabsize(small) mcolor(white) mlabgap(-2))(scatter x y if freq>=25 & freq<35, mlabel(word) mlabsize(medsmall) mcolor(white) mlabgap(-2))(scatter x y if freq>=35 & freq<45, mlabel(word) mlabsize(medium) mcolor(white) mlabgap(-2))(scatter x y if freq>=45 & freq<65, mlabel(word) mlabsize(medlarge) mcolor(white) mlabgap(-2))(scatter x y if freq>=65 & freq<85, mlabel(word) mlabsize(large) mcolor(white) mlabgap(-2))(scatter x y if freq>=85 & freq<90, mlabel(word) mlabsize(vlarge) mcolor(white) mlabgap(-2))(scatter x y if freq>=95 & freq<100, mlabel(word) mlabsize(huge) mcolor(white) mlabgap(-2))(scatter x y if freq>=100, mlabel(word) mlabsize(vhuge) mcolor(white) mlabgap(-2)), legend(off) xlabel(0(1)`obs', nolabels noticks nogrid) ylabel(0(1)`obs', nolabels noticks nogrid) xtitle("") ytitle("") yscale(noline) xscale(noline) graphregion(fcolor(white) lcolor(white) lpattern(blank) ifcolor(white) ilcolor(white) ilpattern(blank)) plotregion(fcolor(none) lcolor(none) lpattern(blank) ifcolor(white) ilcolor(white) ilpattern(blank)) `options'"
			}
			if ("`showcommand'"=="") {
				drop x y insample
			}
		}
		if (`style'==2) {
			capture: drop x y insample
			local obs=_N			
			gen x = runiformint(1, `obs')
			gen y = runiformint(1, `obs')
			forval aa=1/120 {
				local _`aa' = ln(`aa'*2)
			}
			twoway (scatter x y if freq>=0 & freq<2, mlabel(word) mlabsize(`_2') mcolor(white) mlabgap(-2))(scatter x y if freq>=2 & freq<4, mlabel(word) mlabsize(`_4') mcolor(white) mlabgap(-2))(scatter x y if freq>=4 & freq<6, mlabel(word) mlabsize(`_6') mcolor(white) mlabgap(-2))(scatter x y if freq>=6 & freq<8, mlabel(word) mlabsize(`_8') mcolor(white) mlabgap(-2))(scatter x y if freq>=8 & freq<12, mlabel(word) mlabsize(`_12') mcolor(white) mlabgap(-2))(scatter x y if freq>=12 & freq<16, mlabel(word) mlabsize(`_16') mcolor(white) mlabgap(-2))(scatter x y if freq>=16 & freq<20, mlabel(word) mlabsize(`_20') mcolor(white) mlabgap(-2))(scatter x y if freq>=25 & freq<35, mlabel(word) mlabsize(`_35') mcolor(white) mlabgap(-2))(scatter x y if freq>=35 & freq<45, mlabel(word) mlabsize(`_45') mcolor(white) mlabgap(-2))(scatter x y if freq>=45 & freq<65, mlabel(word) mlabsize(`_65') mcolor(white) mlabgap(-2))(scatter x y if freq>=65 & freq<85, mlabel(word) mlabsize(`_85') mcolor(white) mlabgap(-2))(scatter x y if freq>=85 & freq<90, mlabel(word) mlabsize(`_90') mcolor(white) mlabgap(-2))(scatter x y if freq>=95 & freq<100, mlabel(word) mlabsize(`_100') mcolor(white) mlabgap(-2))(scatter x y if freq>=100, mlabel(word) mlabsize(`_120') mcolor(white) mlabgap(-2)), legend(off) xlabel(0(1)`obs', nolabels noticks nogrid) ylabel(0(1)`obs', nolabels noticks nogrid) xtitle("") ytitle("") yscale(noline) xscale(noline) graphregion(fcolor(white) lcolor(white) lpattern(blank) ifcolor(white) ilcolor(white) ilpattern(blank)) plotregion(fcolor(none) lcolor(none) lpattern(blank) ifcolor(white) ilcolor(white) ilpattern(blank)) `options'
			if ("`showcommand'"!="") {
				noi: di "Following commands are provided for users' convenience to modify the wordcloud"
				noi: di "gen x = runiformint(1, `obs')"
				noi: di "gen y = runiformint(1, `obs')"
				noi: di "twoway (scatter x y if freq>=0 & freq<2, mlabel(word) mlabsize(`_2') mcolor(white) mlabgap(-2))(scatter x y if freq>=2 & freq<4, mlabel(word) mlabsize(`_4') mcolor(white) mlabgap(-2))(scatter x y if freq>=4 & freq<6, mlabel(word) mlabsize(`_6') mcolor(white) mlabgap(-2))(scatter x y if freq>=6 & freq<8, mlabel(word) mlabsize(`_8') mcolor(white) mlabgap(-2))(scatter x y if freq>=8 & freq<12, mlabel(word) mlabsize(`_12') mcolor(white) mlabgap(-2))(scatter x y if freq>=12 & freq<16, mlabel(word) mlabsize(`_16') mcolor(white) mlabgap(-2))(scatter x y if freq>=16 & freq<20, mlabel(word) mlabsize(`_20') mcolor(white) mlabgap(-2))(scatter x y if freq>=25 & freq<35, mlabel(word) mlabsize(`_35') mcolor(white) mlabgap(-2))(scatter x y if freq>=35 & freq<45, mlabel(word) mlabsize(`_45') mcolor(white) mlabgap(-2))(scatter x y if freq>=45 & freq<65, mlabel(word) mlabsize(`_65') mcolor(white) mlabgap(-2))(scatter x y if freq>=65 & freq<85, mlabel(word) mlabsize(`_85') mcolor(white) mlabgap(-2))(scatter x y if freq>=85 & freq<90, mlabel(word) mlabsize(`_90') mcolor(white) mlabgap(-2))(scatter x y if freq>=95 & freq<100, mlabel(word) mlabsize(`_100') mcolor(white) mlabgap(-2))(scatter x y if freq>=100, mlabel(word) mlabsize(`_120') mcolor(white) mlabgap(-2)), legend(off) xlabel(0(1)`obs', nolabels noticks nogrid) ylabel(0(1)`obs', nolabels noticks nogrid) xtitle("") ytitle("") yscale(noline) xscale(noline) graphregion(fcolor(white) lcolor(white) lpattern(blank) ifcolor(white) ilcolor(white) ilpattern(blank)) plotregion(fcolor(none) lcolor(none) lpattern(blank) ifcolor(white) ilcolor(white) ilpattern(blank)) `options'"
			}
			if ("`showcommand'"=="") {
				drop x y insample
			}
		}
	}
end

mata:
	void get_www ()
	{	
		icerik_www = "html#script#thumbnail#com#url#jpg#jpeg#gif#png#www#nbsp#js#http#https#href#async#var#idx#src#ad#ads#br#app#doc#xls#docx#xlsx#gen#get#img#lib#mod#pkg#tag#explorer#google#chrome#apache#mozilla#file#meta#null#site#default#indexof#more…#section#index#video#videos#pagetop#pageload#pagetype#getrefdom#homepage#homepage1#homepage2#homepage3#homepage4#homepage5#javascript#scriptname#insertbefore#registryfile#scriptelement#layout#headline#icontype#function#true#false#refdom#font#root"	
		satir_www = tokens(icerik_www, "#")			
		_cols = cols(satir_www)		
		for (i=1; i<=_cols; i++) {
			if (satir_www[1,i]!="#") {
				stata("replace insample = 0 if (word==" + char(34) + satir_www[1,i] + char(34) + ")")
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
				stata("replace insample = 0 if (word==" + char(34) + satir_grammar[1,i] + char(34) + ")")
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
				stata("replace insample = 0 if (word==" + char(34) + satir_common[1,i] + char(34) + ")")
			}
		}
	}
	
end



