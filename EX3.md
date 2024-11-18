# Q.3.1 Quel est le matériel réseau A ?
il s'agit d'un switch
## Quel est son rôle sur ce schéma vis-à-vis des ordinateurs ?
il sert à interconnecter les 5 PCs entre eux et à les connecter également au routeur et ce dernier est connecté au switch pour permettre aux ordinateurs de communiquer avec Internet ou d'autres réseaux extérieurs.
# Q.3.2 Quel est le matériel réseau B ?
un routeur
Quel est son rôle pour le réseau 10.10.0.0/16 ?
Le routeur permet aux PC du réseau 10.10.0.0/16 d’accéder à des réseaux externes, comme Internet.  Pour toute communication avec des appareils en dehors de 10.10.0.0/16 (par exemple, accéder à un site Web sur Internet), le routeur est nécessaire pour acheminer les données.

# Q.3.3 Que signifie f0/0 et g1/0 sur l’élément B ?
interfaces réseau sur le routeur B.
f0/0 signifie FastEthernet 0/0
g1/0 signifie GigabitEthernet 1/0.
# Q.3.4 Pour l'ordinateur PC2, que représente /16 dans son adresse IP ?
masque de sous-réseau.Cela signifie que les 16 premiers bits de l'adresse IP sont réservés pour identifier le réseau, et le reste (les 16 derniers bits) est utilisé pour identifier l'hôte dans ce réseau

# Q.3.5 Pour ce même ordinateur, que représente l'adresse 10.10.255.254 ?
10.10.255.254 est l'une des dernières adresses utilisables dans ce réseau, juste avant l'adresse de diffusion (broadcast)
# Q.3.6 Pour les ordinateur PC1, PC2, et PC5 donne :

###### PC1 (10.10.4.1/16) :
Adresse de réseau : 10.10.0.0
Première adresse disponible : 10.10.0.1
Dernière adresse disponible : 10.10.255.254
Adresse de diffusion : 10.10.255.255
###### PC2 (10.11.80.2/16) :
Adresse de réseau : 10.11.0.0
Première adresse disponible : 10.11.0.1
Dernière adresse disponible : 10.11.255.254
Adresse de diffusion : 10.11.255.255
###### PC5 (10.10.4.7/15) :
Adresse de réseau : 10.10.0.0
Première adresse disponible : 10.10.0.1
Dernière adresse disponible : 10.11.255.254
Adresse de diffusion : 10.11.255.255

# Q.3.7 En t'aidant des informations que tu as fourni à la question 3.6, et à l'aide de tes connaissances, indique parmi tous les ordinateurs du schéma, lesquels vont pouvoir communiquer entre-eux.

PC1, PC3, PC4 et PC5 peuvent tous communiquer entre eux car ces ordinateurs sont dans les memes sous-réseaux (10.10.0.0/16 et 10.10.0.0/15)

PC2 (10.11.80.2/16) ne peut pas communiquer directement avec PC1, PC3, PC4 ou PC5 car il se trouve dans un réseau différent (10.11.0.0/16). Il appartient à un réseau distinct, et donc, pour communiquer avec les autres ordinateurs (qui sont dans le réseau 10.10.0.0/16 ou 10.10.0.0/15), il doit passer par un routeur.
# Q.3.8 De même, indique ceux qui vont pouvoir atteindre le réseau 172.16.5.0/24.

PC1, PC3, PC4, PC5 (dans 10.10.0.0/16) peuvent atteindre 172.16.5.0/24.
PC2 (dans 10.11.80.0/16) ne peut pas atteindre 172.16.5.0/24.

