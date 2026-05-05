# TalTech Marketplace — Prototüüp (Müüja töökoht)

Lühike projektiprotoüüp kursusele Andmebaasid I (ITI0206). See repo sisaldab lihtsat full-stack prototüüpi, mis keskendub ainult müüja töökojale (kuulutuste haldus).

**Scope**
- Näitab, et müüja saab: vaadata oma kuulutusi, lisada kuulutuse, muuta kuulutust, vaadata detaili ja muuta staatust.
- EI sisalda ostja UI-d, autentimist, piltide üleslaadimist, vestlussüsteemi, pakkumisi ega order-flow'd.

**Struktuur**
- `backend/` — Node.js + Express + TypeScript, REST API, `pg` PostgreSQL kliendiga.
- `frontend/` — React + Vite + TypeScript, lihtne UI müüja töökoha jaoks.

## Kiire käivitamine

Märkus: sinu andmebaasis on demoandmed juba olemas (seedimine ei ole vajalik). Juhised seedimiseks on olemas, kuid ära jooksuta seda, kui andmed on juba olemas.

1) Backend

```bash
cd prototype/backend
npm install
# täida .env (või kopeeri .env.example -> .env)
# lisa oma DB parool ja veendu, et DEMO_SELLER_ID on seadistatud
# example: DEMO_SELLER_ID=aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa
npm run dev
```

2) Frontend

```bash
cd prototype/frontend
npm install
# kontrolli .env (koos VITE_API_URL, vaikimisi http://localhost:3001)
npm run dev
```

3) Ava brauseris
- Frontend: http://localhost:5173
- Backend health: http://localhost:3001/api/health

## .env muutujad

- Backend (`backend/.env` või `backend/.env.example`):
  - `PORT` (vaikimisi 3001)
  - `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`
  - `DEMO_SELLER_ID` — demo müüja UUID (seed-failis kasutatud `aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa`). Kui see on placeholder, API `/api/listings` võib tagastada 500 või mitte leida kirjeid.
  - `CORS_ORIGIN` (frontend host, vaikimisi `http://localhost:5173`)

- Frontend (`frontend/.env`):
  - `VITE_API_URL` (näiteks `http://localhost:3001`)

## Kuidas kontrollida, et funktsionaalsus töötab

- Vaata teenuseid: ava `http://localhost:3001/api/health`.
- Vaata kategooriaid: `GET /api/categories`.
- Vaata seisundeid: `GET /api/listing-conditions`.
- Vaata demo müüja kuulutusi: `GET /api/listings` (näitab ainult `DEMO_SELLER_ID` kuulutusi).

Frontendil on järgmised vaated:
- Minu kuulutused — list ja toimingud (vaata, muuda, muuda staatust)
- Lisa kuulutus — vorm, mis POSTib `/api/listings` (salvestub `draft` staatuses)
- Muuda kuulutust — PUT `/api/listings/:id`
- Kuulutuse detail — GET `/api/listings/:id`
- Muuda staatust — PATCH `/api/listings/:id/status`

## Seed (ainult kui vajad)
- Seedimine lisab demo profiili ja mõned näidis-kuulutused (`backend/sql/seed_demo_data.sql`).
- Kui sinu DB on juba seeditud, ÄRA käivita seda uuesti vajaolutuseta.
- Kui siiski vaja, käivita:
```bash
cd prototype/backend
npm run seed
```

## Vead ja tõrkeotsing
- Kui `/api/listings` tagastab 500: kontrolli `backend/.env` ja veendu, et `DEMO_SELLER_ID` ei ole placeholder ning DB parool on korrektne.
- FK-vead tekivad, kui `DEMO_SELLER_ID` viitab profiilile, mida andmebaasis ei ole. Veendu, et profiil `aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa` on tabelis `profiles`.

## Mida ma lisasin (lühike kokkuvõte tehtust)
- Backend: listings API (GET/POST/PUT/PATCH), validation, mappers.
- Frontend: API klient, tüübid, vaated ja komponendid (dashboard, create, edit, detail, status change).

Kui tahad, teen nüüd ühte järgmistest: viimistleda README-i, parandada veateated backendis, lisada väiksemaid stiilimuudatusi frontendis või lisada täpsemaid testikäske. Mille alustan?

---
Projekti juures olevad olulised failid:
- `backend/src` — serveri lähtekood
- `backend/sql/seed_demo_data.sql` — demoandmed
- `frontend/src` — React frontend
