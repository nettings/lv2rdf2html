#!/bin/bash
# generate a web interface from a mod-host command history file

# This is the syntax and default setup for lv2rdf.conf

BUILDDIR=./build
MODHOSTCONF=./mod-host.cmd
MODHOSTHOST=localhost
MODHOSTPORT=5555
WEBGUIROOT=/var/www/html
WEBGUIURI=lv2rdf.html
JQUERYURI=https://code.jquery.com/jquery-3.3.1.js
JQUERYINTEGRITY=sha384-fJU6sGmyn07b+uD1nMk7/iSb4yvaowcueiQhfVgQuD98rfva8mcr1eSvjchfpMrH
JQUERYUIURI=https://code.jquery.com/ui/1.12.1/jquery-ui.min.js
JQUERYUIINTEGRITY=sha256-VazP97ZCwtekAsvgPBSUwPFKdrwD3unUfSGVYrahUqU=
JQUERYUICSSURI=http://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css
JSURI=lv2rdf.js
CSSURI=lv2rdf.css
AJAXROOT=/var/www/html
AJAXURI=lv2rdf.php
XSLDIR=.

. lv2rdf.conf

function success {
  echo  -e " \033[1;32msucceeded.\033[0m"
}

function failure {
  echo  -e " \033[1;31mfailed with return code $?.\033[0m"
  exit 1
}

function usage {
  echo Usage: $0 [build\|download\|install\|clean]
  echo
  echo \*build\* takes a mod-host command history file from \'$MODHOSTCONF\' 
  echo \(the one used to create the plugin graph\). 
  echo $0 will filter out all the statements
  echo that instantiate plugins and create a web interface to match.
  echo
  echo XSL files are expected in \'$XSLDIR\', generated files will be  
  echo written out to \'$BUILDDIR\'. 
  echo
  echo \*download\* will make a local copy of the desired JQuery and JQueryUI versions.
  echo 
  echo \*install\* will deploy the built interface files to the configured locations.
  echo
  echo \*clean\* will wipe intermediary files from \'$BUILDDIR\'.
  echo
  echo Source and target paths as well as JQuery versions can be configured in \'lv2rdf.conf\'.
  echo
  exit 255
}

function build {
  
  RDF="$BUILDDIR"/allplugins.rdf	
  echo -e "Opening output file $RDF..."
  echo "<plugins>" > "$RDF"

  while read uri index; do
  
    echo "Found plugin $index: $uri." 

    TTLOUTFILE[index]="$BUILDDIR"/`printf %03d $index`.ttl
    echo -ne "\tWriting out plugin info to Turtle file ${TTLOUTFILE[index]}..."
    rm -f "${TTLOUTFILE[index]}" # clear now because lv2info always appends
    lv2info -p "${TTLOUTFILE[index]}" "$uri" && success || failure

    RDFOUTFILE[index]="$BUILDDIR"/`printf %03d $index`.rdf
    echo -ne "\tConverting to RDF/XML file ${RDFOUTFILE[index]}..."
    rapper -q -o rdfxml -i turtle "${TTLOUTFILE[index]}" \
    | xsltproc --param pluginID "$index" "$XSLDIR"/addPluginID.xsl - > "${RDFOUTFILE[index]}" && success || failure

    cat ${RDFOUTFILE[index]} >> $RDF
        
  done  <<< `
    tac "$MODHOSTCONF" |		# print command history file in reverse order, last line first 
    awk '$1 ~ /^add$/ {print $0}' | 	# filter out commands that add a plugin
    sort -k3 -n -u |			# sort numerically by instance number, only showing the first occurrence (=last plugin loaded into that slot)
    awk '{print $2" "$3}'		# print only the field containing the plugin URI
  `
  echo -e "...closing output file $RDF."
  echo "</plugins>" >> "$RDF"

  echo -ne "Generating XHTML $WEBGUIURI..."
  xsltproc \
    --stringparam jsuri "$JSURI" \
    --stringparam cssuri "$CSSURI" \
    --stringparam jqueryuri "$JQUERYURI" \
    --stringparam jqueryintegrity "$JQUERYINTEGRITY" \
    --stringparam jqueryuiuri "$JQUERYUIURI" \
    --stringparam jqueryuiintegrity "$JQUERYUIINTEGRITY" \
    --stringparam jqueryuicssuri "$JQUERYUICSSURI" \
    "$XSLDIR"/lv2rdf2html.xsl "$RDF" \
  | xsltproc "$XSLDIR"/xml-prettyprint.xsl - > "$BUILDDIR"/"$WEBGUIURI" && success || failure

  echo -en "Generating server-side AJAX handler..."
  xsltproc \
    --stringparam host "$MODHOSTHOST" \
    --param port "$MODHOSTPORT" \
    "$XSLDIR"/lv2rdf2php.xsl "$RDF" > "$BUILDDIR"/"$AJAXURI" && success || failure

  echo -en "Generating client-side AJAX handler..."
  xsltproc \
    --stringparam ajaxuri "$AJAXURI" \
    "$XSLDIR"/lv2rdf2js.xsl "$RDF" > "$BUILDDIR"/"$JSURI" && success || failure

}


function download {
  WGET="wget -nv -P ${BUILDDIR:-.} --backups=1"
  echo -e "Downloading JQuery from $JQUERYURI..."
  $WGET "$JQUERYURI" && success || failure
  echo -e "Downloading JQuery-UI from $JQUERYUIURI..."
  $WGET "$JQUERYUIURI" && success || failure
  echo -e "Downloading JQuery-UI CSS from $JQUERYUICSSURI..."
  $WGET "$JQUERYUICSSURI" && success || failure
}

function install {

  echo -en "Installing XHTML $WEBGUIURI to $WEBGUIROOT..."
  cp "$BUILDDIR"/"$WEBGUIURI" "$WEBGUIROOT" && success || failure

  echo -en "Installing JavaScript $JSURI to $WEBGUIROOT..."
  cp "$BUILDDIR"/"$JSURI" "$WEBGUIROOT" && success || failure
 
  echo -en "Installing CSS $CSSURI to $WEBGUIROOT..."
  cp "$CSSURI" "$WEBGUIROOT" && success || failure

  echo -en "Installing PHP AJAX handler $AJAXURI to $AJAXROOT..."
  cp "$BUILDDIR"/"$AJAXURI" "$AJAXROOT" && success || failure

}

function cleanup {          
  
  echo -en "Deleting turtle files..."
  rm -f "$BUILDDIR"/*ttl && success || failure
  echo -en "Deleting rdf files..."
  rm -f "$BUILDDIR"/*rdf && success || failure
  echo -en "Deleting web interface files..."
  rm -f "$BUILDDIR"/"$WEBGUIURI" "$BUILDDIR"/"$JSURI" "$BUILDDIR"/"$CSSURI" "$BUILDDIR"/"$AJAXURI" && success || failure
  
}

function parse_cmdline {
  if [[ -z "$1" ]] ; then
    usage
  fi

  while [ "$1" ] ; do
    case "$1" in
        build)
            build
            ;;
        download)
            download
            ;;
        install)
            install
            ;;
        clean)
            cleanup
            ;;
        *)
            usage
            ;;    
    esac
    shift
  done
}

parse_cmdline $@

