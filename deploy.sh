#!/bin/sh
SERVER=86.83.27.183
DOCROOT=/srv/www/htdocs/
while : ; do  
  inotifywait -e modify lv2rdf2html.xsl iterators.xsl gui-*.xsl ;
  xsltproc lv2rdf2html.xsl ~/Desktop/*media*/output.xml \
    | xsltproc xml-prettyprint.xsl - \
    | ssh $SERVER "cat > $DOCROOT/index.html"
  sleep 5
done &

while : ; do
  inotifywait -e modify lv2rdf2php.xsl ;
  xsltproc lv2rdf2php.xsl ~/Desktop/*media*/output.xml \
    | ssh $SERVER "cat > $DOCROOT/pluginController.php"
  sleep 5
done &

while : ; do
  inotifywait -e modify *css *js ;
  scp *css *js $SERVER:$DOCROOT
  sleep 5
done

  
  