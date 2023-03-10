form comparer le pitch des syllabes de deux fichiers
	comment choisir 2 fichiers à comparer ainsi que leur transcription (par défaut stockés dans le dossier sons): 
	text fichier1	prince_1.wav
	text transcription1 prince_1.txt
	text fichier2	prince_2.wav
	text transcription2 prince_2.txt
	comment le chemin de sortie du fichier (par défaut dans le dossier results)
	text resultsfile results\mesures_pitch.txt
    comment indiquer le chemin d'accès du dossier d'installation d'EasyAlign (par défaut le chemin EA du dossier)
    text pathEA easyalign
    #comment indiquer le pourcentage de de similarité à calculer (par défaut +- 25%)

    endform


writeInfoLine: resultsfile$

sortie$=resultsfile$
appendInfoLine: "Le fichier de sortie est ", sortie$
writeFileLine: sortie$


@AutoEasyAlign: fichier1$, transcription1$
@AutoEasyAlign: fichier2$, transcription2$
@TraitementSon: fichier1$
@TraitementSon: fichier2$
@ComparaisonF0: fichier1$, fichier2$
#Partie procédure

procedure AutoEasyAlign: .fichierSon$, .fichierTxt$

    #manipulation des noms de fichier

    .fichierWav1$= "sons\"+.fichierSon$
    .fichiertxt1$= "sons\"+.fichierTxt$

    son = Read from file: .fichierWav1$
    txt = Read Strings from raw text file: .fichiertxt1$

    selectObject: son
    pitch=To Pitch: 0, 75, 600  

    #1. Macro-segmentation... son, txt

    selectObject: txt, son

    runScript: pathEA$+"\utt_seg2.praat", "ortho", "yes"

    #2. Phonetization

    runScript: pathEA$+"\phonetize_orthotier2.praat", "ortho", "phono", "fra", "yes", "yes"

    #2.5 selection du fichier TextGrid

    .nomDuFichier$ = .fichierSon$-".wav"

    .txtgrid$= "TextGrid "+.nomDuFichier$

    #3. Phone segmentation
    #need le txtgrid, il faut le retrouver ? ou alors créer son nom depuis la variable
    selectObject: son
    plusObject: .txtgrid$
    runScript: pathEA$+"\align_sound.praat", "ortho", "phono", "yes", "fra", "}-';(),.?¿", "no", "yes", "no", 90, "yes", "yes"

    #4. Sauvegarde du fichier textGrid

    selectObject: .txtgrid$
    .nomDuTextGridSauv$= .nomDuFichier$+".TextGrid"
    Save as text file: "D:\00. Cours\S3\corpus_oraux_avance\fichiers\sons\"+.nomDuTextGridSauv$
endproc

procedure TraitementSon: .fichierSon$

    #Récupération du nom des textgrid (pour pouvoir les selectionner par le nom)
    .nomDuFichier$ = .fichierSon$-".wav"
    .txtgrid$= "TextGrid "+.nomDuFichier$

    #Récupération du path du fichier son
    .fichierWav$= "sons\"+.fichierSon$

	#lecture des entrées
	son = Read from file: .fichierWav$

	#Paramétrage des objets (pour le pitch et le nombre de syllabes pour chaque fichier audio)
	selectObject: son
	pitch=To Pitch: 0, 75, 600

	selectObject: .txtgrid$
	.syll=2
	.nbSyll = Get number of intervals: .syll
	appendInfoLine: .txtgrid$, " nb de syll : ", .nbSyll

	#Début du traitement à proprement parlé
        #Initialisation de deux compteurs
        #Nécessaire à cause du fonctionnement des arrays dans Praat (évite d'avoir des emplacements null)
        nb_de_syllabes_avec_label=0

        appendFileLine: sortie$, "mesures du fichier", .fichierSon$

        #Parcours de 1 au nombre de syllabe du fichier 1 (considéré comme étant le fichier exemple)
        for .i from 1 to .nbSyll 

            #Traitement du fichier (.fichierSon$)
            #Récupération de l'ensemble des labels de la Tier syllabe (+ affichage dans le log des syllabes)
            selectObject: .txtgrid$
            .label$ = Get label of interval: .syll, .i
            appendInfoLine: "tour n°", .i, "label=", .label$

            #Condition pour ne pas traiter les labels vides        
            if .label$<>"_"

                #Mise à jour du compteur + array qui contient la liste des labels non-vides (on part du principe que les deux audios ont le même découpage syllabique/contiennent le même nombre de syllabes)
                nb_de_syllabes_avec_label=nb_de_syllabes_avec_label+1
                syllabes$[nb_de_syllabes_avec_label] = .label$

                #casting du nombre de syllage en string pour le concaténer dans le nom de la clé du dictionnaire de pourcentage
                .nb_de_syllabes_avec_label$=string$: nb_de_syllabes_avec_label

                #Ecriture du label en cours de traitement dans le fichier de sortie
                appendFileLine: sortie$, "label=", .label$ 

                #Récupération des données temporelles de chaque syllabe
                .tempsDebut= Get starting point: .syll, .i
                .tempsFin = Get end point: .syll, .i
                appendFileLine: sortie$, "Le segment dure ", round((.tempsFin-.tempsDebut)*1000)," ms"
                
                #Mesure du pitch aux bornes temporelles
                selectObject: pitch
                .f0_deb = Get value at time: .tempsDebut, "Hertz", "linear"
                .f0_fin = Get value at time: .tempsFin, "Hertz", "linear"
                
                #Calcul de pourcentage entre les deux mesures de f0 si les deux variables le permettent + stockage dans un array

                .key$=.nomDuFichier$+"_"+.nb_de_syllabes_avec_label$
            
                    if .f0_deb>0 and .f0_fin>0
                        .f0_pourcent=(.f0_fin-.f0_deb)/.f0_deb
                        pourcentage[.key$]=.f0_pourcent

                #si l'une des deux mesures est manquantes (easyalign ne place pas toujours les bornes exactement au début du signal, on peut donc se retrouver avec des mesures vides "--undefined--") on met une valeur par défaut (pour conserver le lien avec l'index des labels)
                    else
                        pourcentage[.key$]=666
                    endif
                #Ecriture dans la sortie
                appendFileLine: sortie$, "f0_deb= ", .f0_deb, tab$, "f0_fin= ", .f0_fin
            endif
        endfor
