# Documentation fonctionnelle

## Présentation du projet

`todos` est une application mobile de gestion de tâches. Elle permet à un utilisateur de créer une liste de tâches, de suivre leur avancement, de découper chaque tâche en sous-tâches et de personnaliser l'affichage de l'application.

L'application est pensée pour un usage simple et direct : l'utilisateur arrive sur une liste de tâches, ajoute ce qu'il doit faire, coche les éléments terminés, ouvre une tâche pour la détailler, puis revient à la liste avec les informations mises à jour.

## Objectifs fonctionnels

- Centraliser les tâches à réaliser dans une liste unique.
- Permettre la création, la modification, la suppression et la complétion des tâches.
- Permettre le découpage d'une tâche en sous-tâches.
- Donner une vision rapide de l'avancement grâce aux cases cochées, aux titres barrés et à la progression des sous-tâches.
- Conserver une copie locale des tâches déjà chargées pour permettre un affichage de secours si le réseau échoue.
- Permettre à l'utilisateur d'adapter la police, la graisse et la taille du texte pendant sa session.

## Utilisateur cible

L'application s'adresse à un utilisateur individuel qui souhaite gérer ses tâches personnelles ou suivre les étapes d'une activité. Il n'y a pas de notion de compte, de rôle, d'équipe ou de partage entre utilisateurs.

## Périmètre fonctionnel

### Inclus

- Consultation de la liste des tâches.
- Ajout d'une tâche.
- Renommage d'une tâche.
- Suppression d'une tâche.
- Passage d'une tâche en terminé ou non terminé.
- Consultation du détail d'une tâche.
- Ajout, renommage, suppression et complétion de sous-tâches.
- Aperçu des sous-tâches directement depuis la liste principale.
- Affichage d'une progression sur l'écran de détail.
- Rafraîchissement manuel de la liste.
- Personnalisation typographique de l'application.
- Affichage des tâches mises en cache lorsque le chargement réseau échoue et qu'un cache existe.

### Non inclus

- Authentification utilisateur.
- Synchronisation entre plusieurs comptes.
- Catégories, tags, priorités ou dates d'échéance.
- Notifications ou rappels.
- Recherche et filtres.
- Mode hors ligne complet pour créer, modifier ou supprimer des tâches.
- Persistance des préférences typographiques après fermeture de l'application.
- Confirmation avant suppression.

## Parcours utilisateur principaux

### 1. Consulter ses tâches

Au lancement, l'application charge les tâches depuis le service distant. Pendant le chargement, un indicateur d'attente est affiché.

Si des tâches existent, elles sont affichées sous forme de cartes. Chaque carte présente le titre, l'état de complétion, les actions principales et, si disponible, un aperçu des sous-tâches.

Si aucune tâche n'existe, l'application affiche un état vide invitant l'utilisateur à créer sa première tâche.

Si le chargement échoue sans cache disponible, un message d'erreur est affiché avec une action de nouvelle tentative.

### 2. Ajouter une tâche

Depuis l'écran d'accueil, l'utilisateur appuie sur le bouton `Ajouter une tâche`. Une fenêtre de saisie s'ouvre.

L'utilisateur renseigne le titre de la tâche puis valide. Si le titre est vide ou si la fenêtre est annulée, aucune tâche n'est créée.

Après création réussie, la nouvelle tâche apparaît dans la liste.

### 3. Modifier une tâche

Depuis la carte d'une tâche, l'utilisateur peut ouvrir une action de renommage. Le titre actuel est prérempli.

La modification est ignorée si l'utilisateur annule, si le nouveau titre est vide ou s'il est identique au titre existant.

Après validation réussie, la liste affiche le nouveau titre.

### 4. Terminer ou réouvrir une tâche

L'utilisateur coche une tâche pour la marquer comme terminée. Le titre est alors affiché comme terminé.

L'utilisateur peut décocher la même tâche pour la remettre dans l'état non terminé.

