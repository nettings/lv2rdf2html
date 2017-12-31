#!/bin/bash
# generate a web interface from a mod-host command history file

XSLDIR="."
TARGETDIR="."

if [[ -z "$1" ]] ; then 
  echo Usage: $0 FILE
  echo
  echo FILE is a mod-host command history used to create
  echo the plugin graph. $0 will filter out all the statements
  echo that instantiate plugins and create a web interface to match.
  echo
  echo $0 expects to find its XSL files in \'$XSLDIR\', and will 
  echo write generated files out to \'$TARGETDIR\'.
  exit 1
fi
  
TTLOUTFILE=`mktemp --tmpdir --suffix=.ttl output_XXXXXXX`
if [[ -z "$TTLOUTFILE" ]] ; then
  echo "Failed to create temporary TTL file."
  exit 1
else
  echo "Created temporary $TTLOUTFILE."
fi

XMLOUTFILE=`mktemp --tmpdir --suffix=.xml output_XXXXXXX`
if [[ -z "$XMLOUTFILE" ]] ; then
  echo "Failed to create temporary XML file."
  exit 1
else
  echo "Created temporary $XMLOUTFILE."
fi

tac "$1" |				# print command history file in reverse order, last line first 
  awk '$1 ~ /^add$/ {print $0}' | 	# filter out commands that add a plugin
  sort -k3 -n -u |			# sort numerically by instance number, only showing the first occurrence (=last plugin loaded into that slot)
  awk '{print $2}' |			# print only the field containing the plugin URI
  while read line; do
    echo "Found plugin $line."
    lv2info -p "$TTLOUTFILE" "$line"
  done

  rapper -o rdfxml -i turtle "$TTLOUTFILE" > "$XMLOUTFILE" \
    && echo "Successfully parsed and converted $TTLOUTFILE to $XMLOUTFILE." \
    || {
      echo "Failed to parse $TTLOUTFILE."
      exit 2
    }
  xsltproc "$XSLDIR"/lv2rdf2html.xsl "$XMLOUTFILE" | 
    xsltproc "$XSLDIR"/xml-prettyprint.xsl > index.html \
    && echo "Successfully created index.html" \
    || {
      echo "Failed to create index.html".
      exit 3
    }
  xsltproc "$XSLDIR"/lv2rdf2php.xsl "$XMLOUTFILE" > pluginController.php \
    && echo "Successfully created pluginController.php" \
    || {
      echo "Failed to create pluginController.php".
      exit 4 
    }
      
   
rm "$TTLOUTFILE" \
  || echo "Failed to remove temporary $TTLOUTFILE." \
  && echo "Removed $TTLOUTFILE."
rm "$XMLOUTFILE" \
  || echo "Failed to remove temporary $XMLOUTFILE." \
  && echo "Removed $XMLOUTFILE."



