{smcl}
{* 05nov2017}{...}
{cmd:help wordcloud}{right: ({browse "http://www.stata-journal.com/article.html?article=dm0094":SJ18-2: dm0094})}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{cmd:wordcloud} {hline 2}}Draw a word cloud graph based on unique words and their frequencies{p_end}


{title:Syntax}

{p 8 17 2}
{cmdab:wordcloud} {it:stringvar} {it:numericvar}
[{cmd:,} {opt min_length(integer)}
{cmd:nonumbers}
{cmd:nogrammar}
{cmd:nowww}
{cmd:nocommon}
{cmd:style(1}|{cmd:2)}
{cmd:showcommand}
{it:twoway_options}]

{pstd}
{it:stringvar} is the variable name for the string variable that is to be used
for the unique words.  {it:numericvar} is the variable name for the numeric
variable that is to be used for the frequency of the unique words.


{title:Description}

{pstd}
{cmd:wordcloud} draws a word cloud graph based on unique words and their
frequency distributions.{p_end}


{title:Options}

{phang}
{opt min_length(integer)} specifies the minimum number of characters required
in a word to keep it in the frequency distribution.  The default is
{cmd:min_length(0)} (that is, keep all words).

{phang}
{cmd:nonumbers} specifies to drop the words that contain numbers.  The default
is to keep them.

{phang}
{cmd:nogrammar} specifies to drop words that are part of
common grammar (for example, is and are).  The default is to keep them.
The full list is available at
{browse "http://researchforprofit.com/data_public/wordfreq/wordfreq_grammar.txt"}.

{phang}
{cmd:nowww} specifies to drop words that are related to http or html (for
example, html, http, or chrome).  The default is to keep them.  The full list
is available at
{browse "http://researchforprofit.com/data_public/wordfreq/wordfreq_www.txt"}.

{phang}
{cmd:nocommon} specifies to drop most common and ordinary words (for
example, over, after, or about).  The default is to keep them.  The full
list is available at
{browse "http://researchforprofit.com/data_public/wordfreq/wordfreq_common.txt"}.

{phang}
{cmd:style(1}|{cmd:2)} is the specific style of the graph to be drawn.  Users
can change {cmd:mlabsize()} in each graph to determine the readability of the
graphs.

{phang}
{cmd:showcommand} lists the command that is used to draw the graph produced by
{cmd:wordcloud}.

{phang}
{it:twoway_options} are any of the options documented in
{it:{help twoway_options}}.  These additional options are simply added to the
end of the command.


{title:Examples}

{phang}{cmd:. wordfreq using https://www.cnbc.com}{p_end}
{phang}{cmd:. wordcloud word freq, min_length(5) nonumbers nogrammar nowww nocommon style(1) showcommand}{p_end}
{phang}{cmd:. wordcloud word freq, min_length(5) nonumbers nogrammar nowww nocommon style(1) showcommand title("This is an example")}{p_end}

{title:Authors}

{pstd}
Mehmet F. Dicle{break}
Loyola University New Orleans{break}
New Orleans, LA{break}
mfdicle@gmail.com{p_end}

{pstd}
Betul Dicle{break}
New Orleans, LA{break}
bkdicle@gmail.com{p_end}


{title:Also see}

{p 4 14 2}
Article:  {it:Stata Journal}, volume 18, number 2: {browse "http://www.stata-journal.com/article.html?article=dm0094":dm0094}{p_end}