### 5. Supprimer une tâche

Depuis la carte d'une tâche, l'utilisateur peut supprimer la tâche. La suppression retire la tâche de la liste après succès.

L'application ne demande pas de confirmation avant suppression.

### 6. Gérer les sous-tâches

L'utilisateur ouvre une tâche en appuyant sur sa carte. L'écran de détail affiche les sous-tâches associées.

Depuis cet écran, l'utilisateur peut :

- ajouter une sous-tâche ;
- renommer une sous-tâche ;
- cocher ou décocher une sous-tâche ;
- supprimer une sous-tâche ;
- renommer la tâche principale.

Chaque changement est sauvegardé sur la tâche complète. Pendant une sauvegarde, l'écran indique qu'une opération est en cours et désactive l'ajout de sous-tâche.

Au retour vers l'écran d'accueil, la tâche modifiée est renvoyée à la liste afin d'actualiser son affichage.

### 7. Suivre l'avancement d'une tâche détaillée

Sur l'écran de détail, lorsqu'une tâche contient au moins une sous-tâche, une barre de progression est affichée.

La progression est calculée à partir du nombre de sous-tâches terminées par rapport au nombre total de sous-tâches. Le compteur est affiché au format `terminées / total`.

### 8. Personnaliser l'affichage

Depuis l'écran d'accueil, l'utilisateur accède aux paramètres d'affichage.

Il peut modifier :

- la famille de police ;
- la graisse de police ;
- la taille globale du texte.

Les changements sont appliqués immédiatement dans l'application. Une carte d'aperçu permet de visualiser le rendu typographique.

Ces paramètres sont conservés uniquement pendant la session en cours.

## Écrans de l'application

### Écran d'accueil

L'écran d'accueil est le point d'entrée de l'application. Il contient :

- une barre d'application avec le titre `Mes tâches` ;
- une action de rafraîchissement ;
- une action d'accès aux paramètres d'affichage ;
- la liste des tâches ;
- un bouton d'ajout de tâche.

Chaque tâche est affichée dans une carte avec :

- une case à cocher ;
- le titre de la tâche ;
- une action de renommage ;
- une action de suppression ;
- un aperçu des sous-tâches si la tâche en contient.

Quand une tâche contient plus de trois sous-tâches, l'accueil affiche d'abord un aperçu limité puis une action permettant d'afficher ou de masquer les sous-tâches supplémentaires.

### Écran de détail d'une tâche

L'écran de détail permet de gérer le contenu d'une tâche. Il contient :

- le titre de la tâche dans la barre d'application ;
- une action de renommage de la tâche ;
- un indicateur de sauvegarde lorsque nécessaire ;
- une barre de progression si des sous-tâches existent ;
- la liste des sous-tâches ;
- un bouton d'ajout de sous-tâche.

Chaque sous-tâche est affichée avec :

- une case à cocher ;
- le titre de la sous-tâche ;
- une action de renommage ;
- une action de suppression.

Si la tâche ne contient pas encore de sous-tâche, un état vide invite l'utilisateur à découper la tâche en étapes.

### Écran des paramètres d'affichage

L'écran des paramètres d'affichage permet de personnaliser le rendu du texte. Il contient :

- une section `Police` avec plusieurs familles disponibles ;
- une section `Graisse` avec plusieurs niveaux de graisse ;
- une section `Taille` avec les tailles `S`, `M`, `L` et `XL` ;
- une section `Aperçu` pour visualiser le résultat.

## Données fonctionnelles

### Tâche

Une tâche contient :

- un identifiant distant ;
- un titre ;
- un état terminé ou non terminé ;
- une liste de sous-tâches.

L'identifiant distant est géré par le service de persistance. Une tâche déjà créée doit disposer d'un identifiant pour pouvoir être modifiée ou supprimée.

### Sous-tâche

Une sous-tâche contient :

- un identifiant local ;
- un titre ;
- un état terminé ou non terminé.

