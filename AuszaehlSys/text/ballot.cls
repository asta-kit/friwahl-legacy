\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{ballot}[2004/01/26 Ballot class, Kristof]

\LoadClass{article}
%\RequirePackage[paper=a3,landscape,pagesize]{typearea} % StuPa-Zettel
\RequirePackage[paper=a4,pagesize]{typearea} % Fachschafts- und sonstige Zettel
\RequirePackage[left=1cm,top=1cm,right=1cm,bottom=1cm]{geometry}
%\RequirePackage{lscape}
\RequirePackage{keyval}
\RequirePackage{store}

\parindent=0pt
\pagestyle{empty}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Userspace configuration

\newdimen\ballotmaxcolumn
\newdimen\ballotmincolumn
\newdimen\ballotmincolheight
\newif\ifballotrepeat
\newdimen\ballotcolsep
\newdimen\ballotcolrule
\newdimen\ballotborderrule
\newdimen\ballotbordersep
\newdimen\ballothsep
\newdimen\ballotvsep

% default values

\ballotmaxcolumn=10cm
\ballotmincolumn=7cm
\ballotmincolheight=7cm
\ballotcolsep=12pt
\ballotcolrule=1pt
\ballotbordersep=12pt
\ballotborderrule=1pt
\ballothsep=6pt
\ballotvsep=6pt

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% configurable text

\newstore{PartyName}
\newstore{CandidateName}
\newstore{PartyText}
\newstore{CandidateText}
\newstore{CumulateText}
\newstore{CrossListText}
\newstore{BottomText}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% internal data

\newwrite\ballot@write@party
\newwrite\ballot@write@cand
\newcount\ballot@partycnt
\newdimen\ballot@colwidth
\newdimen\ballot@colheight
\newdimen\ballot@tmpdim
\newif\ifballot@CrossList
\newif\ifballot@first
\newbox\ballot@tmpbox

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% keys for ballot environment

