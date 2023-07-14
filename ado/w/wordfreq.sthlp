{smcl}
{* 05nov2017}{...}
{cmd:help wordfreq}{right: ({browse "http://www.stata-journal.com/article.html?article=dm0094":SJ18-2: dm0094})}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{cmd:wordfreq} {hline 2}}Download a webpage or a local file and prepare frequency distribution of all different words{p_end}

{title:Syntax}

{p 8 16 2}
{cmdab:wordfreq using} {it:filename} [{cmd:,} 
{opt min_length(integer)} {cmd:nonumbers} {cmd:nogrammar} {cmd:nowww} 
{cmd:nocommon} {cmd:clear} {cmd:append}]{p_end}

{pstd}
{it:filename} is the filename to process.  It can be an internet address to
download, in which case it must start with http or https.  It can also be a
local file with any extension.  The ASCII source of the file will be
processed.


{title:Description}

{pstd}
{cmd:wordfreq} downloads a webpage or a local file and prepares frequency
distribution of all different words contained in the processed file.{p_end}


{title:Options}

{phang}
{opt min_length(integer)} specifies the minimum number of characters required
in a word to keep it in the frequency distribution.  The default is
{cmd:min_length(0)} (that is, keep all words).

{phang}
{cmd:nonumbers} specifies to drop the words that contain numbers.  The default
is to keep them.

{phang}
{cmd:nogrammar} specifies to drop words that are part of common grammar (for
example, is or are).  The default is to keep them.  The full list is
available at
{browse "http://researchforprofit.com/data_public/wordfreq/wordfreq_grammar.txt"}.

{phang}
{cmd:nowww} specifies whether to drop words that are related to http or html
(for example, html, http, or chrome).  The default is to keep them.  The
full list is available at
{browse "http://researchforprofit.com/data_public/wordfreq/wordfreq_www.txt"}.

{phang}
{cmd:nocommon} specifies to drop most common and ordinary words (for example,
over, after, or about).  The default is to keep them.  The full list is
available at
{browse "http://researchforprofit.com/data_public/wordfreq/wordfreq_common.txt"}.

{phang}
{cmd:clear} clears the data in the memory.

{phang}
{cmd:append} specifies to append the new word-frequency distribution to
an existing word-frequency distribution.


{title:Examples}

{phang}{cmd:. wordfreq using http://www.cnn.com}{p_end}
{phang}{cmd:. wordfreq using https://www.cnbc.com, min_length(3) nonumbers nogrammar nowww nocommon append}{p_end}


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