Les sous-tâches sont enregistrées dans la tâche parente. Toute modification d'une sous-tâche entraîne donc la sauvegarde de la tâche complète.

### Paramètres d'affichage

Les paramètres d'affichage contiennent :

- la famille de police ;
- la graisse du texte ;
- l'échelle globale de taille du texte.

Ils sont appliqués globalement mais ne sont pas sauvegardés localement.

## Règles fonctionnelles

- Une tâche ou une sous-tâche ne peut pas être créée avec un titre vide.
- Un renommage est ignoré si le nouveau titre est vide.
- Un renommage est ignoré si le nouveau titre est identique au titre actuel.
- Une tâche terminée reste visible dans la liste.
- Une sous-tâche terminée reste visible dans le détail de la tâche.
- Les titres des éléments terminés sont affichés comme barrés.
- La suppression d'une tâche ou d'une sous-tâche est immédiate après action de l'utilisateur.
- L'accueil affiche au maximum trois sous-tâches par tâche avant extension manuelle.
- La progression d'une tâche détaillée est affichée uniquement si elle contient au moins une sous-tâche.
- Les opérations de création, modification et suppression nécessitent un accès au service distant.
- Le cache local est utilisé uniquement comme secours de lecture lors du chargement des tâches.
- Si le service distant devient invalide ou introuvable, l'application tente de générer un nouvel endpoint puis rejoue la requête.

## Gestion des erreurs et états particuliers

### Chargement

Pendant le chargement initial ou le rafraîchissement, l'application affiche un indicateur de progression.

### Liste vide

Si aucune tâche n'est disponible, l'application affiche un message d'état vide et invite l'utilisateur à créer une première tâche.

### Erreur réseau ou API

Si le chargement échoue et qu'aucun cache n'est disponible, l'application affiche l'erreur et propose une nouvelle tentative.

Si un cache local existe, les tâches du cache sont affichées et un message avertit l'utilisateur que les données proviennent du cache.

### Erreur lors d'une action

En cas d'échec lors d'une création, modification ou suppression, l'application affiche un message d'erreur. L'action demandée n'est pas considérée comme réussie.

## Persistance des données

Les tâches sont persistées principalement via une API distante. L'application conserve aussi localement :

- l'endpoint utilisé pour accéder à l'API ;
- des métadonnées de cet endpoint ;
- une copie cache des tâches déjà chargées.

Le cache local améliore la consultation en cas d'échec réseau, mais il ne remplace pas la persistance distante pour les actions d'écriture.

## Critères d'acceptation fonctionnels

- L'utilisateur peut afficher la liste des tâches après le lancement de l'application.
- L'utilisateur peut créer une tâche avec un titre non vide.
- L'utilisateur peut renommer une tâche existante.
- L'utilisateur peut marquer une tâche comme terminée ou non terminée.
- L'utilisateur peut supprimer une tâche.
- L'utilisateur peut ouvrir le détail d'une tâche.
- L'utilisateur peut ajouter, renommer, terminer et supprimer des sous-tâches.
- L'utilisateur voit l'avancement d'une tâche lorsque des sous-tâches existent.
- L'utilisateur retrouve sur l'accueil les modifications faites dans le détail.
- L'utilisateur peut rafraîchir manuellement la liste.
- L'utilisateur peut modifier la typographie de l'application pendant la session.
- En cas d'échec réseau avec cache disponible, l'utilisateur voit les tâches mises en cache.
- En cas d'échec réseau sans cache disponible, l'utilisateur voit une erreur et peut relancer le chargement.

## Limites connues

- Les préférences typographiques ne sont pas conservées après redémarrage.
- Les suppressions ne demandent pas de confirmation.
- L'application ne propose pas de recherche, filtrage ou tri.
- L'application ne gère pas les comptes utilisateurs.
- L'application ne permet pas de travailler complètement hors ligne.
- Les données dépendent de la disponibilité et de la validité de l'endpoint distant.
