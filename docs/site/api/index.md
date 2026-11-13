---
title: WEBPROJ
description: Transformér koordinater mellem de koordinatsystemer, der bruges i Danmark og Grønland.
order: 0
---

WEBPROJ transformerer 2D-, 3D- og 4D-koordinater mellem de koordinatsystemer (CRS), der bruges i Danmark og Grønland. Tjenesten udstilles via [Dataforsyningen](https://dataforsyningen.dk).

## Adgang

Til adgang benyttes Dataforsyningens brugeradgang som ved andre tjenester. Du skal bruge en token, som du opretter, når du er logget ind på Dataforsyningen. Send den som query-parameteren `token` eller i headeren `token`. Brug af WEBPROJ er underlagt [Dataforsyningens vilkår](https://dataforsyningen.dk/Vilkaar).

## Endpoints

API-versionen angives i stien. `v1.0`, `v1.1` og `v1.2` er alle tilgængelige, og vi anbefaler den nyeste, `v1.2`.

| Endpoint | Beskrivelse |
|---|---|
| `GET /v1.2/crs/` | De tilgængelige CRS, grupperet efter `DK`, `GL` og `Global` |
| `GET /v1.2/crs/{crs}` | Information om ét CRS |
| `GET /v1.2/trans/{src}/{dst}/{v}` | Transformér en 2D-koordinat fra `src` til `dst`. `v` angives som `v1,v2` |
| `GET /v1.2/trans/{src}/{dst}/{v1},{v2},{v3}` | Transformér en 3D-koordinat |
| `GET /v1.2/trans/{src}/{dst}/{v1},{v2},{v3},{v4}` | Transformér en 4D-koordinat |
| `GET /v1.2/info/` | Versionerne af WEBPROJ og PROJ |

De ældre versioner har de samme endpoints, bortset fra `/info/`, og adskiller sig kun i svaret fra `/crs/{crs}`: `v1.1` tilføjer `srid`, `area_of_use` og `bounding_box`, og `v1.2` tilføjer enhederne `v1_unit` til `v4_unit`.

## Transformér en koordinat

```sh
curl "$WEBPROJ/v1.2/trans/EPSG:4258/DK:S34S/55.0,12.0?token=$TOKEN"
```

```json
{"v1":106020.6670140382,"v2":64281.27481858295,"v3":null,"v4":null}
```

Svaret indeholder altid `v1` til `v4`. Værdier, der ikke var med i inputtet, er `null`.

## Fejl

Ved fejl står årsagen i feltet `detail`. Et ukendt CRS giver `400`, og det samme gør en transformation mellem et dansk og et grønlandsk CRS. En koordinat, der ikke kan transformeres, fx fordi den ligger uden for CRS'ets anvendelsesområde, giver `404`.
