# lv2rdf2html
(C) 2017 by Jörn Nettingsmeier. This transform is licensed under the
GNU General Public License v3.

lv2rdf2html automatically generates HTML/jQuery GUIs for LV2 audio
plugins. The original usecase is to control plugin instances running
on embedded systems in a [mod-host](
https://github.com/moddevices/mod-host), but it can be adapted to
other uses easily.

The conversion is done with XSL transformations. This means that the 
LV2 metadata must be converted to XML first.

![UI generated for x42-fil#stereo (by Robin Gareus, DSP by Fons
!Adriaensen)](fil4stereo.png)
## Usage
  
* Gather URI information of available plugins:
```
#~> lv2ls
```
* Collect the desired plugin documentation in a Turtle file (lv2info appends to a file):
```
#~> rm output.ttl
#~> lv2info -p output.ttl http://gareus.org/oss/lv2/fil4#stereo
#~> lv2info -p output.ttl http://calf.sourceforge.net/plugins/Compressor
    ...
```
* Convert the turtle file to RDF/XML:
  * Using [rapper](http://librdf.org/raptor/rapper.html) (part of
    raptor/Redland, this is what I use for testing):
  ```
  #~> rapper -o rdfxml -i turtle output.ttl > output.xml
  ```
  * Using [rdf2rdf](http://www.l3s.de/~minack/rdf2rdf/) (I'm testing this
every once in a while, but expect hiccups):
  ```
  #~> java -jar rdf2rdf-1.0.1-2.3.1.jar output.ttl output.xml
  ```
* Generate the HTML page and prettyprint:
```
#~> xsltproc lv2rdf2html.xsl output.xml | xsltproc xml-prettyprint.xsl - > index.html
```
* Generate the PHP AJAX handler:
```
#~> xsltproc lv2rdf2php.xsl output.xml > pluginController.php
```
* Edit the mod-host server settings in [lv2rdf2php.xsl](lv2rdf2php.xsl) to
reflect your local setup.
* Deploy everything to a PHP-enabled webserver, including the CSS and
Javascript. There is a script `deploy.sh` that tries to be clever about this
and auto-deploys whenever you modify a file on disk. Works for me.

The steps listed above can be automatically performed by parsing a mod-host
command log with the experimental script `generate.sh`.

## Requirements

* LV2 plugins installed on your system,
* the LV2 tools lv2ls and lv2info,
* an XSLT 1.0  processor such as 
  * xsltproc or 
  * saxon,
* a Turtle-to-XML RDF converter, such as
  * [rapper](http://librdf.org/raptor/rapper.html) or
  * [rdf2rdf](http://www.l3s.de/~minack/rdf2rdf/).
* [mod-host](https://github.com/moddevices/mod-host), and
* a PHP-capable webserver
* (optional) inotify-tools for automated deployment

## Status

lv2rdf2html currently supports all LV2 features used by the plugins
listed above. As bugs are shaken out, more plugins will be added to the 
testing environment. 
The generated web GUI is fully functional and interacts with a configurable
mod-host instance, with a few missing features listed in the [TODO](TODO.md) 
file that do not impede basic usability. 
    
## Notes

Rdf2rdf and rapper produce different RDF/XML: rdf2rdf tries to collate
triplets (but does a horrible job of doing it in a consistent way), and rapper
does the simple, clean thing of keeping every single triplet separate. Both work
because the stylesheet doesn't make any assumptions about them being grouped, 
that's why it's soo terrible.
  
There is a very clean alternative converter at http://www.easyrdf.org/converter
which appears to do perfect grouping, but I'm a bit wary of supporting it because
it requires PHP, fails to include namespace prefixes and seems to make a few risky guesses...

Sometimes, the generated UI is not very nice to use because of deficiencies
in this code, and sometimes because the plugin's metadata is sub-optimal.
Calf is a bad example here, it does much usability magic in its GUI and
exposes ports with coefficient gains rather than logarithmic. I hope I can
get a few of these issues fixed upstream as the project matures.
