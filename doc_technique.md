# Documentation technique

## Vue d'ensemble

`todos` est une application mobile Flutter de gestion de tâches. Elle permet de créer, modifier, supprimer et compléter des tâches, avec gestion de sous-tâches et personnalisation de l'affichage typographique.

Le projet utilise Flutter Material 3, une API distante TinyCRUD pour la persistance principale, et `SharedPreferences` pour conserver localement l'endpoint API ainsi qu'un cache des tâches.

## Stack technique

- Framework : Flutter
- Langage : Dart `^3.11.4`
- Interface utilisateur : Material 3
- Requêtes HTTP : `http`
- Stockage local : `shared_preferences`
- Génération d'identifiants : `uuid`
- Typographie : `google_fonts`
- Qualité du code : `flutter_lints`

## Architecture du projet

Le code applicatif est organisé dans `lib/`.

- `main.dart` : point d'entrée de l'application, configuration du thème global et injection du contrôleur de police.
- `models/` : modèles métier `Todo`, `SubTask` et `FontSettings`.
- `services/` : accès API, endpoint dynamique TinyCRUD et cache local.
- `controllers/` : contrôleur d'état pour les paramètres de police.
- `pages/` : écrans principaux de l'application.

## Modèle de données

Le modèle principal est `Todo`, défini dans `lib/models/todo.dart`.

Une tâche contient :

- `id` : identifiant distant optionnel, mappé depuis `_id`.
- `title` : titre obligatoire.
- `completed` : état terminé ou non terminé.
- `subTasks` : liste de sous-tâches.

Une sous-tâche est représentée par `SubTask` et contient :

- `id`
- `title`
- `completed`

Les modèles exposent des méthodes `fromJson`, `toJson` et `copyWith`. Cela facilite les échanges avec l'API, la sérialisation locale et les mises à jour immuables dans l'interface.

## Accès aux données

`TodoService`, situé dans `lib/services/todo_service.dart`, centralise les opérations métier liées aux tâches.

Il expose les méthodes suivantes :

- `fetchAll()` : récupère toutes les tâches depuis l'API.
- `create(title)` : crée une nouvelle tâche.
- `update(todo)` : met à jour une tâche existante.
- `delete(id)` : supprime une tâche.

Après chaque opération réussie, le cache local est mis à jour. Lors du chargement initial, si le réseau échoue mais qu'un cache existe, l'application affiche les tâches mises en cache et conserve un avertissement dans `lastFetchWarning`.

## API et endpoint TinyCRUD

`EndpointStore`, situé dans `lib/services/endpoint_store.dart`, gère l'endpoint TinyCRUD utilisé par l'application.

Fonctionnement général :

- L'application crée un endpoint public via `https://tinycrud.dev/api/endpoints`.
- Le `baseUrl`, l'identifiant, la visibilité, les limites et la date d'expiration sont sauvegardés dans `SharedPreferences`.
- Si aucun endpoint n'est présent ou si l'endpoint est expiré, un nouvel endpoint est généré.
- Si une requête retourne `400` ou `404`, `TodoService` demande un rafraîchissement de l'endpoint puis rejoue la requête.

Les clés de persistance liées à l'endpoint sont centralisées dans `EndpointStore`.

## Cache local

`TodoCacheStore`, situé dans `lib/services/todo_cache_store.dart`, stocke les tâches encodées en JSON dans `SharedPreferences`.

La clé utilisée est :

- `todos_cache`

Ce cache sert principalement de solution de secours lorsque le réseau échoue pendant `fetchAll()`.

## Interface utilisateur

### Écran d'accueil

`HomePage`, dans `lib/pages/home.dart`, affiche la liste des tâches.

Fonctionnalités principales :

- chargement initial des tâches ;
- ajout d'une tâche ;
- renommage d'une tâche ;
- suppression d'une tâche ;
- changement d'état terminé ou non terminé ;
- aperçu des sous-tâches ;
- navigation vers le détail d'une tâche ;
- accès aux paramètres d'affichage.

Chaque tâche est affichée dans une carte avec une case à cocher, un titre, des actions de modification et de suppression, ainsi qu'un aperçu limité des sous-tâches.

### Écran de détail

`TodoDetailPage`, dans `lib/pages/todo_detail.dart`, permet de gérer les sous-tâches d'une tâche.

Fonctionnalités principales :

- ajout d'une sous-tâche ;
- renommage d'une sous-tâche ;
- suppression d'une sous-tâche ;
- changement d'état terminé ou non terminé ;
- affichage d'une barre de progression basée sur les sous-tâches terminées ;
- retour vers l'écran d'accueil avec la tâche mise à jour.

Les identifiants des sous-tâches sont générés localement avec `uuid`.

### Paramètres d'affichage

`SettingsPage`, dans `lib/pages/settings_page.dart`, permet de personnaliser la typographie de l'application.

Paramètres disponibles :

- famille de police ;
- graisse de police ;
- taille globale du texte ;
- aperçu typographique en temps réel.

Les changements sont appliqués immédiatement via le contrôleur de police global.

## Gestion du thème

`main.dart` configure un `MaterialApp` basé sur Material 3.

Le thème utilise :

- `ColorScheme.fromSeed` avec une couleur indigo ;
- `GoogleFonts.getTextTheme` pour appliquer la police sélectionnée ;
- `TextScaler.linear` pour appliquer l'échelle de taille globale ;
- `FontSettingsScope` pour exposer le contrôleur typographique à toutes les pages.

`FontSettingsController` étend `ChangeNotifier`. Il notifie l'interface à chaque changement de police, de graisse ou de taille.

À l'état actuel, les paramètres typographiques ne sont pas persistés. Ils sont conservés uniquement pendant la session courante.

## Gestion des erreurs

Les erreurs réseau ou API sont capturées dans les pages et affichées à l'utilisateur via des `SnackBar`.

Cas couverts :

- échec du chargement des tâches ;
- échec de création ;
- échec de mise à jour ;
- échec de suppression ;
- absence d'identifiant lors d'une mise à jour.

Le service vérifie explicitement les codes HTTP attendus et lève une exception lorsque la réponse n'est pas conforme.

## Tests

Le projet contient `test/widget_test.dart`.

Les tests actuels couvrent :

- la désérialisation de `Todo.fromJson`, notamment le mapping de `_id`, les sous-tâches et les valeurs par défaut ;
- la sérialisation de `Todo.toJson`, en vérifiant que l'identifiant géré par l'API n'est pas envoyé dans le corps des requêtes ;
- le rendu de `MyApp` lorsque le chargement réseau échoue mais qu'un cache local existe dans `SharedPreferences`.

Le test widget désactive le chargement réseau dynamique de `GoogleFonts` et initialise `SharedPreferences` avec des valeurs mockées afin de rester déterministe.
