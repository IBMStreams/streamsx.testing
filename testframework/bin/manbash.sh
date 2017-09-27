######################################################
# Utilities for testframework
#

function manbashpage () {
	less <<-EOF
Export Variables
================
The ro attribute (and others) is not availble in the child shell

Parameter Expansion
===================
\${parameter:=word}
              Assign Default Values.  If parameter is unset or null, the expansion of word is assigned to parameter. The value  of  parameter is
              then substituted.  Positional parameters and special parameters may not be assigned to in this way.
              
\${parameter=word}
              Assign Default Values.  If parameter is unset, the expansion of word is assigned to parameter. The value  of  parameter is
              then substituted.  Positional parameters and special parameters may not be assigned to in this way.
              
Conditionals
============
Prefer the [[ ]] expression (This is a Compound Command in bash man)
Word splitting and pathname expansion are not performed on the words between the [[ and ]];
tilde expansion, parameter and variable expansion,  arithmetic  expansion,  command  substitution, process substitution, and quote removal
are performed.  Conditional operators such as -f must be unquoted to be recognized as primaries.
- Unquotes variables
- Unquoted parenthese
- Pattern matching with == and !=
- Regular expression mathch with =~
....
Therefore a
if [[ -n \$STFPRN_VERBOSE && -z \$STFPRN_VERBOSE_DISABLE ]]; then
is fine
help [[ ]]  -shows more

test and [ ] 
- Quote variables! 
- Quote parentheses! 
...

help test  - shows more

Redirections
============
>&2          directs std to error out
&> file      directs error and stdout to file
2>&1         directs error to stdout
2>&1 | tee ...

Variable Expansion
==================
\${#parameter}
              Parameter  length.
              
\${parameter:offset}
\${parameter:offset:length}
              Substring Expansion (offset is zero base; negative lengts - the value is used as an offset from the end of the value of parameter
              
\${parameter#word}
\${parameter##word}
              Remove matching prefix pattern (# - shortest; ## - longest)
              
\${parameter%word}
\${parameter%%word}
              Remove matching suffix pattern (% - shortest; %% - longest

\${!parameter}
             Indirect addressing
              

EOF
}
