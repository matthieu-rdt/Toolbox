#!/bin/bash

# description
# 
# 

# BUT DU SCRIPT : Connexion SSH sécurisé avec authentification par clés entre deux machines. 

#-----------------------#
#	Synopsis	#
#-----------------------#

#	Step 1
echo "Pour exécuter ce script, placez-vous dans votre $HOME"
echo "Suivre la procédure suivante :"
echo "laissez la question 1 par défaut en tapant entrée"
echo "Question 1 : Enter file in which to save the key ("$HOME"/.ssh/id_rsa.pub)"
echo "question 2 : Entrer un passphrase ( assez longue), puis tapez entrée"

if [ $(pwd) != $HOME ] ; then
	exit 1
fi

#	Step 2
# Création du dossier .ssh qui sera créé dans /home/<user>.
# les fichiers des private key, public key et known host y seront stockées.
mkdir .ssh && cd .ssh/

# Etape 3
# Creation d'une passphrase sécurisée

passphrase=""
while [ "$passphrase" != "oui" ] && [ "$passphrase" != "non" ] ; do
        echo "veuillez écrire oui ou non"
        read passphrase
done

read -p "générer une passphrase avec 128 bits d'entropie ? [oui/non] " passphrase # mesure de la robustesse d'un mot de passe

if [ $passphrase != 'oui' ] && [ $passphrase != 'non' ]
then
	echo "veuillez écrire oui ou non"
fi

if [ $passphrase == oui ]
then
	echo "copier/coller le dans votre gestionnaire de mot de passe :"
	passwd=`dd if=/dev/urandom bs=16 count=1 2>/dev/null | base64 | sed 's/=//g'`
	echo $passwd
else
	echo "avec 256 bits alors ?"
fi

read -p "générer une passphrase avec 256 bits d'entropie ? [oui/non]" passphrase # mesure de la robustesse d'un mot de passe

if [ $passphrase == oui ]
then
	echo "copier/coller le dans votre gestionnaire de mot de passe :"
	passwd=`dd if=/dev/urandom bs=32 count=1 2>/dev/null | sha256sum -b | sed 's/ .*//'`
	echo $passwd
else
	echo "pas de passphrase alors ?"
fi

# Etape 4
# Génération d'une paire de clés publique/privée
# algorithmes de chiffrement
a='rsa'
b='ecdsa'
c='ed25519'

echo "Liste des algorithmes sécurisés de clés publiques :"
echo ""
echo "RSA # éprouvé et conseillé avec une taille de clé de 4096 bits. Compatible partout."
echo "ECDSA # conseillé par l’ANSSI mais a priori n’a pas la confiance de tout le monde"
echo "ED25519 # le dernier arrivé et le meilleur en termes de sécu et de performance."

read -p 'choisissez a, b ou c :' algo
read -p 'donnez un nom à votre ssh key :' keyname # donner un nom de fichier a votre cle

echo "###################################################"
echo "RAPPEL de votre passphrase : $passwd"
echo "###################################################"

if [ $algo == a ] # si c'est rsa => a
	then 
		ssh-keygen -b 4096 -f $keyname # par défaut donc pas besoin de "-type"
fi

if [ $algo == b ] # si c'est ecdsa => b
	then
		ssh-keygen -t $b -b 512 -f $keyname
fi

if [ $algo == c ] # si c'est ed25519 => c 
	then 
		ssh-keygen -t $c -f $keyname
fi

# Etape 3
# On demande le login et l'adresse IP du serveur avec qui on veut une connexion SSH 
# par authentification de clés. Pour cela, il doivents remplir le champ vide
echo "Tapez l'adresse du serveur distant sous cette forme : (exple: 192.168.0.20 "
read adresse

echo "Tapez le login du serveur distant - c'est l'utilisateur du serveur :"
read login

# Vérification des données entrées par le client
echo "votre login et adresse ip sont : $login@$adresse "

# Etape 4
# On Envoi la clé publique au serveur souhaité
ssh-copy-id -i $HOME/.ssh/id_rsa.pub $login@$adresse

# Etape 4
# Mise en place de l'agent ssh pour éviter de taper un passphrase à chaque fois
ssh-add


echo "Veuillez-vous connecter maintenant au serveur avec votre login et adresse ip du serveur"
echo "sous la forme : login@ip-adress" 
