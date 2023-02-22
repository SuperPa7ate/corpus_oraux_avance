# Script Praat : comparaison du pitch (prosodie ?) de deux fichiers audio

Vous trouverez ci-joint les dossiers/fichiers concernant le script [Praat](https://www.fon.hum.uva.nl/praat/).

Le script se décompose en 3 parties :
- application d'easyalign sur les deux fichiers son ainsi que leur transcription
- traitement de chaque fichier (récupération des valeur du pitch à chaque borne de syllabe et calcul de pourcentage d'évolution entre ces deux bornes)
- comparaison des pourcentages obtenus sur les deux fichiers

Deux fichiers ressortent de ce traitement :
- un fichier .txt qui regroupe les mesures du pitch
- un fichier .csv qui donne les pourcentages d'évolution ainsi que le résultat du calcul (est-ce que oui ou non l'évolution est similaire à xx%)

## Prérequis

L'execution de ce script nécessite l'installation de [Praat](https://www.fon.hum.uva.nl/praat/) ainsi que du plug-in [EasyAlign](http://latlcui.unige.ch/phonetique/easyalign.php).

Pour des raisons de portabilité, les deux sont fournis dans le dossier et permettent un lancement autonome sans prérequis.

## Installation

Aucune installation particulièrement nécessaire dans la mesure où une version portable se trouve dans le dossier.

## Arborescence des fichiers
```
📦corpus_oraux_avance
 ┗ 📂fichiers
 ┃ ┣ 📂easyalign
 ┃ ┣ 📂results
 ┃ ┣ 📂sons
 ┃ ┃ ┣ 📜prince_1.txt
 ┃ ┃ ┣ 📜prince_1.wav
 ┃ ┃ ┣ 📜prince_2.txt
 ┃ ┃ ┗ 📜prince_2.wav
 ┃ ┣ 📜Praat.exe
 ┃ ┣ 📜readme.md
 ┃ ┗ 📜script_comparaison_sons.praat
 ```

### 📦corpus_oraux_avance

Le dossier racine, qui contient un certain nombre de fichiers importants.

#### 📂fichiers
L'endroit où se trouvent tous les fichiers pour le script.
Il contient notamment l'exe de Praat (pour Windows), le readme sur vous êtes en train de lire et le script Praat à proprement parlé.

##### 📂easyalign

Le dossier qui contient tous les fichiers relatifs à EasyAlign. Permet de pouvoir lancer EasyAlign depuis le script.

##### 📂results

Dossier qui contient les sorties du script (fichiers txt et csv).

##### 📂sons

C'est l'endroit où mettre les fichiers son (au format .wav de préférence) et leur transcription (au format .txt) à traiter.

## Pour utiliser le script

Il suffit de lancer Praat.exe, de charger le script ```Praat > Open Praat script...```, puis de faire ```CTRL+R``` pour lancer le script.
Une fenêtre pop-up apparaît alors pour donner certaines informations relatives au traitement des fichiers.

### Images du prompt et des sorties 
Exemple du prompt : 
![](https://i.imgur.com/oFtWP6H.png)

Exemple des fichiers de sortie  :
- Le fichier .txt qui contient les mesures : ![](https://i.imgur.com/fOgCh9M.png)
- Le fichier .csv qui contient le résultat de la compraison : ![](https://i.imgur.com/aEMTkst.png)

## Disclaimer

Ce script n'est pas forcément correct d'un point de vue linguistique. La comparaison est mesure est probablement totalement hors-sol. L'idée était simplement de proposer un script qui permet de le faire (en faisant des pourcentage de pourcentages).

Quelques améliorations au sein du script sont également possibles :
- Des fichiers de sortie un peu plus lisibles (voire peut-être un seul fichier qui regroupe les deux ?)
- Un calcul prosodique qui se base sur des paramètres linguistiquement viables autres que le F0. La comparaison prosodique est un sujet très complexe, et ce script n'a absolument pas la prétention d'avoir fait les choses correctement en ce sens
- Des améliorations au niveau de l'organisation du code en lui-même : du fait des particularités du langage de script, certaines variables ont un scope global et passent d'une procédure à l'autre. C'est pas très bien.

## Remerciements
Llyad, pour le petit coup de main mathématique pour la comparaison des courbes.
Vous-mêmes, qui avez survécu jusqu'à la fin.

