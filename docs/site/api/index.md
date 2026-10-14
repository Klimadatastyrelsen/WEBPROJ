---
title: WEBPROJ
description: Transformér koordinater mellem koordinatsystemerne i Danmark og Grønland.
order: 0
---

WEBPROJ transformerer 2D-, 3D- og 4D-koordinater mellem de koordinatsystemer (CRS), der bruges i Danmark og Grønland. Det kører som en del af [Dataforsyningen](https://dataforsyningen.dk).

## Adgang

WEBPROJ bruger Dataforsyningens brugeradgang, som de andre tjenester. Du skal have et token fra Dataforsyningen. Brugere af Dataforsyningen laver et, når de er logget ind på deres konto. Send det som query-parameteren `token` eller i en `token`-header. [Dataforsyningens vilkår](https://dataforsyningen.dk/Vilkaar) gælder.

## Endpoints

Versionen er en del af stien. `v1.0`, `v1.1` og `v1.2` er alle tilgængelige. Brug den nyeste, `v1.2`.

| Endpoint | Hvad det gør |
|---|---|
| `GET /v1.2/crs/` | De tilgængelige CRS, grupperet efter `DK`, `GL` og `Global` |
| `GET /v1.2/crs/{crs}` | Information om ét CRS |
| `GET /v1.2/trans/{src}/{dst}/{v}` | Transformér en 2D-koordinat fra `src` til `dst`. `v` er `v1,v2` |
| `GET /v1.2/trans/{src}/{dst}/{v1},{v2},{v3}` | Transformér en 3D-koordinat |
| `GET /v1.2/trans/{src}/{dst}/{v1},{v2},{v3},{v4}` | Transformér en 4D-koordinat |
| `GET /v1.2/info/` | Versionerne af WEBPROJ og PROJ |

De ældre versioner har de samme endpoints, undtagen `/info/`. De er kun forskellige i svaret fra `/crs/{crs}`: `v1.1` tilføjer `srid`, `area_of_use` og `bounding_box`, og `v1.2` tilføjer enhederne `v1_unit` til `v4_unit`.

## Transformér en koordinat

```sh
curl "$WEBPROJ/v1.2/trans/EPSG:4258/DK:S34S/55.0,12.0?token=$TOKEN"
```

```json
{"v1":106020.6670140382,"v2":64281.27481858295,"v3":null,"v4":null}
```

Svaret har altid `v1` til `v4`. De værdier, inputtet ikke havde, er `null`.

## Fejl

Fejl har årsagen i `detail`. Et ukendt CRS giver `400`, og det samme gør en transformation mellem CRS fra to forskellige lande. En koordinat, der ikke kan transformeres, fx fordi den ligger uden for CRS'ets anvendelsesområde, giver `404`.
