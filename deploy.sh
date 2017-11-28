#!/bin/bash
SERVER=localhost
DOCROOT=/var/www/html/
SOURCE=~/output.xml
SLEEPTIME=5


function deployHTML {
  xsltproc lv2rdf2html.xsl "$SOURCE" \
    | xsltproc xml-prettyprint.xsl - \
    | ssh $SERVER "cat > '$DOCROOT'/index.html"

}

function watchHTML {
while : ; do  
  inotifywait -e modify lv2rdf2html.xsl iterators.xsl gui-*.xsl "$SOURCE";
  deployHTML
  sleep $SLEEPTIME
done
}

function deployPHP {
  xsltproc lv2rdf2php.xsl "$SOURCE" \
    | ssh $SERVER "cat > '$DOCROOT'/pluginController.php"
}

function watchPHP {
while : ; do
  inotifywait -e modify lv2rdf2php.xsl "$SOURCE";
  deployPHP
  sleep $SLEEPTIME
done
}

function deployOther {
  scp *css *js $SERVER:"$DOCROOT"
}

function watchOther {
while : ; do
  inotifywait -e modify *css *js ;
  deployOther
  sleep $SLEEPTIME
done
}

echo "Initial deployment of all files:"
echo -n "HTML code... "
deployHTML && echo "done." || echo "failed."  
echo -n "PHP code... "
deployPHP && echo "done." || echo "failed."
echo  "CSS and Javascript... "  
deployOther && echo "done." || echo "failed."  

echo "Hit Control-C to terminate $0." 
  
watchHTML &
watchHTML_PID="$!"
watchPHP &
watchPHP_PID="$!"
watchOther &
watchOther_PID="$!"

function user_break {
  echo "Ok, preparing to exit..."
  kill $watchHTML_PID
  kill $watchPHP_PID
  kill $watchOther_PID
  echo "Cleaned up, goodbye!"
  exit 0;
}

trap user_break SIGINT

while : ; do
  sleep 60
done
