question 1 : 
Nom des lieux qui finissent par 'um'.

SELECT nom_lieu    (on sélectionne la colonne 'nom_lieu')
FROM lieu          (dans la table 'lieu')
WHERE nom_lieu LIKE '%um'


question 2 :
Nombre de personnages par lieu (trié par nombre de personnages décroissant).

SELECT lieu.nom_lieu, COUNT(personnage.id_lieu)
FROM lieu
INNER JOIN personnage ON lieu.id_lieu = personnage.id_lieu
GROUP BY personnage.id_lieu
ORDER BY COUNT(personnage.id_lieu) DESC

SELECT lieu.nom_lieu, COUNT(personnage.id_lieu)
FROM personnage
INNER JOIN lieu ON personnage.id_lieu = lieu.id_lieu
GROUP BY personnage.id_lieu
ORDER BY COUNT(personnage.id_lieu) DESC


question 3 :
Nom des personnages + spécialité + adresse et lieu d'habitation, triés par lieu puis par nom de personnage.

SELECT personnage.nom_personnage, specialite.nom_specialite, personnage.adresse_personnage, lieu.nom_lieu
FROM personnage
INNER JOIN specialite ON personnage.id_specialite = specialite.id_specialite
INNER JOIN lieu ON personnage.id_lieu = lieu.id_lieu
ORDER BY lieu.nom_lieu, personnage.nom_personnage


question 4 :
Nom des spécialités avec nombre de personnages par spécialité (trié par nombre de personnages décroissant).

SELECT specialite.nom_specialite, COUNT(personnage.id_specialite)
FROM specialite
INNER JOIN personnage ON specialite.id_specialite = personnage.id_specialite
GROUP BY (personnage.id_specialite)
ORDER BY COUNT(personnage.id_specialite) DESC


question 5 :
Nom, date et lieu des batailles, classées de la plus récente à la plus ancienne (dates affichées au format jj/mm/aaaa).

SELECT bataille.nom_bataille, DATE_FORMAT (bataille.date_bataille, "%d/%m/%Y") AS date_battle, lieu.nom_lieu
FROM bataille
INNER JOIN lieu ON bataille.id_lieu = lieu.id_lieu
ORDER BY date_bataille DESC

