## Tekijä: Kai Katajisto TITE23 - Ohjelmistotuotannon Jatkokurssi
Feat. Hanna Tammela TITE22

# Item Database Application

Tämä on Ohjelmistotuotannon jatkokurssin harjoitustyö. Sovellus on Spring Boot -pohjainen järjestelmä tuotetietojen hallintaan. Projekti demonstroi ohjelmistokehitystä, jossa yhdistyvät REST-arkkitehtuuri, tietokantojen hallinta, kontitus Dockerilla sekä täysin automatisoitu CI/CD-putki.

## Sisällysluettelo

1. [Yleiskuvaus](#yleiskuvaus)
2. [Arkkitehtuuri](#arkkitehtuuri)
3. [Teknologiat](#teknologiat)
4. [Konfiguraatio ja profiilit](#konfiguraatio-ja-profiilit)
5. [Paikallinen kehitys](#paikallinen-kehitys)
6. [Testaus](#testaus)
7. [CI/CD-putki](#ci-cd-putki)
8. [Tuotantoympäristö](#tuotantoympäristö)

---

## Yleiskuvaus

Sovelluksen yksinkertaisen käyttöliittymän avulla käyttäjät voivat lisätä ja tarkastella tuotteita selaimen kautta. Sovellus on suunniteltu stateless-periaatteella, jossa tila säilytetään ulkoisessa tietokannassa.

http://195.148.20.136/  # HUOM. CSC-palvelin kaatuu 23.2.2026.

Järjestelmän keskeinen ominaisuus on automaatio: koodimuutokset siirtyvät versionhallinnasta tuotantopalvelimelle automaattisesti testauksen ja Docker-imagetuksen kautta.

## Arkkitehtuuri

Sovellus noudattaa kerrosarkkitehtuuria:

* **Käyttöliittymä:** Palvelinpuolen renderöinti (Server-Side Rendering) Thymeleaf-moottorilla.
* **Controller:** Spring MVC -kontrollerit käsittelevät HTTP-pyynnöt ja ohjaavat liikenteen oikeisiin näkymiin.
* **Data:** Spring Data JPA abstrahoi tietokantakutsut.
* **Infrastruktuuri:** Sovellus ja tietokanta ajetaan eristetyissä Docker-konteissa, jotka kommunikoivat keskenään Dockerin sisäisessä verkossa.

## Teknologiat

Projektissa käytetyt keskeiset teknologiat ja versiot:

* **Ohjelmointikieli:** Java 11
* **Sovelluskehys:** Spring Boot 2.1.3
* **Automaatio:** Maven 3.9.8
* **Kontitus:** Docker & Docker Compose
* **Tietokanta (Tuotanto):** PostgreSQL 17
* **Tietokanta (Testaus):** H2 In-Memory Database
* **CI/CD:** GitHub Actions
* **Palvelin:** Ubuntu Server (CSC cPouta)

## Konfiguraatio ja profiilit

Sovellus hyödyntää Spring Bootin profiileja ympäristöjen eriyttämiseen. Tämä varmistaa, että testidata ei sekoitu tuotantodataan. Tosin nämä ovat hyvin "barebones" ja ymmärrys niistä on rajoitettu.

### Default-profiili (Tuotanto ja Docker)
* **Asetustiedosto:** `application.properties`
* **Käyttötarkoitus:** Sovelluksen normaali ajo Docker-ympäristössä.
* **Tietokanta:** Yhdistää PostgreSQL-kantaan.
* **Datan pysyvyys:** Hibernate on asetettu tilaan `update`, jolloin listaa ei poisteta käynnistyksen yhteydessä.

### Test-profiili (Automaattitestit)
* **Asetustiedosto:** `src/test/resources/application-test.properties`
* **Käyttötarkoitus:** Yksikkö- ja integraatiotestit.
* **Tietokanta:** Käyttää muistinvaraista H2-kantaa.
* **Datan pysyvyys:** Hibernate on asetettu tilaan `create-drop`, jolloin tietokanta tyhjennetään testien jälkeen.

## Paikallinen kehitys

Sovelluksen voi käynnistää paikallisesti Docker Composen avulla. Tämä ei vaadi Java- tai Maven-asennusta työasemalle, ainoastaan Docker Desktopin.

### Käynnistysohjeet

1. Kloonaa projektin repositorio:
   ```bash
   git clone https://github.com/KaiKatajisto/item-database
   ```

2. Siirry projektin juurihakemistoon ja käynnistä ympäristö:
   ```bash
   docker compose up --build
   ```

3. Sovellus on käytettävissä selaimessa osoitteessa `http://localhost:8080` (tai portissa 80, riippuen docker-compose.yml -määrityksistä).

4. Sammuta ympäristö komennolla:
   ```bash
   docker compose down
   ```

## Testaus

Projektin laadunvarmistus perustuu automaattisiin testeihin.

**Suoritus:** Testit ajetaan Mavenilla komennolla `mvn test`.

**Teknologiat:** JUnit testien suoritukseen ja FluentLenium käyttöliittymätestaukseen.

**Eristäminen:** `@ActiveProfiles("test")` -annotaatio varmistaa, että testit käyttävät väliaikaista H2-tietokantaa.

**Poisluku:** Yksikkötestit tietynlaiselle sovellukselle poistettu `@Ignore` -annotaatiolla, kaatumisen estämiseksi.

## CI/CD-putki

Jatkuva integraatio ja toimitus (CI/CD) on toteutettu GitHub Actions -työnkululla. Prosessi käynnistyy automaattisesti, kun koodia työnnetään main-haaraan. Putki etenee seuraavasti:

### Build & Test

GitHub Actions pystyttää Java-ympäristön ja suorittaa yksikkötestit. Jos testit epäonnistuvat, prosessi keskeytyy välittömästi. ItemDatabaseTest.javan yksikkötestaus vaatimukset ovat varustettu @Ignore -annotaatiolla, koska sovellusta ei ole rakennettu sen vaatimusten mukaisesti.

### Docker Build & Push

Kirjautuminen Docker Hubiin, sovelluksesta rakennetaan Docker-image ja se lähetetään Docker Hubiin latest-tagilla.

### Deploy (Tuotantoonvienti)

Yhteys muodostetaan CSC:n palvelimelle SSH-protokollalla. Palvelimella suoritetaan komentosarja, joka lataa uusimman imagen ja käynnistää Docker-kontit uudelleen. Lopuksi järjestelmä poistaa vanhentuneet imaget levytilan säästämiseksi.

## Tuotantoympäristö

Sovellus on asennettu CSC:n (IT Center for Science) cPouta-pilvipalveluun Ubuntu-virtuaalikoneelle.

### Palvelimen hakemistorakenne

Palvelimen kotihakemistossa `/home/ubuntu/itembase-harjoitus/` sijaitsee `docker-compose.yml`, joka määrittelee sovelluksen ja tietokannan asetukset.

### Vaaditut salaisuudet (GitHub Secrets)

Automatisoitu käyttöönotto vaatii seuraavien muuttujien määrittämistä GitHub-repositorion asetuksissa:

- **DOCKER_USERNAME ja DOCKER_PASSWORD:** Tunnukset Docker Hubiin
- **CSC_HOST:** Tuotantopalvelimen IP-osoite
- **CSC_USERNAME:** SSH-käyttäjätunnus (oletuksena ubuntu)
- **CSC_SSH_KEY:** Yksityinen SSH-avain palvelimelle kirjautumiseen

**Tekijä: Kai Katajisto TITE23 - README.md luotu AI:n avulla. Ihmisluettu ja korjattu.**

**Kehitys, oppimis ja ajatus prosesessit (harjoitus-tarkoituksessa) löytyy tiedostosta Vomit.txt**
