# Guide de Contribution

Le document suivant est un guide pour les contributions au sein du [Gitlab](https://gitlab.com/linceaerian/package-generator).   
Ce document définie un guide de règles à suivre pour une bonne gestion de projet dans Gitlab.   
Ce guide peut être amené à évoluer en fonction des sugestions faites via des merges request.


#### Table Des Matières

[Code de Conduite](#code-de-conduite)

[Que dois-je savoir avant de commencer?](#que-dois-je-savoir-avant-de-commencer)
  * [Introduction à Git et Gitlab](#introduction-à-git-et-gitlab)

[Comment contribuer?](#comment-contribuer)
  * [Soumettre des Bugs](#soumettre-des-bugs)
  * [Suggérer des Features](#suggérer-des-features)
  * [Première Contribution de code](#première-contribution-de-code)
  * [Merge Requests](#merge-requests)

[Guide de style](#guide-de-style)
  * [Git Commit Messages](#git-commit-messages)
  * [Guide de Documentation](#guide-de-documentation)

## Code de Conduite

Les contributions doivent suivre le [code conduite du Gitlab](https://gitlab.com/linceaerian/package-generator/wikis/Code-Conduite).

## Que dois-je savoir avant de commencer?

## Comment contribuer?

### Soumettre des bugs

Cette section vous guide pour la soumission d'un rapport de bug.   
Suivre ce guide aide les responsables du projet à comprendre votre problème et trouver s'il existe des problèmes rapportés en relation.   
Dans ce projet peut être trouvé un [modèle d'issue pour les bugs](.gitlab/issue_templates/Bug.md).

En plus de ce modèle, les points suivants facilitent la compréhension du problème

* **Utilise un titre clair et précis** pour l'issue identifiant le problème.
* **Décrire les étapes exactes permettant de repoduire le problème** avec le plus de détails possible. Quelle action accomplie, lors de la description, **ne pas juste expliquer ce que vous avez fait mais décrire comment vous l'avez fait**. Ex: Lors d'un déplacement du curseur, spécifié si vous l'avez déplacé avec la souris, un raccourcis clavier ou autre.
* **Donner des examples de démonstration**.
* **Décrire le comportement observé** et pointer le problème de ce comportement.
* **Expliquer le comportement attendu et pourquoi il est attendu.**
* **Inclure des captures d'écran voir des GIFs** décrivant les étapes et le problème tel qu'il est apparu. Enregistrement en GIF possible avec [cet outil](https://www.cockos.com/licecap/) sous Windows, et [celui-ci](https://github.com/colinkeenan/silentcast) ou [celui-la](https://github.com/GNOME/byzanz) sous Linux.
* **Si vous bénéficier d'un log ou d'une erreur**, inclure cette information.
* **Si le problème n'a pas été déclenché par une action spécifique**, décrire ce que vous étiez en train d'effectuer pendant que le projet a eu son problème.

Fournir plus de contexte en répondant aux question suivantes:

* **Le problème peut-il être reproduit ?**
* **Le problème est-il apparu récemment** (Ex. après une mise à jour) ou était-il déjà présent?
* Si le problème vient d'apparaitre, **Pouvez vous reproduire le problème dans une ancienne version?** Quelle est la version la plus récente où ce problème ne se produit pas.

Inclure des détails à propos de votre configuration et environment:

* **Quelle version du projet utilisez-vous?**
* **Quel est le nom et la version de l'OS que vous utilisez**

### Suggérer des features

Avant de soumettre une nouvelle fonctionnalité, merci de vérifier qu'il n'existe une proposition similaire dans la [liste des issues du projet](/../issues)   
Cette section vous guides pour la soumission d'une fonctionnalité, que ce soit une nouvelle fonctionnalité ou l'amélioration d'une fonctionnalité existante.   
Suivre ce guide permet aux responsables du projet de comprendre votre suggestion et vérifier si d'autres suggestion similaire ont été soumises.

Dans ce projet peut être trouvé un [modèle d'issue pour les features](.gitlab/issue_templates/Feature.md).

* **Utilise un titre clair et précis** pour l'issue identifiant la nouvelle fonctionnalité.
* **Fournir une description pas-à-pas de la nouvelle fonctionnalité** avec le plus de détails possible.
* **Fournir des exemples d'utilisation de la fonctionnalité**.
* **Décrire le comportement actuel** et **expliquer le comportement attendu** ainsi que pourquoi il est attendu.
* **Inclure des captures d'écran et si possible des GIFs** Aidant à démontrer les étapes ou les points auquel la suggestion fait référence. Enregistrement en GIF possible avec [cet outil](https://www.cockos.com/licecap/) sous Windows, et [celui-ci](https://github.com/colinkeenan/silentcast) ou [celui-la](https://github.com/GNOME/byzanz) sous Linux.
* **Expliquer pourquoi cette amélioration serait utile** pour la plupart des utilisateurs.
* **Lister des exemples de logiciels ou cette fonctionnalité peut être trouvée.**
* **Spécifier la version actuelle du projet utilisé.**
* **Specifier le nom et la version de l'OS utilisé.**

### Première Contribution de code

### Merge Requests

Lorsqu'une branche de feature est considérée comme terminée, il est possible de faire une Merge Request.   
Lors de la création d'une Merge Request le template [**Merge.md**](.gitlab/merge_request_templates/Merge.md) doit être utilisé.   
Il suffit alors de compléter le template.

## Guide de style

### Git Commit Messages

* Utiler le présent ("Ajout de feature" et "feature ajoutée")
* Limiter la première ligne à 72 charactères ou moins
* Consider starting the commit message with an applicable emoji:
    * :art: `:art:` Lors d'une amélioration de format/structure du code
    * :racehorse: `:racehorse:` Lors d'une amélioration de performance
    * :non-potable_water: `:non-potable_water:` Pour résoudre une fuite mémoire
    * :memo: `:memo:` Pour une écriture de documentation
    * :penguin: `:penguin:` Pour un commit pour Linux
    * :checkered_flag: `:checkered_flag:` Pour un commit pour Windows
    * :bug: `:bug:` Lor de la correction d'un bug
    * :fire: `:fire:` Lors d'une suppression de code ou files
    * :white_check_mark: `:white_check_mark:` Lors d'ajout de tests
    * :lock: `:lock:` Pour correction de sécurité
    * :arrow_up: `:arrow_up:` Pour une augmentation de dépendences
    * :arrow_down: `:arrow_down:` Pour une diminution de dépendences

### Guide de Documentation

Suivre les exemples de documentation présent dans le Wiki