# Q.3.9 Quel incidence y-a-t'il pour les ordinateurs PC2 et PC3 si on interverti leur ports de connexion sur le matériel A ?
Aucun effet sur la communication entre eux (sous-réseaux différents)
# Q.3.10 On souhaite mettre la configuration IP des ordinateurs en dynamique. Quelles sont les modifications possible ?
Configurer les ordinateurs pour obtenir une adresse IP via DHCP (à savoir, modifier les paramètres réseau pour obtenir une adresse IP automatiquement)
Configurer un serveur DHCP sur le réseau (il faut qu'un serveur DHCP soit configuré pour distribuer des adresses IP aux ordinateurs du réseau (via un routeur ou un serveur dédié)

# Analyse de trames
## Fichier 1 :

### Q.3.11 Sur le paquet N°5, quelle est l'adresse mac du matériel qui initialise la communication ? Déduis-en le nom du matériel.
  00:50:79:66:68:00
 le fabricant est Private (l'OUI 00:50:79)


### Q.3.12 Est-ce que la communication enregistrée dans cette capture a réussi ? Si oui, indique entre quels matériel, si non indique pourquoi cela n'a pas fonctionné.
Oui car on a une réponse ICMP Echo (Reply)

### Q.3.13 Dans cette capture, à quel matériel correspond le request et le reply ? Donne le nom, l'adresse IP, et l'adresse mac de chaque materiel.
Matériel qui envoie la requête (request) :

Nom du matériel : Private (fabricant identifié par l'OUI 00:50:79).
Adresse IP : 10.10.4.1.
Adresse MAC : 00:50:79:66:68:00.
Matériel qui répond à la requête (reply) :

Nom du matériel : Private (fabricant identifié par l'OUI 00:50:79).
Adresse IP : 10.10.4.2.
Adresse MAC : 00:50:79:66:68:03.

### Q.3.14 Dans le paquet N°2, quel est le protocole encapsulé ? Quel est son rôle ?
ARP qui peut résoudre une adresse IP en adresse MAC

### Q.3.15 Quels ont été les rôles des matériels A et B dans cette communication ?
le Switch est de transmettre la requête ARP sur le réseau local à tous les appareils (broadcast). Il relaye aussi la réponse ARP de l'appareil cible vers l'émetteur de la requête
Le routeur ne joue pas un rôle direct dans la communication ARP s'il s'agit d'une requête et réponse ARP sur le même réseau local. Son rôle serait plutôt de gérer le routage des paquets entre différents sous-réseaux, mais dans ce cas spécifique, il est probablement translucide pour la communication ARP.
### Fichier 2 :

#### Q.3.16 Dans cette trame, qui initialise la communication ? Donne l'adresse IP ainsi que le nom du matériel.
Adresse IP de la machine qui initialise la communication : 10.10.80.3.
Nom du matériel : Private_66:68:02 (selon l'adresse MAC 00:50:79:66:68:02).
#### Q.3.17 Quel est le protocole encapsulé ? Quel est son rôle ?
Protocole encapsulé : ICMP qui peut tester la connectivité et envoyer des messages d'erreur ou de contrôle dans un réseau IP.

#### Q.3.18 Est-ce que cette communication a réussi ? Si oui, indique entre quels matériel, si non indique pourquoi cela n'a pas fonctionné.
no car il n'y a pas de réponse
#### Q.3.19 Explique la ligne du paquet N° 2
Le paquet N°2 contient une trame Ethernet II qui encapsule un paquet IPv4 avec un protocole ICMP. Le paquet ICMP est envoyé de l'adresse IP 10.10.255.254  à l'adresse IP 10.10.80.3. Le rôle d'ICMP est de tester la connectivité ou de signaler un message de contrôle, comme un ping ou une erreur de réseau.
#### Q.3.20 Quels ont été les rôles des matériels A et B ?
le switch s'occupe de la transmission locale des trames Ethernet, tandis que le routeur  est responsable de l'acheminement des paquets ICMP à travers différents réseaux ou sous-réseaux.

### Fichier 3 :

####  Q.3.21 Dans cette trame, donne les noms et les adresses IP des matériels sources et destination.
*Matériel source* 
Adresse IP : 10.10.4.2
Nom du matériel : selon l'adresse IP, cela pourrait être un ordinateur ou un dispositif sur le réseau local de l'adresse 10.10.4.0/24).
*Matériel destination*
Adresse IP : 172.16.5.253
Nom du matériel : il s'agit d'un appareil dans un autre réseau, probablement un serveur ou un routeur dans le sous-réseau 172.16.5.0/24

#### Q.3.22 Quelles sont les adresses mac source et destination ? Qu'en déduis-tu ?
Adresse MAC source : ca:01:da:d2:00:1c
Adresse MAC destination : ca:03:9e:ef:00:38 

####  Q.3.23 A quel emplacement du réseau a été enregistré cette communication ?

La communication a probablement été enregistrée sur un équipement réseau de bordure, tel qu'un switch ou un routeur, au niveau du réseau local 10.10.4.0/24 avant que le paquet ne soit routé vers le réseau 172.16.5.0/24. Cela signifie que l'enregistrement de la communication a eu lieu dans le réseau local de l'adresse source (10.10.4.0/24) ou dans un dispositif réseau qui se situe entre ces deux sous-réseaux.