\define@key{ballot}{Election}{\gdef\ballot@Election{#1}}
\define@key{ballot}{CandidateVotes}{\gdef\ballot@CandidateVotes{#1}}
\define@key{ballot}{MaxCumulate}{\gdef\ballot@MaxCumulate{#1}}
\define@key{ballot}{CrossList}[]{\global\ballot@CrossListtrue}
\define@key{ballot}{NoCrossList}[]{\global\ballot@CrossListfalse}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% data collection inside ballot environment

\newenvironment{party}[3]{
  \global\advance\ballot@partycnt by 1
  \piwrite\ballot@write@party{\string\ballot@party{#1}{#2}}
  \piwrite\ballot@write@cand{\string\begin{ballot@party@env}{#1}{#2}}
}{
  \piwrite\ballot@write@cand{\string\end{ballot@party@env}%
                             \string\ignorespaces}
}

\newcommand{\candidate}[3]{
  \piwrite\ballot@write@cand{\string\ballot@cand{#1}{#2}}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% workhorse: election environment

\newenvironment{election}[1]{%
%
  \gdef\ballot@Election{}%
  \gdef\ballot@CandidateVotes{1}%
  \gdef\ballot@MaxCumulate{1}%
  \global\ballot@CrossListfalse%
  \setkeys{ballot}{#1}%
%
  \immediate\openout\ballot@write@party\jobname.bap%
  \immediate\openout\ballot@write@cand\jobname.bac%
  \ballot@partycnt=0%
%
  \setbox\ballot@tmpbox=\vbox\bgroup
}{
  \egroup%
  \immediate\closeout\ballot@write@party%
  \immediate\closeout\ballot@write@cand%
%
  \setbox\ballot@tmpbox=\hbox{%
%
    \fboxsep=\ballotbordersep%
    \fboxrule=\ballotborderrule%
    \advance\hsize by-2\ballotbordersep%
    \advance\hsize by-2\ballotborderrule%
%    
    \ballot@colheight=0cm%
    \ballot@colwidth=\hsize%
    \divide\ballot@colwidth by \ballot@partycnt%
    \advance\ballot@colwidth by -\ballotcolsep%
    \ifdim\ballot@colwidth>\ballotmaxcolumn%
      \ballot@colwidth=\ballotmaxcolumn%
    \fi%

    % non-stupa-ballots should have at least 7 cm/ballotmincolumn 
    % column width, otherwise they cannot be printed well
    % 
    % same with ballotmincolheight

    \def\stupawahl{Studierendenparlament}
    \ifx\ballot@Election\stupawahl
    \else
      \ifdim\ballot@colwidth<\ballotmincolumn%
        \ballot@colwidth=\ballotmincolumn%
      \fi%
      \ifdim\ballot@colheight<\ballotmincolheight%
        \ballot@colheight=\ballotmincolheight%
      \fi%
    \fi

    \hsize=\ballot@colwidth%
    \advance\hsize by \ballotcolsep%
    \multiply\hsize by \ballot@partycnt%
%    
    \fbox{%
      \begin{minipage}{0cm}
      \vrule width 0pt height \ballot@colheight\
      \end{minipage}
      \begin{minipage}{\hsize}
      \parbox{\hsize}{
        \sloppy
	\makeatletter
	{\centering
         \huge\sffamily\bfseries\ballot@Election
	 \bigskip
	
	}
	\ifnum\ballot@partycnt>1
	  \sffamily
	  \large\textbf{\thePartyName}
	  \quad\hfil\penalty0\hfilneg
	  \normalsize\thePartyText
	  \medskip
	
	  \ballot@firsttrue
	  \input\jobname.bap
	  \bigskip
	\fi
	
	\ifnum\ballot@CandidateVotes>0
	  \sffamily
	  \large\textbf{\theCandidateName}
	  \quad\hfil\penalty0\hfilneg
	  \normalsize%
	  \useexpr{\theCandidateText}{##1}{\ballot@CandidateVotes}\ 
	  \ifnum\ballot@MaxCumulate>1
	    \useexpr{\theCumulateText}{##1}{\ballot@MaxCumulate}\ 
	  \fi
	  \ifballot@CrossList
	    \theCrossListText\ 
	  \fi
	  \medskip

	  \ballot@firsttrue
	  \input\jobname.bac
	\fi
	\makeatother
	\bigskip

	\theBottomText
      }%
      \end{minipage}
    }% end \fbox
  }%
  \ifballotrepeat
    \vbox to \vsize{%
      \leaders\vbox{%
	\hbox to \hsize{%
	  \leaders\hbox{%
	    \box\ballot@tmpbox%
	    \hskip\ballothsep%
	  }%
	  \hfill%
	  \hskip-\ballothsep%
	}%
	\vskip\ballotvsep%
      }%
      \vfill%
      \vskip-\ballotvsep%
    }
  \else
    \box\ballot@tmpbox%
    \hfil\penalty0\hfilneg%
  \fi
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% evaluation of stored data

\newcommand{\ballot@party}[2]{%
  \ifballot@first
    \global\ballot@firstfalse
  \else
    \ballot@seprule%
  \fi
  \nobreak\hskip.5\ballotcolsep%
  \parbox[t]{\ballot@colwidth}{%
    \sffamily%
    \sloppy\raggedright%
    \LARGE%
    \ballot@hsplit{\ballotbox{2pt}{5mm}~}%
		  {\sloppy\raggedright#1}\medskip\par
    \large #2
  }%
  \nobreak\hskip.5\ballotcolsep%
}

\newenvironment{ballot@party@env}[2]{%
  \ifballot@first
    \global\ballot@firstfalse
  \else
    \ballot@seprule%
  \fi
  \nobreak\hskip.5\ballotcolsep%
  \begin{minipage}[t]{\ballot@colwidth}%
    \sffamily%
    \sloppy\raggedright%
    \ifnum\ballot@partycnt=1
      \LARGE #1\medskip\par
      \large #2\bigskip\par
    \fi
}{%
  \end{minipage}%
  \nobreak\hskip.5\ballotcolsep%
}

\newcommand{\ballot@cand}[2]{
  \normalsize%
  \ballot@hsplit{\ballotbox{1pt}{3mm}~}%
		{\sloppy\raggedright#1 \footnotesize#2}\par
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% graphical elements

\newcommand{\ballot@seprule}{%
  \nobreak\hskip-.5\ballotcolrule%
  \vrule width \ballotcolrule%
  \nobreak\hskip-.5\ballotcolrule%
}

\newcommand{\ballotbox}[3][]{%
  \ballot@tmpdim=#3%
  \advance\ballot@tmpdim by -1.5ex%
  \raise-.5\ballot@tmpdim%
  \hbox{%
    \fboxsep=0pt\fboxrule=#2%
    \fbox{%
      \vbox to#3{%
	\vss%
	\hbox to#3{\hss#1\hss}%
	\vss%
      }%
    }%
  }%
}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% helper

\newcommand{\useexpr}[2]{%
  \expandafter\edef\expandafter\useexpr@\expandafter#2{#1}%
  \useexpr@%
}

\newcommand{\piwrite}[2]{%
  \begingroup%
  \let\protect\@unexpandable@protect%
  \edef\tmp{\immediate\write#1{#2}}%
  \tmp%
  \endgroup%
}

\newcommand{\ballot@hsplit}[2]{%
  \begingroup%
  \setbox\ballot@tmpbox=\hbox{#1}%
  \advance\hsize by-\wd\ballot@tmpbox%
  \leavevmode%
  \box\ballot@tmpbox%
  \parbox[t]{\hsize}{#2}%
  \endgroup%
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
