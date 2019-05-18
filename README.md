# Projecte 3

En aquesta pràctica explicarem, com deshabilitar o eliminar el compte d'un usuari o els seus fitxers, donant l'opció de fer una còpia del seu directori.

## Ús bàsic del programa

Principalment, el nostre programa, rebrà dos paràmetres.
El primer d'ells, indicarà l'acció que voldrem fer sobre algun usuari del sistema:

-d Eliminar comptes sense deshabilitar-lo.

-r Eliminar el directori home.

-a Crear una còpia del home.

I l'altre rebrà el nom de l'usuari, al que vol aplicar les accions anteriors.

En cas que només s'introdueixi l'usuari sense cap acció, caducarà el seu compte, fent que l'usuari no pugui iniciar sessió.

##  Funcions principals del programa

### Ús bàsic programa

Funció que mostrarà com s'ha d'executar el programa.

```bash
us ()
{
  echo Utilitzacio: ./$nom_script [-dra] USUARI [NOM_USUARI]
  echo Deshabilitar un compte local de Linux
  echo "-d Elimina comptes en lloc de deshabilitar-les."
  echo "-r Elimina el directori home associat amb el(s) compte(s)."
  echo "-a Crea un fitxer del directori home associat amb els(s) comptes(s)."
}
```

### Saber si l'usuari existeix

Funció que verificarà si l'usuari existeix per realitzar les accions disponibles.

```bash
existeix (){
   usuari_trobat=FALS
   for usuaris_locals in `cat /etc/passwd | cut -d ":" -f1`
   do
     if [ $nom_usuari == $usuaris_locals ];then
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
```

### Deshabilitar usuari

Funció que deshabilitarà un compte d'un usuari.

```bash
deshabilitar ()
{
  if [ $id_usuari -ge 1000 ];then
      chage -E 0 $nom_usuari
      echo El compte $nom_usuari ha estat deshabilitat
  else
     echo El compte de $nom_usuari no ha estat deshabilitat
     echo ID: $id_usuari
  fi
}
```
La funció chage ens permetrà expirar la contrasenya de l'usuari.

### Eliminar compte

Funció que eliminarà un compte d'un usuari del sistema, mantenint el seu directori personal.

```bash
eliminar_compte ()
{
  if [ $id_usuari -ge 1000 ];then
       userdel $nom_usuari > /dev/null 2>&1
       echo El compte de $nom_usuari ha estat eliminada
   else
        echo El compte de $nom_usuari no ha estat eliminada
        echo ID: $id_usuari
  fi
}
```

### Eliminar home

Funció que elimina el directori personal d'un usuari.

```bash
eliminar_home ()
{
 if [ $id_usuari -ge 1000 ];then
      rm -r /home/$nom_usuari
      echo /home/$nom_usuari ha estat eliminat
  else
      echo /home/$nom_usuari no ha estat eliminat
      echo ID: $id_usuari
 fi
}
```

### Còpia directori

Funció que emmagatzemarà el directori home comprimit de l'usuari a la carpeta archives.

```bash
backup_directori ()
{
 mkdir archives > /dev/null 2>&1
 if [ $? -eq 0 ]; then
    echo "S'esta creant el directori archives"
 fi
   tar -czvf archives/$nom_usuari.tgz  /home/$nom_usuari > /dev/null 2>&1
   echo Creant el directori /home/$nom_usuari a archives/$nom_usuari.tgz
}
```

## Cos del programa

El primer condicional que hem de verificar, és que solament l'administrador del sistema, tindrà permisos per esborrar un determinat usuari.

Per aquest motiu, hem d'estar segurs que l'identificador no sigui diferent de 0. 

```bash
if [ $id_usuari_execucio -ne 0 ]; then
   echo "No tens permisos de root"
   exit 1
```

Si ja és el root, el primer que hem de verificar que posi almenys un paràmetre.
 
Si no es així, mostrarem a l'usuari com ha d'executar l'script.

```bash
else
   if [ $# -eq 0 ];then
    us
```

En cas contrari, si l'usuari només ha ficat un paràmetre, voldrà dir que pot haver-hi una acció, o un nom de l'usuari.

En el cas que el nom de l'usuari sigui un caràcter especial, com (-z,-p,-k, etc .. ), anirà a l'última opció del menú, d'on li mostrarem que no és un paràmetre vàlid.

```bash
else
      
        if [ $# -eq 1 ];then
           nom_usuari=$1
           parametre='-[a-zA-Z]'

            if [[ $nom_usuari != $parametre ]];then
               existeix
               deshabilitar
               sleep 1
            fi

```

Finalment, si ha ficat dos paràmetres, 
el nom de l'usuari serà el segon paràmetre, i verificarà si existeix, per fer algunes de les tres accions.

```bash

 else
    nom_usuari=$2
    existeix
 fi

```

Per al cas del menú, hem creat variables auxiliars, perquè si l'usuari vol introduir les tres accions juntes (-dra) i el nom d'un usuari.

Primer faci la còpia del home, perquè després esborri el directori, i elimini l'usuari.

```bash

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
     #Caracters especials
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
```

## Autors

* **Javier Úbeda**
* **Jefry Montalvan**

