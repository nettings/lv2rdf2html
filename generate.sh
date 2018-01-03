#!/bin/bash
# generate a web interface from a mod-host command history file

. lv2rdf.conf

XSLDIR="."

if [[ -z "$1" ]] ; then 
  echo Usage: $0 FILE [-d]
  echo
  echo FILE is a mod-host command history used to create
  echo the plugin graph. $0 will filter out all the statements
  echo that instantiate plugins and create a web interface to match.
  echo
  echo $0 expects to find its XSL files in \'$XSLDIR\', and will 
  echo write generated files out to \'$WEBGUIROOT\'.
  echo
  echo The optional trailing parameter -d \(\"debug\"\) will prevent the removal
  echo of temporary files to aid in debugging.
  exit 1
fi
  
TTLOUTFILE=`mktemp --tmpdir --suffix=.ttl lv2rdf_XXXXXXX`
if [[ -z "$TTLOUTFILE" ]] ; then
  echo "Failed to create temporary TTL file."
  exit 1
else
  echo "Created temporary $TTLOUTFILE."
fi

XMLOUTFILE=`mktemp --tmpdir --suffix=.xml lv2rdf_XXXXXXX`
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
  xsltproc \
    --stringparam jsuri "$JSURI" \
    --stringparam cssuri "$CSSURI" \
    "$XSLDIR"/lv2rdf2html.xsl "$XMLOUTFILE" \
    | xsltproc "$XSLDIR"/xml-prettyprint.xsl - > "$WEBGUIROOT"/"$WEBGUIURI" \
    && echo "Successfully created $WEBGUIURI" \
    || {
      echo "Failed to create $WEBGUIURI".
      exit 3
    }
  xsltproc \
    --stringparam host "$MODHOSTHOST" \
    --param port "$MODHOSTPORT" \
    "$XSLDIR"/lv2rdf2php.xsl "$XMLOUTFILE" > "$AJAXROOT"/"$AJAXURI" \
    && echo "Successfully created $AJAXURI" \
    || {
      echo "Failed to create $AJAXURI".
      exit 4 
    }
  xsltproc \
    --stringparam ajaxuri "$AJAXURI" \
    "$XSLDIR"/lv2rdf2js.xsl "$XMLOUTFILE" > "$WEBGUIROOT"/"$JSURI" \
    && echo "Successfully created $JSURI" \
    || {
      echo "Failed to create $JSURI".
      exit 5 
    }
  cp "$XSLDIR"/lv2rdf.css "$WEBGUIROOT"/"$CSSURI" \
    && echo "Successfully installed $CSSURI." \
    || {
      echo "Failed to install $CSSURI".
      exit 5 
    }
      
if [[ $2 != "-d" ]] ; then    
  rm "$TTLOUTFILE" \
    || echo "Failed to remove temporary $TTLOUTFILE." \
    && echo "Removed $TTLOUTFILE."
  rm "$XMLOUTFILE" \
    || echo "Failed to remove temporary $XMLOUTFILE." \
    && echo "Removed $XMLOUTFILE."
fi


