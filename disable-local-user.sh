#!/bin/bash

#Javi Ubeda i Jefry Montalvan

#Variables
nom_script=$0
id_usuari_execucio=`id -u`
CERT=1
FALS=0

#Funcio que mostrara l'us bàsic del programa quan no rebi parametres o quan el parametre sigui diferent a (d,r,a)
us (){
  echo Utilitzacio: ./$nom_script [-dra] USUARI [NOM_USUARI]
  echo Deshabilitar un compte local de Linux
  echo "-d Elimina comptes en lloc de deshabilitar-les."
  echo "-r Elimina el directori home associat amb el(s) compte(s)."
  echo "-a Crea un fitxer del directori home associat amb els(s) comptes(s)."
}

#Funcio que verificara si l'usuari existeix per deshabilitar, eliminar (compte / home), o fer la copia del home
existeix (){
   usuari_trobat=FALS
   for usuaris_locals in `cat /etc/passwd | cut -d ":" -f1`
   do
     if [[ $nom_usuari == $usuaris_locals ]];then
        usuari_trobat=CERT
     fi
   done

    if [[ $usuari_trobat == "CERT" ]];then
	id_usuari=`id -u $nom_usuari`
    else
	echo $nom_usuari no existeix
	exit 1
   fi
}

#Funcio que deshabilitara un compte d'un usuari quan el seu identificador sigui major o igual que 1000
deshabilitar (){
  if [ $id_usuari -ge 1000 ];then
      chage -E 0 $nom_usuari
      echo El compte $nom_usuari ha estat deshabilitat
  else
     echo El compte de $nom_usuari no ha estat deshabilitat
     echo ID: $id_usuari
  fi
}

#Funcio que eliminara un compte d'un usuari del sistema, mantenint el seu directori personal, quan el seu id sigui major o igual de 1000
eliminar_compte (){
  if [ $id_usuari -ge 1000 ];then
       userdel $nom_usuari > /dev/null 2>&1
       echo El compte de $nom_usuari ha estat eliminada
    else
        echo El compte de $nom_usuari no ha estat eliminada
	echo ID: $id_usuari
  fi
}

#Funcio que elimina el directori personal de l'usuari, quan el seu id sigui major o igual de 1000
eliminar_home (){
 if [ $id_usuari -ge 1000 ];then
     rm -r /home/$nom_usuari
     echo /home/$nom_usuari ha estat eliminat
  else
     echo /home/$nom_usuari no ha estat eliminat
     echo ID: $id_usuari
 fi
}

#Funcio que creara directoris home comprimits a la carpeta archives de l'usuari rebut per parametre
backup_directori (){
 mkdir archives > /dev/null 2>&1
 if [ $? -eq 0 ]; then
    echo "S'esta creant el directori archives"
 fi
   tar -czvf archives/$nom_usuari.tgz  /home/$nom_usuari > /dev/null 2>&1
   echo Creant el directori /home/$nom_usuari a archives/$nom_usuari.tgz
}

#Quan l'script sigui executat per un usuari que no te permisos de root, no podra interactuar amb el programa
 if [ $id_usuari_execucio -ne 0 ]; then
   echo "No tens permisos de root"
   exit 1

 else
   #Si no hi ha cap parametre, li direm a l'usuari el seu us bàsic
   if [ $# -eq 0 ];then
    us
    else
	#Si s'ha introduit tant sols un parametre, voldra dir que el usuari es trobara en el primer parametre
	if [ $# -eq 1 ];then
	   nom_usuari=$1
	   parametre='-[a-zA-Z]'

	  #En el cas que en el primer parametre no s'hagi guardat un caracter especial (-z),
	  #verificara si existeix, i en cas afirmatiu deshabilitara el compte de l'usuari
	    if [[ $nom_usuari != $parametre ]];then
	       existeix
	       deshabilitar
	       sleep 1
            fi

	 #Si s'ha introduit dos parametres, voldra dir que el usuari es trobara en el segon parametre
	 else
	   nom_usuari=$2
	   existeix
	fi
       	   while getopts "dra" PARAMETRE
       	    do
             case ${PARAMETRE} in
		#Cas eliminar compte
                d)
		  COMPTE_ELIMINADA=CERT
                ;;
		#Cas eliminar home
               	r)
		  HOME_ESBORRAT=CERT
                ;;
		 #Cas copia home
                a)
		  COPIA_HOME=CERT
                ;;
		#Cas caracters especials
               	?)
                  us
		;;
             esac
          done

	if [[ $COPIA_HOME == "CERT" ]];then
	    backup_directori
            sleep 2
	fi

	if [[ $HOME_ESBORRAT == "CERT" ]];then
	     eliminar_home
	     sleep 2
        fi

 	if [[ $COMPTE_ELIMINADA == "CERT" ]];then
	    eliminar_compte
            sleep 2
	fi
    fi
fi

