#! /bin/bash
# http://blog.fclement.info/content/supprimer-tous-les-tableaux-de-bord-ubuntu-904
gconftool --set /apps/panel/general/toplevel_id_list --type list --list-type string []
gconftool --recursive-unset /apps/panel/toplevels
