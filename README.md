# lv2rdf2html
(C) 2017 by Jörn Nettingsmeier. This transform is licensed under the
GNU General Public License v3.

lv2rdf2html converts LV2 plugin documentation in RDF/XML format to a simple
form-based HTML5/jquery-ui GUI with a PHP backend, by means of XSL
transformations. This means that the LV2 metadata must be converted to
XML.
The resulting code is designed to control plugins running embedded in a 
mod-host through a socket connection, but could be adapted to other uses easily.

This stylesheet has been developed and tested with RDF/XML generated in the 
following way:
  
0. Gather URI information of available plugins:
```
#~> lv2ls
```
0. Collect plugin documentation in a Turtle file (lv2info appends to a file):
```
#~> rm output.ttl
#~> lv2info -p output.ttl http://gareus.org/oss/lv2/fil4#stereo
#~> lv2info -p output.ttl http://calf.sourceforge.net/plugins/Compressor
    ...
```
0. Convert the turtle file to RDF/XML:
  0. Using [rdf2rdf](http://www.l3s.de/~minack/rdf2rdf/):
  ```
  #~> java -jar rdf2rdf-1.0.1-2.3.1.jar output.ttl output.xml
  ```
  0. Using [rapper](http://librdf.org/raptor/rapper.html) (part of raptor/Redland):
  ```
  #~> rapper -o rdfxml -i turtle output.ttl > output2.xml
  ```
0. Apply this stylesheet and prettyprint:
```
#~> xsltproc lv2rdf2html.xsl output.xml | xsltproc xml-prettyprint.xsl - > output.html
#~> xsltproc lv2rdf2html.xsl output2.xml | xsltproc xml-prettyprint.xsl - > output2.html
```
It currently tries to support all LV2 features used by the plugins listed above.
    
Rdf2rdf and rapper produce different RDF/XML: rdf2r2f tries to collate
triplets (but does a horrible job of doing it in a consistent way), and rapper
does the simple, clean thing of keeping every single triplet separate. Both work
because the stylesheet doesn't make any assumptions about them being grouped, 
that's why it's soo terrible.
  
There is a very clean alternative converter at http://www.easyrdf.org/converter
which appears to do perfect grouping, but I'm a bit wary of supporting it because
it requires PHP, fails to include namespace prefixes and seems to make a few risky guesses...
