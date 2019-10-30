#!/bin/bash
# generate a web interface from a mod-host command history file

# This is the syntax and default setup for lv2rdf.conf

BUILDDIR=./build
MODHOSTCONF=./mod-host.cmd
MODHOSTHOST=localhost
MODHOSTREALNAME=`hostname`
MODHOSTPORT=5555
SAMPLERATE=48000
WEBGUIROOT=/var/www/html
WEBGUIURI=lv2rdf.html
JQUERYURI=https://code.jquery.com/jquery-3.3.1.min.js
JQUERYINTEGRITY=sha384-fJU6sGmyn07b+uD1nMk7/iSb4yvaowcueiQhfVgQuD98rfva8mcr1eSvjchfpMrH
JQUERYUIURI=https://code.jquery.com/ui/1.12.1/jquery-ui.min.js
JQUERYUIINTEGRITY=sha256-VazP97ZCwtekAsvgPBSUwPFKdrwD3unUfSGVYrahUqU=
JQUERYUICSSURI=http://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css
JQUERYUICSSINTEGRITY=
DOWNLOADJQUERY=true
JSURI=lv2rdf.js
CSSURI=lv2rdf.css
AJAXROOT=/var/www/html
AJAXURI=lv2rdf.php
XSLDIR=./xslt
# DESTDIR=

. lv2rdf.conf

SRISUFFIX=.sha
SRIHASH=sha384

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
  echo \*install\* will deploy the built interface files to the configured locations.
  echo
  echo \*clean\* will wipe intermediary files from \'$BUILDDIR\'.
  echo
  echo Source and target paths as well as JQuery versions can be configured in \'lv2rdf.conf\'.
  echo
  exit 255

}


function download {

  WGET="wget -q -P ${BUILDDIR:-.} --backups=1"
  echo -en "Downloading JQuery from $JQUERYURI..."
  $WGET "$JQUERYURI" && success || failure
  echo -en "Downloading JQuery-UI from $JQUERYUIURI..."
  $WGET "$JQUERYUIURI" && success || failure
  echo -en "Downloading JQuery-UI CSS from $JQUERYUICSSURI..."
  $WGET "$JQUERYUICSSURI" && success || failure
  for i in $JQUERYURI $JQUERYUIURI $JQUERYUICSSURI; do
    echo -en "Computing SRI checksum for $i..."
    n=`basename "$i"`
    {
      cat "$BUILDDIR"/"$n" \
      | openssl dgst -"$SRIHASH" -binary \
      | openssl enc -base64 -A \
      > "$BUILDDIR"/"$n""$SRISUFFIX"
    } && success || failure
  done

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

  if [[ "$DOWNLOADJQUERY" = "true" ]] ; then
    echo "Using a local copy of jQuery."
    download
    for i in JQUERYURI JQUERYUIURI JQUERYUICSSURI; do
      k=`basename "${!i}"`
      echo -en "Shortening $i to $k to use local copy..."
      declare $i=$k
      test "${!i}" = "$k" && success || failure
    done
    echo -en "Substituting local SRI hash for $JQUERYURI: "
    JQUERYINTEGRITY="$SRIHASH"-`cat "$BUILDDIR"/"$JQUERYURI""$SRISUFFIX"`
    echo "'$JQUERYINTEGRITY'."
    echo -en "Substituting local SRI hash for $JQUERYUIURI: "
    JQUERYUIINTEGRITY="$SRIHASH"-`cat "$BUILDDIR"/"$JQUERYUIURI""$SRISUFFIX"`
    echo "'$JQUERYUIINTEGRITY'."
    echo -en "Substituting local SRI hash for $JQUERYUICSSURI: "
    JQUERYUICSSINTEGRITY="$SRIHASH"-`cat "$BUILDDIR"/"$JQUERYUICSSURI""$SRISUFFIX"`
    echo "'$JQUERYUICSSINTEGRITY'."
  fi
  
  echo -ne "Generating XHTML $WEBGUIURI..."
  xsltproc \
    --stringparam jsuri "$JSURI" \
    --stringparam cssuri "$CSSURI" \
    --stringparam jqueryuri "$JQUERYURI" \
    --stringparam jqueryintegrity "$JQUERYINTEGRITY" \
    --stringparam jqueryuiuri "$JQUERYUIURI" \
    --stringparam jqueryuiintegrity "$JQUERYUIINTEGRITY" \
    --stringparam jqueryuicssuri "$JQUERYUICSSURI" \
    --stringparam jqueryuicssintegrity "$JQUERYUICSSINTEGRITY" \
    --stringparam hostname "$MODHOSTREALNAME" \
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


function install {

  echo -en "Installing XHTML $WEBGUIURI to $DESTDIR$WEBGUIROOT..."
  cp "$BUILDDIR"/"$WEBGUIURI" "$DESTDIR""$WEBGUIROOT" && success || failure

  echo -en "Installing JavaScript $JSURI to $DESTDIR$WEBGUIROOT..."
  cp "$BUILDDIR"/"$JSURI" "$DESTDIR""$WEBGUIROOT" && success || failure
 
  echo -en "Installing CSS $CSSURI to $DESTDIR$WEBGUIROOT..."
  cp "$CSSURI" "$DESTDIR""$WEBGUIROOT" && success || failure

  echo -en "Installing PHP AJAX handler $AJAXURI to $DESTDIR$AJAXROOT..."
  cp "$BUILDDIR"/"$AJAXURI" "$DESTDIR""$AJAXROOT" && success || failure

  for i in "$JQUERYURI" "$JQUERYUIURI" "$JQUERYUICSSURI"; do
    n="$BUILDDIR"/`basename $i`
    if [[ -e "$n" ]]; then
      echo -en "Installing $n to $DESTDIR$WEBGUIROOT..."
      cp "$n" "$DESTDIR""$WEBGUIROOT" && success || failure
    fi
  done
}


function cleanup {          
  
  echo -en "Deleting turtle files..."
  rm -f "$BUILDDIR"/*ttl && success || failure
  echo -en "Deleting rdf files..."
  rm -f "$BUILDDIR"/*rdf && success || failure
  echo -en "Deleting web interface files..."
  rm -f "$BUILDDIR"/"$WEBGUIURI" "$BUILDDIR"/"$JSURI" "$BUILDDIR"/"$CSSURI" "$BUILDDIR"/"$AJAXURI" && success || failure
  echo -en "Deleting local jQuery copies and checksums..."
  for i in "$JQUERYURI" "$JQUERYUIURI" "$JQUERYUICSSURI"; do
    k=`basename $i`
    rm -f "$BUILDDIR"/"$k"* && echo -n " $k"
  done ; success 
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
        install)
            install
            ;;
        clean)
            cleanup
            ;;
        download)
            download
            ;;
        *)
            usage
            ;;    
    esac
    shift
  done
}

parse_cmdline $@

