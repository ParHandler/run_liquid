#!/bin/bash
docker kill libreoffice
docker rm libreoffice

echo make md
docker run --rm -v $(pwd):/documents/ asciidoctor-od asciidoctor -r asciidoctor-mathematical -r asciidoctor-diagram statqya.adoc -b docbook
pandoc -f docbook -t markdown -s statqya.xml -o statqya.md --wrap=none --atx-headers

sed  -i 's/{[a-zа-я#_]*}//g' statqya.md
sed  -i 's/---/—/g' statqya.md

#
#echo make fodt
#docker run --rm -v $(pwd):/documents/ asciidoctor-od a-od-pre -r asciidoctor-mathematical -r asciidoctor-diagram statqya.adoc -o pre.xml
#docker run --rm -v $(pwd):/documents/ asciidoctor-od a-od-out -f template_s.fodt -i pre.xml -o statya.fodt
#
#docker run --rm -v $(pwd):/documents/ asciidoctor-od a-od-pre -r asciidoctor-mathematical -r asciidoctor-diagram adoc_baza_dannyhx.adoc -o pre.xml
#docker run --rm -v $(pwd):/documents/ asciidoctor-od a-od-out -f template.fodt -i pre.xml -o adoc_baza_dannyhx.fodt
#
#docker run --rm -v $(pwd):/documents/ asciidoctor-od a-od-pre -r asciidoctor-mathematical -r asciidoctor-diagram adoc_egrul_vmeste.adoc -o pre.xml
#docker run --rm -v $(pwd):/documents/ asciidoctor-od a-od-out -f template.fodt -i pre.xml -o adoc_egrul_vmeste.fodt
#
#echo convert with libreoffice
#docker run -d --name libreoffice -p 8100:8100 hdejager/libreoffice-api
#sleep 3
#docker cp statya.fodt libreoffice:/tmp/statya.fodt
#docker cp adoc_baza_dannyhx.fodt libreoffice:/tmp/adoc_baza_dannyhx.fodt
#docker cp adoc_egrul_vmeste.fodt libreoffice:/tmp/adoc_egrul_vmeste.fodt
#docker exec -i libreoffice unoconv --connection \
#    'socket,host=127.0.0.1,port=8100,tcpNoDelay=1;urp;StarOffice.ComponentContext' \
#    -f odt /tmp/statya.fodt
#docker exec -i libreoffice unoconv --connection \
#    'socket,host=127.0.0.1,port=8100,tcpNoDelay=1;urp;StarOffice.ComponentContext' \
#    -f docx /tmp/adoc_baza_dannyhx.fodt
#docker exec -i libreoffice unoconv --connection \
#    'socket,host=127.0.0.1,port=8100,tcpNoDelay=1;urp;StarOffice.ComponentContext' \
#    -f docx /tmp/adoc_egrul_vmeste.fodt
#docker cp libreoffice:/tmp/statya.odt .
#docker cp libreoffice:/tmp/adoc_baza_dannyhx.docx .
#docker cp libreoffice:/tmp/adoc_egrul_vmeste.docx .
#docker kill libreoffice
#docker rm libreoffice