SELECT bataille.nom_bataille, DATE_FORMAT (bataille.date_bataille, "%d/%m/%Y") AS date_bataille, lieu.nom_lieu
FROM bataille
INNER JOIN lieu ON bataille.id_lieu = lieu.id_lieu
ORDER BY bataille.date_bataille DESC (attention à prendre bataille.date_bataille et à ne pas prendre l'alias !)


!!!! CECI EST FAUX !!!! ORDER BY a pris            DATE_FORMAT (bataille.date_bataille, "%d/%m/%Y") AS date_bataille          et non   bataille.date_bataille.
SELECT bataille.nom_bataille, DATE_FORMAT (bataille.date_bataille, "%d/%m/%Y") AS date_bataille, lieu.nom_lieu
FROM bataille
INNER JOIN lieu ON bataille.id_lieu = lieu.id_lieu
ORDER BY date_bataille DESC


question 6 :
Nom des potions + coût de réalisation de la potion (trié par coût décroissant).

SELECT potion.nom_potion, SUM(composer.qte*ingredient.cout_ingredient) AS prix_potion
FROM composer
INNER JOIN potion ON composer.id_potion = potion.id_potion
INNER JOIN ingredient ON composer.id_ingredient = ingredient.id_ingredient
GROUP BY composer.id_potion
ORDER BY prix_potion DESC


question 7 :
Nom des ingrédients + coût + quantité de chaque ingrédient qui composent la potion 'Santé'.

SELECT ingredient.nom_ingredient, ingredient.cout_ingredient, composer.qte
FROM composer
INNER JOIN potion ON composer.id_potion = potion.id_potion
INNER JOIN ingredient ON composer.id_ingredient = ingredient.id_ingredient
WHERE composer.id_potion = 3

SELECT ingredient.nom_ingredient, ingredient.cout_ingredient, composer.qte
FROM composer
INNER JOIN potion ON composer.id_potion = potion.id_potion
INNER JOIN ingredient ON composer.id_ingredient = ingredient.id_ingredient
WHERE potion.nom_potion = 'Santé'


question 8 :
Nom du ou des personnages qui ont pris le plus de casques dans la bataille 'Bataille du village gaulois'.


SELECT personnage.nom_personnage
FROM prendre_casque
INNER JOIN bataille ON prendre_casque.id_bataille = bataille.id_bataille
INNER JOIN personnage ON prendre_casque.id_personnage = personnage.id_personnage
WHERE bataille.nom_bataille = 'Bataille du village gaulois'
GROUP BY personnage.nom_personnage
HAVING SUM(prendre_casque.qte) = (
    SELECT MAX(total_qte)
    FROM (
        SELECT SUM(prendre_casque.qte) AS total_qte
        FROM prendre_casque
        INNER JOIN bataille ON prendre_casque.id_bataille = bataille.id_bataille
        WHERE bataille.nom_bataille = 'Bataille du village gaulois'
        GROUP BY prendre_casque.id_personnage
    ) AS qte_par_personnage
);



SELECT personnage.nom_personnage    (la colonne de noms qui s'ajoute à la table grâce à la jointure avec personnage)
FROM prendre_casque
INNER JOIN bataille ON prendre_casque.id_bataille = bataille.id_bataille
INNER JOIN personnage ON prendre_casque.id_personnage = personnage.id_personnage
WHERE bataille.nom_bataille = 'Bataille du village gaulois' (on ne veut que les persos qui prennent les casques à la bataille id_bataille = 1)
GROUP BY personnage.nom_personnage  (quand un perso est cité plusieurs fois, on regroupe)
HAVING SUM(prendre_casque.qte) = (          (on va ajouter une condition)
    SELECT MAX(total_qte)
    FROM (
        SELECT SUM(prendre_casque.qte) AS total_qte
        FROM prendre_casque
        INNER JOIN bataille ON prendre_casque.id_bataille = bataille.id_bataille
        WHERE bataille.nom_bataille = 'Bataille du village gaulois'
        GROUP BY prendre_casque.id_personnage
    ) AS qte_par_personnage
);



correction en suivant les consignes de Mickael :

SELECT personnage.nom_personnage    (la colonne de noms qui s'ajoute à la table grâce à la jointure avec personnage)
FROM prendre_casque
INNER JOIN bataille ON prendre_casque.id_bataille = bataille.id_bataille
INNER JOIN personnage ON prendre_casque.id_personnage = personnage.id_personnage
WHERE bataille.nom_bataille = 'Bataille du village gaulois' (on ne veut que les persos qui prennent les casques à la bataille id_bataille = 1)
GROUP BY personnage.nom_personnage  (quand un perso est cité plusieurs fois, on regroupe)
HAVING SUM(prendre_casque.qte) >= ALL              (on va ajouter une condition) 
        (
        SELECT SUM(prendre_casque.qte) AS total_qte
        FROM prendre_casque
        INNER JOIN bataille ON prendre_casque.id_bataille = bataille.id_bataille
        WHERE bataille.nom_bataille = 'Bataille du village gaulois'
        GROUP BY prendre_casque.id_personnage
    ) AS qte_par_personnage
);












en bas, c'est la valeur que doit avoir HAVING SUM(prendre_casque.qte) :
on veut qu'il soit égal au max des casques récup par un personnage (ici : 60)

 SELECT MAX(total_qte)
    FROM (
        SELECT SUM(prendre_casque.qte) AS total_qte
        FROM prendre_casque
        INNER JOIN bataille ON prendre_casque.id_bataille = bataille.id_bataille
        WHERE bataille.nom_bataille = 'Bataille du village gaulois'
        GROUP BY prendre_casque.id_personnage
    ) AS qte_par_personnage

si on met HAVING SUM(prendre_casque.qte) = 20 --> résultat : Abraracourcix
si on met HAVING SUM(prendre_casque.qte) = 21 --> résultat : Astérix
si on met HAVING SUM(prendre_casque.qte) = 60 --> résultat : Obélix
si on met HAVING SUM(prendre_casque.qte) = autre --> résultat : vide


question 9 :
Nom des personnages et leur quantité de potion bue (en les classant du plus grand buveur au plus petit).
!!!!!!!!!! pas d'espace entre SUM et (boire.dose_boire) !!!!!!!!!!

SELECT personnage.nom_personnage, SUM(boire.dose_boire) AS qte_potion_bue
FROM boire
INNER JOIN personnage ON boire.id_personnage = personnage.id_personnage
GROUP BY personnage.nom_personnage
ORDER BY SUM(boire.dose_boire) DESC

pour avoir aussi les personnages qui ne boivent pas : 
SELECT personnage.nom_personnage, SUM(boire.dose_boire) AS qte_potion_bue
FROM boire
RIGHT JOIN personnage ON boire.id_personnage = personnage.id_personnage
GROUP BY personnage.nom_personnage
ORDER BY SUM(boire.dose_boire) DESC

question 10 :
Nom de la bataille où le nombre de casques pris a été le plus important.
--> on prend comme modèle la requête de la question 8.

SELECT bataille.nom_bataille
FROM prendre_casque
INNER JOIN bataille ON prendre_casque.id_bataille = bataille.id_bataille
INNER JOIN personnage ON prendre_casque.id_personnage = personnage.id_personnage
GROUP BY bataille.nom_bataille
HAVING SUM(prendre_casque.qte) = (
    SELECT MAX(total_qte)
    FROM (
        SELECT SUM(prendre_casque.qte) AS total_qte
        FROM prendre_casque
        INNER JOIN bataille ON prendre_casque.id_bataille = bataille.id_bataille
        GROUP BY prendre_casque.id_bataille
    ) AS qte_par_bataille
);



question 11 :
Combien existe-t-il de casques de chaque type et quel est leur coût total ? (classés par nombre décroissant)
SELECT COUNT(id_casque) AS nombre_casques  (je compte sur la clé primaire pour être sûr d'éviter les doublons)
FROM casque

Faux car je n'avais pas vu la table type_casque


SELECT type_casque.nom_type_casque,
       COUNT(casque.id_casque) AS nombre_casques,
       SUM(casque.cout_casque) AS cout_total
FROM casque
INNER JOIN type_casque ON casque.id_type_casque = type_casque.id_type_casque   (pour récupérer le nom de chaque type en fonction de id_type_casque)
GROUP BY type_casque.nom_type_casque  (on groupe pour chaque id_type_casque pour obtenir le nb de casques pour chaque type et le cout de chaque type de casque)
ORDER BY nombre_casques DESC;



question 12 :
Nom des potions dont un des ingrédients est le poisson frais.

SELECT potion.nom_potion
FROM composer
INNER JOIN potion ON composer.id_potion = potion.id_potion
INNER JOIN ingredient ON composer.id_ingredient = ingredient.id_ingredient
WHERE ingredient.nom_ingredient = 'Poisson frais'


question 13 :
Nom du / des lieu(x) possédant le plus d'habitants, en dehors du village gaulois.


mauvaise méthode ! en fait, j'avais oublié la ligne 238. --> ça fonctionne après le rajout de cette ligne manquante.
on aurait eu une réponse quand même s'il existait (par un hasard) un village avec le même nb d'hab que le village gaulois.

SELECT lieu.nom_lieu
FROM personnage
INNER JOIN lieu ON personnage.id_lieu = lieu.id_lieu
WHERE lieu.nom_lieu != 'Village gaulois'
GROUP BY personnage.id_lieu
HAVING COUNT(personnage.id_lieu) = (
    SELECT MAX(total_habitants)
    FROM (
        SELECT COUNT(personnage.id_lieu) AS total_habitants
        FROM personnage
        INNER JOIN lieu ON personnage.id_lieu = lieu.id_lieu
        WHERE lieu.nom_lieu != 'Village gaulois'
        GROUP BY personnage.id_lieu
    ) AS habitants_par_lieu
);


Correction de chatGPT :

SELECT lieu.nom_lieu
FROM personnage
INNER JOIN lieu ON personnage.id_lieu = lieu.id_lieu
WHERE lieu.nom_lieu != 'Village gaulois'
GROUP BY lieu.nom_lieu
HAVING COUNT(personnage.id_personnage) = (
    SELECT MAX(nb_habitants)
    FROM (
        SELECT COUNT(personnage.id_personnage) AS nb_habitants
        FROM personnage
        INNER JOIN lieu ON personnage.id_lieu = lieu.id_lieu
        WHERE lieu.nom_lieu != 'Village gaulois'
        GROUP BY lieu.id_lieu
    ) AS habitants_par_lieu
);



question 14 :
Nom des personnages qui n'ont jamais bu aucune potion.

en tous cas 42 personnages
certains boivent plusieurs fois : 6 - 9 - 32 boivent deux fois : ils apparaiisent 2 fois et non pas une fois
                                  13 boit 4 fois, il apparait donc 4 fois et non pas une fois

 voilà pourquoi ma colonne personnage.nom_personnage compte 48 éléments.
 --> colonne personnage.nom_personnage est greffée par RIGHT JOIN et se déforme comparée à personnage.nom_personnage initiale                      

SELECT personnage.nom_personnage, boire.id_potion
FROM boire
RIGHT JOIN personnage ON boire.id_personnage = personnage.id_personnage
ORDER BY boire.id_potion  (clause pour mieux controlée en rangeant proprement)


ensuite je rajoute la clause WHERE boire.id_potion IS NULL pour ne garder que les personnages qui ne pointent vers aucune potion
pas besoin de jointure avec la table potion puisque on se fiche du nom des potions, on veut juste 'pas de potion du tout'
SELECT personnage.nom_personnage, boire.id_potion
FROM boire
RIGHT JOIN personnage ON boire.id_personnage = personnage.id_personnage
WHERE boire.id_potion IS NULL

ou alors j'applique à la lettre la technique de jointure de ma feuille de cours.
SELECT *
FROM tableA
RIGHT JOIN tableB
  ON tableA.name = tableB.name
WHERE tableA.name IS NULL

SELECT personnage.nom_personnage, boire.id_potion
FROM boire
RIGHT JOIN personnage ON boire.id_personnage = personnage.id_personnage
WHERE boire.id_personnage IS NULL

ça fonctionne également mais cela peut sembler moins intuitif parce que cela n'est pas affiché (mais ça reste logique et cohérent)


question 15 :
Nom du / des personnages qui n'ont pas le droit de boire de la potion 'Magique'.

 
SELECT personnage.nom_personnage
FROM personnage
WHERE personnage.id_personnage NOT IN (                  (NOT IN très pratique pour exclure plusieurs éléments)
    SELECT autoriser_boire.id_personnage
    FROM autoriser_boire
    INNER JOIN potion ON autoriser_boire.id_potion = potion.id_potion
    WHERE potion.nom_potion = 'Magique'
)
ORDER BY personnage.nom_personnage



oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo


modèle 1

SELECT tentative, prixRecette AS prixRecetteMax
FROM (
    SELECT recette.nomRecette AS tentative, 
           SUM(composition.quantiteIngredient * ingredient.prix_gramme_cl_unite) AS prixRecette
    FROM composition 
    INNER JOIN ingredient ON composition.idIngredient = ingredient.idIngredient
    INNER JOIN recette ON composition.idRecette = recette.idRecette
    GROUP BY composition.idRecette
) AS listePrixRecette
WHERE prixRecette = (
    SELECT MAX(prixRecette)
    FROM (
        SELECT recette.nomRecette AS tentative, SUM(composition.quantiteIngredient * ingredient.prix_gramme_cl_unite) AS prixRecette
        FROM composition 
        INNER JOIN ingredient ON composition.idIngredient = ingredient.idIngredient
        INNER JOIN recette ON composition.idRecette = recette.idRecette
        GROUP BY composition.idRecette
    ) AS maxPrixRecette (nom de la table provisoire définie entre les lignes 310 à 314 = maxPrixRecette et elle contient la colonne prixRecette)
)


modèle 2

WITH listePrixRecette AS (
    SELECT recette.nomRecette AS tentative, SUM(composition.quantiteIngredient*ingredient.prix_gramme_cl_unite) AS prixRecette
FROM composition 
INNER JOIN ingredient ON composition.idIngredient=ingredient.idIngredient
INNER JOIN recette ON composition.idRecette=recette.idRecette
GROUP BY composition.idRecette
ORDER BY SUM(composition.quantiteIngredient*ingredient.prix_gramme_cl_unite) DESC
)
SELECT tentative, prixRecette AS prixRecetteMax
FROM listePrixRecette
WHERE prixRecette = (SELECT MAX(prixRecette) FROM listePrixRecette)



MODIFICATIONS DE LA BASE DE DONNEES :


A. Ajoutez le personnage suivant : Champdeblix, agriculteur résidant à la ferme Hantassion de Rotomagus.

Rotomagus est un lieu existant, avec lieu.id_lieu = 6
Le personnage est déjà dans la table personnage, il est inutile de le rajouter. (id_personnage = 45)


B. Autorisez Bonemine à boire de la potion magique, elle est jalouse d'Iélosubmarine...

La potion magique est la potion suivante : potion.id_potion = 1 et potion.nom_potion = 'Magique'  (MAJUSCULE !)
Le personnage Bonemine : personnage.id_personnage = 12.

Dans la table autoriser_boire, la ligne (1,12) existe déjà, Bonemine a donc déjà le droit de boire de la potion magique !


C. Supprimez les casques grecs qui n'ont jamais été pris lors d'une bataille.

casque grec : 
type_casque.id_type_casque = 2
type_casque.nom_type_casque = 'Grec'

les casques appartenant à ce type de casque sont : 
Corinthien  id_casque = 3
Athénien    id_casque = 20
Spartiate   id_casque = 21
Phrygien    id_casque = 22
Hoplite     id_casque = 23

il faut arriver à supprimer les trois derniers en écrivant notre requête.


oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
DELETE table1
FROM table1
INNER JOIN table2 ON table1.cle_etrangere = table2.cle_primaire
WHERE condition;

exemple :
DELETE personnage
FROM personnage
INNER JOIN lieu ON personnage.id_lieu = lieu.id_lieu
WHERE lieu.nom_lieu = 'village romain';

la solution est donc : 
DELETE composer
FROM composer
INNER JOIN potion ON composer.id_potion = potion.id_potion
INNER JOIN ingredient ON composer.id_ingredient = ingredient.id_ingredient
WHERE (potion.nom_potion = 'Soupe' AND ingredient.nom_ingredient = 'Persil)
--> les jointures permettent de retrouver la ligne avec les bons id-potion et id_ingredient en fonction des noms donnés dans l'énoncé.
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

DELETE casque
FROM casque
INNER JOIN type_casque ON casque.id_type_casque = type_casque.id_type_casque   (pour récupérer le bon id correspond aux casques de type 'Grec')
FULL OUTER JOIN prendre_casque ON casque.id_casque = prendre_casque.id_casque
WHERE ((type_casque.nom_type_casque = 'Grec') AND (prendre_casque.id_casque IS NULL))
(chatGPT m'informe que MySQL ne prend pas en charge le FULL OUTER JOIN)

DELETE casque
FROM casque
INNER JOIN type_casque ON casque.id_type_casque = type_casque.id_type_casque   (pour récupérer le bon id correspond aux casques de type 'Grec')
LEFT JOIN prendre_casque ON casque.id_casque = prendre_casque.id_casque    (left car on veut compléter la colonne prendre_casque.id_casque avec des NULL si besoin)
WHERE ((type_casque.nom_type_casque = 'Grec') AND (prendre_casque.id_casque IS NULL))
(chatGPT m'informe que la syntaxe est correcte - je ne sais pas si le résultat est celui attendu)




























D. Modifiez l'adresse de Zérozérosix : il a été mis en prison à Condate.

Voici la syntaxe générale pour une requête UPDATE avec une jointure en SQL :
UPDATE table1
INNER JOIN table2 ON table1.cle_etrangere = table2.cle_primaire
SET table1.colonne_a_mettre_a_jour = nouvelle_valeur
WHERE condition;


UPDATE personnage 
INNER JOIN lieu ON personnage.id_lieu = lieu.id_lieu
SET personnage.adresse_personnage = 'Prison', personnage.id_lieu = (
    SELECT id_lieu
    FROM lieu
    WHERE lieu.nom_lieu = 'Condate'
)
WHERE personnage.nom_personnage = 'Zérozérosix'
--> faux car l’utilisation directe d’une sous-requête dans une clause SET n'est pas autorisée.

correction de chatGPT
UPDATE personnage
INNER JOIN lieu AS lieu_cible ON lieu_cible.nom_lieu = 'Condate'
INNER JOIN lieu ON personnage.id_lieu = lieu.id_lieu
SET personnage.adresse_personnage = 'Prison', personnage.id_lieu = lieu_cible.id_lieu
WHERE personnage.nom_personnage = 'Zérozérosix';


E. La potion 'Soupe' ne doit plus contenir de persil.

En reprenant la correction de chatGPT de la question D, je vais essayer de construire cette requête.
On fera attention à utiliser DELETE et non pas UPGRADE puisqu'on supprime une ligne, on ne met pas cette ligne à jour.
--> mauvaise méthode ! 


DELETE table1
FROM table1
INNER JOIN table2 ON table1.cle_etrangere = table2.cle_primaire
WHERE condition;

exemple :
DELETE personnage
FROM personnage
INNER JOIN lieu ON personnage.id_lieu = lieu.id_lieu
WHERE lieu.nom_lieu = 'village romain';

la solution est donc : 
DELETE composer
FROM composer
INNER JOIN potion ON composer.id_potion = potion.id_potion
INNER JOIN ingredient ON composer.id_ingredient = ingredient.id_ingredient
WHERE (potion.nom_potion = 'Soupe' AND ingredient.nom_ingredient = 'Persil)
--> les jointures permettent de retrouver la ligne avec les bons id-potion et id_ingredient en fonction des noms donnés dans l'énoncé.


F. Obélix s'est trompé : ce sont 42 casques Weisenau, et non Ostrogoths, qu'il a pris lors de la bataille 'Attaque de la banque postale'. Corrigez son erreur !
(attention, notre base de données n'est pas à jour avec cette question)

on prend comme modèle : 
UPDATE personnage
INNER JOIN lieu AS lieu_cible ON lieu_cible.nom_lieu = 'Condate'
INNER JOIN lieu ON personnage.id_lieu = lieu.id_lieu
SET personnage.adresse_personnage = 'Prison', personnage.id_lieu = lieu_cible.id_lieu
WHERE personnage.nom_personnage = 'Zérozérosix';

Dans notre base de données actuelle, dans la table prendre_casque, on a la ligne suivante :
10, 5, 2, 42  --> c'est la ligne où il faut intervenir ! 
On peut donc dire que lors de la bataille "Anniversaire d'Obélix" (id_bataille = 2),
Obélix (id_personnage = 5) a pris 42 casques (qte = 42) dont le nom est 'Weisenau' (id_casque = 10)

On voudrait que cette ligne soit transformée en :
lors de la bataille "Anniversaire d'Obélix" (id_bataille = 2),
Obélix (id_personnage = 5) a pris 42 casques (qte = 42) dont le nom est 'Ostrogoth' (id_casque = 14)
--> on ne change que l'id_casque ou le nom_casque de cette ligne.


Il faut faire comprendre sur quelle ligne intervenir et par quoi remplacer le nom du casque.
UPDATE prendre_casque 
INNER JOIN casque AS casque_cible ON casque_cible.nom_casque = 'Ostrogoth'
INNER JOIN casque ON prendre_casque.id_casque = casque.id_casque
INNER JOIN personnage ON prendre_casque.id_personnage = personnage.id_personnage
INNER JOIN bataille ON prendre_casque.id_bataille = bataille.id_bataille
SET prendre_casque.id_casque = casque_cible.id_casque
WHERE ((personnage.nom_personnage = 'Obélix') AND (bataille.nom_bataille = "Anniversaire d'Obélix") AND (qte = 42));