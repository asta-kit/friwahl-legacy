#!/bin/bash

cat <<EOF
\documentclass{article}
\usepackage{a4wide}
\usepackage[latin1]{inputenc}
\usepackage[ngerman]{babel}
\usepackage{wahead}
\parindent=0pt
\begin{document}
\wahead
\begin{center}
\bfseries\Huge Automatische Konsistenzprüfung
\end{center}
EOF
( cd ../ ; ./UrnenPruefen.pl $DBSERVER ) |
perl -ne 's/^(Urne .*)$/\\section*{$1}/; s/^    /\\qquad /; print "$_\n"'
cat <<EOF
\end{document}
EOF

