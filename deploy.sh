#!/bin/bash
SERVER=86.83.27.183
DOCROOT=/srv/www/htdocs/
SOURCE=~/output.xml
SLEEPTIME=5

echo "Hit Control-C to terminate $0." 

function deployHTML {
while : ; do  
  inotifywait -e modify lv2rdf2html.xsl iterators.xsl gui-*.xsl ;
  xsltproc lv2rdf2html.xsl "$SOURCE" \
    | xsltproc xml-prettyprint.xsl - \
    | ssh $SERVER "cat > '$DOCROOT'/index.html"
  sleep $SLEEPTIME
done
}

function deployPHP {
while : ; do
  inotifywait -e modify lv2rdf2php.xsl ;
  xsltproc lv2rdf2php.xsl $SOURCE \
    | ssh $SERVER "cat > '$DOCROOT'/pluginController.php"
  sleep $SLEEPTIME
done
}

function deployOther {
while : ; do
  inotifywait -e modify *css *js ;
  scp *css *js $SERVER:"$DOCROOT"
  sleep $SLEEPTIME
done
}
  
deployHTML &
deployHTML_PID="$!"
deployPHP &
deployPHP_PID="$!"
deployOther &
deployOther_PID="$!"

function user_break {
  echo "Ok, preparing to exit..."
  kill $deployHTML_PID
  kill $deployPHP_PID
  kill $deployOther_PID
  echo "Cleaned up, goodbye!"
  exit 0;
}

trap user_break SIGINT

while : ; do
  sleep 60
done