endproc

procedure ComparaisonF0:.fichierSon1$, .fichierSon2$
 #Une fois toutes les syllabes traitées pour les deux fichiers, on peut faire un """calcul de similarité""" entre les deux (on prend les pourcentages calculés pour les deux et on regarde si l'évolution est raccord à +-10%) + écriture dans un fichier CSV
   
    csv$="results\comparaison_pourcentage.csv"
    writeFileLine: csv$, "syllabe, pourcentage fichier 1, pourcentage fichier 2, similarité ? (y/n)"
    flagY=0
    flagN=0


    for i from 1 to nb_de_syllabes_avec_label
        
        #setup des variables dont on aura besoin pour consulter le dictionnaire

        .nomDuFichier1$= .fichierSon1$-".wav"
        .nomDuFichier2$= .fichierSon2$-".wav"    
        .compteur$=string$: i
        .key_fichier1$=.nomDuFichier1$+"_"+.compteur$
        .key_fichier2$=.nomDuFichier2$+"_"+.compteur$

        appendInfoLine: syllabes$[i]
        appendInfoLine: "pourcentage d'évolution du pitch aux bornes de la syllabe", syllabes$[i], " du fichier", .nomDuFichier1$, ":", pourcentage[.key_fichier1$]
        appendInfoLine: "pourcentage d'évolution du pitch aux bornes de la syllabe", syllabes$[i], " du fichier", .nomDuFichier2$, ":", pourcentage[.key_fichier2$]

        if pourcentage[.key_fichier2$]>pourcentage[.key_fichier1$]*0.75 and pourcentage[.key_fichier2$]<pourcentage[.key_fichier1$]*1.25
            appendFileLine: csv$, syllabes$[i],",", pourcentage[.key_fichier1$],",", pourcentage[.key_fichier2$],",", "y"
            appendInfoLine: "La syllabe :", syllabes$[i], ". Similarité d'évolution des mesures de F0 entre les deux fichiers audio."
            flagY= flagY+1
        else
            appendFileLine: csv$, syllabes$[i], ",", pourcentage[.key_fichier1$], ",", pourcentage[.key_fichier2$], ",", "n"
            appendInfoLine: "La syllabe :", syllabes$[i], ". La prosodie des deux fichiers diffère."
            flagN=flagN+1
        endif
    endfor

    #Calcul du pourcentage de similarité global entre les deux fichiers
    similarite=flagY/(flagY+flagN)
    if similarite >= 0.75
        appendInfoLine: "Les deux fichiers sont similaires à ", similarite, "%. Nos calculs sont très savants."
    else
        appendInfoLine: "La prosodie n'est pas assez similaire (", similarite, "%). Tout a été calculé. Mais je suis mauvais en maths."
    endif
endproc

# Effacer les objets chargés pour le traitement
select all
Remove

################################
#NB : certaines variables (nb de syllabes avec label, pourcentage) sont des variables globales qui passent d'une procédure à l'autre.