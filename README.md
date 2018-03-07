# Construction de paquet depuis un depôt GIT

## Introduction

La documentation ci-dessous sera appliquée sur un poste utilisateur Debian.

Ce dépôt est répartie sous plusieurs répertoires:

* scripts       - Les différents scripts utilisés pour générer le paquet et par le paquet lui-même.
* configuration - Contient les exemples de fichiers de configuration utilisés par le script
* log           - Le répertoire de log utilisé par les builds. Ce répertoire devrait être vide dans le Gitlab.

## Prérequis du système

### FPM 

Le script utilise le paquet FPM, il nécessite donc que le système de build ait ce paquet d'installé.

Installation des dépendances de FPM
```
apt-get install ruby ruby-dev rubygems build-essential
```

L'installation de FPM est faite via internet car celui-ci ne dispose pas de paquet
et l'installation se fait via gem.

```
sudo -E gem install --no-ri --no-rdoc fpm
Password: 
Fetching: cabin-0.9.0.gem (100%)
Successfully installed cabin-0.9.0
Fetching: backports-3.11.0.gem (100%)
Successfully installed backports-3.11.0
Fetching: arr-pm-0.0.10.gem (100%)
Successfully installed arr-pm-0.0.10
Fetching: clamp-1.0.1.gem (100%)
Successfully installed clamp-1.0.1
Fetching: ffi-1.9.18.gem (100%)
Building native extensions.  This could take a while...
Successfully installed ffi-1.9.18
Fetching: childprocess-0.8.0.gem (100%)
Successfully installed childprocess-0.8.0
Fetching: io-like-0.3.0.gem (100%)
Successfully installed io-like-0.3.0
Fetching: ruby-xz-0.2.3.gem (100%)
Successfully installed ruby-xz-0.2.3
Fetching: stud-0.0.23.gem (100%)
Successfully installed stud-0.0.23
Fetching: mustache-0.99.8.gem (100%)
Successfully installed mustache-0.99.8
Fetching: insist-1.0.0.gem (100%)
Successfully installed insist-1.0.0
Fetching: dotenv-2.2.1.gem (100%)
Successfully installed dotenv-2.2.1
Fetching: pleaserun-0.0.30.gem (100%)
Successfully installed pleaserun-0.0.30
Fetching: fpm-1.9.3.gem (100%)
Successfully installed fpm-1.9.3
14 gems installed
```

Pour plus d'information sur FPM, voir
[Documentation FPM] (http://fpm.readthedocs.io/en/latest/index.html)

## Utilisation de la solution

Le répertoire script contient build-package.sh qui permet de construire un paquet RPM ou DEB à partir de dépôt GIT.

L'aide du plugin est disponible tel que:
```
scripts/build-package.sh -h
```

Exemple d'utilisation
```
scripts/build-package.sh -o DEBIAN -a 64 -c configuration/config.ini -d configuration/outputs.ini
```

### Fichier de configuration

Le script de build utilise un fichier de configuration sous la forme 'VAR_NAME="VALUE"'.
Un fichier type peut-être trouvé sous [configuration/build.conf](configuration/build.conf)

### Fichier de dépendences

Un fichier de dépendance peut être passé en argument.
Il doit contenir une dépendance par ligne.

Un fichier type peut-être trouvé sous configuration/debian.deps

```
#
# Fichier de dépendences Debian utilisé pour
# build-package.sh
#
libsnmp-perl
libxml-libxml-perl
libjson-perl
libwww-perl
libxml-xpath-perl
libnet-telnet-perl
libnet-ntp-perl
libnet-dns-perl
libdbi-perl
libdbd-mysql-perl
libdbd-pg-perl
```

### Fichier de répertoire

Ce fichier passé en argument permet à FPM de lié le répertoire
source avec sa destination finale lors de l'installation.

```
#
# Fichier de répertoire type utilisé pour
# build-package.sh
#

# <DIR SOURCE>=<INSTALL_OUTPUT_DIR>
paquet-generator/=/test/paquet-generator
```

Un fichier type peut-être trouvé sous configuration/directory.conf

### Fichier d'option de FPM

Ce fichier passé en argument permet de passer des options 
à FPM durant la construction du paquet.

```
#
# Fichier d'option passé à FPM pour le script
# build-package.sh
#
--template-scripts --after-install paquet-generator/scripts/post-installation.sh
```

Un fichier type peut-être trouvé sous configuration/fpm.conf

## Création des TAGs de version

Le script se base sur la création de tag avec un nommage spécifique pour déterminer le numéro de version du paquet.
Il est nécessaire de créer un tag sous la forme "cv[0-9].*"

Les tags peuvent être créés directement depuis le Gitlab ou en utilisant la commande
```
git tag -a "<tag>" # Ex: git tag -a "cv2.5"
```


Cela donnera un nommage sous la forme suivante:
```
package-generator_2.5.3111_amd64.deb
package-generator_2f4fe15.3111_amd64.deb
```

## Utilisation du système de packaging

Les fichiers de packaging sont stockés sous configuration/packaging.
Ils permetttent d'utiliser package-generator pour générer un paquet RPM ou DEB.

La création du paquet nécessite donc d'avoir une version de package-generator de présente
sur la machine où vous souhaitez générer le paquet.

Le paquet peut alors être généré tel que:

```
<path>/package-generator/scripts/build-package.sh -o RHEL -a 64 -c configuration/packaging/build.conf -d configuration/packaging/directory.espv.conf -D configuration/packaging/centos.deps -f configuration/packaging/fpm.conf
```

Le logiciel permet de spécifier une branche pour le projet, sous la forme -b "nom_projet:nom_branche,nom_projet2:branche1"

Pour plus d'informations, l'aide du logiciel est disponible via <path>/package-generator/scripts/build-package.sh -h
