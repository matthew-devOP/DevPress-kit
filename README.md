# DevPress-Kit

Un mediu de dezvoltare WordPress cuprinzător și pregătit pentru producție, folosind Docker cu performanță optimizată, capabilități de debugging și instrumente de dezvoltare.

## Cuprins

- [Prezentare Generală](#prezentare-generală)
- [Arhitectura](#arhitectura)
- [Instalare](#instalare)
- [Utilizare](#utilizare)
- [Configurare Debugging](#configurare-debugging)
- [Optimizare Performanță](#optimizare-performanță)
- [Depanare](#depanare)
- [Maparea Porturilor](#maparea-porturilor)
- [Instrumente de Dezvoltare](#instrumente-de-dezvoltare)
- [Contribuire](#contribuire)

## Prezentare Generală

DevPress-Kit oferă un mediu modern de dezvoltare WordPress containerizat cu următoarele caracteristici:

- **Setup Rapid**: Instalare și pornire cu o singură comandă
- **Optimizat pentru Dezvoltare**: Integrare Xdebug, hot-reloading, caching optimizat
- **Pregătit pentru Producție**: Configurabil pentru deployment în producție
- **Stack Complet**: Stack LAMP complet cu instrumente suplimentare
- **Testare Email**: MailHog integrat pentru dezvoltarea de emailuri
- **Management Bază de Date**: phpMyAdmin integrat
- **Instrumente de Performanță**: Caching Redis, configurații optimizate

### Caracteristici Principale

- ✅ **WordPress** cu instalare și configurare automată
- ✅ **Apache 2.4** server web cu setări optimizate
- ✅ **PHP-FPM** cu suport Xdebug pentru debugging
- ✅ **MariaDB** bază de date cu tuning de performanță
- ✅ **phpMyAdmin** pentru managementul bazei de date
- ✅ **MailHog** pentru testarea și dezvoltarea de emailuri
- ✅ **Redis** caching (mediu de dezvoltare)
- ✅ **Node.js** instrumente pentru compilarea asset-urilor
- ✅ **WP-CLI** integrare cu script-uri wrapper
- ✅ **Backup-uri automate** și restaurare
- ✅ **Instrumente de dezvoltare** și utilitare

## Arhitectura

### Arhitectura Serviciilor

```
┌─────────────────────────────────────────────────────────────┐
│                    Rețea Docker                              │
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │   Apache    │    │  PHP-FPM    │    │   MariaDB   │     │
│  │   :80       │◄──►│   :9000     │◄──►│   :3306     │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │ phpMyAdmin  │    │   MailHog   │    │    Redis    │     │
│  │   :8080     │    │   :8025     │    │   :6379     │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
│                                                             │
│                    ┌─────────────┐                          │
│                    │   Node.js   │                          │
│                    │ (Instrumente)│                          │
│                    └─────────────┘                          │
└─────────────────────────────────────────────────────────────┘
```

### Structura Directoarelor

```
devpress-kit/
├── docker-compose.yml          # Configurarea serviciilor principale
├── docker-compose.override.yml # Override-uri pentru dezvoltare
├── .env                        # Variabile de mediu
├── Makefile                    # Comenzi de dezvoltare
├── start.sh                    # Script de pornire
├── README.md                   # Acest fișier
├──
├── src/                        # Codul sursă WordPress
├── config/                     # Fișiere de configurare
│   ├── apache/                 # Configurări Apache
│   ├── php/                    # Configurări PHP
│   ├── mysql/                  # Configurări MySQL
│   ├── phpmyadmin/             # Setări phpMyAdmin
│   └── redis/                  # Configurare Redis
├──
├── scripts/                    # Script-uri utilitare
│   ├── init.sh                 # Inițializare WordPress
│   ├── wp-cli.sh               # Wrapper WP-CLI
│   ├── toggle-xdebug.sh        # Toggle Xdebug
│   ├── backup-db.sh            # Backup bază de date
│   ├── restore-db.sh           # Restaurare bază de date
│   └── view-logs.sh            # Vizualizator log-uri
├──
├── logs/                       # Log-uri aplicații
│   ├── apache/                 # Log-uri Apache
│   ├── php/                    # Log-uri PHP
│   ├── mysql/                  # Log-uri MySQL
│   └── xdebug/                 # Log-uri Xdebug
├──
├── backups/                    # Backup-uri bază de date
└── sql/                        # Fișiere de inițializare SQL
    └── init/                   # Inițializare bază de date
```

## Instalare

### Cerințe Sistem

- **Docker**: Versiunea 20.0 sau mai nouă
- **Docker Compose**: Versiunea 2.0 sau mai nouă (sau docker-compose v1.29+)
- **Git**: Pentru clonarea repository-ului
- **Make** (opțional): Pentru utilizarea comenzilor Makefile
- **4GB RAM** recomandat pentru performanță optimă
- **2GB spațiu liber** pentru imagini Docker și volume-uri

### Instalare Rapidă

1. **Clonează repository-ul:**
   ```bash
   git clone https://github.com/your-username/devpress-kit.git
   cd devpress-kit
   ```

2. **Pornește mediul (recomandat):**
   ```bash
   ./start.sh
   ```
   
   Sau folosind make:
   ```bash
   make up
   ```

3. **🎉 După pornirea cu succes, vei avea acces la:**

   **📱 Interfețe Web:**
   - 🌐 **Site WordPress**: http://localhost
   - 🔐 **Admin WordPress**: http://localhost/wp-admin
   - 🗄️ **phpMyAdmin**: http://localhost:8080
   - 📧 **MailHog Web UI**: http://localhost:8025

   **🔑 Credențiale Implicite:**
   - **WordPress Admin**: `admin` / `admin_password`
   - **Bază de Date**: `webapp_user` / `webapp_pass`
   - **MySQL Root**: `root_password`

   **📊 Informații Conexiune:**
   - **Host Bază de Date**: `localhost:3306`
   - **Redis Cache**: `localhost:6379`
   - **SMTP MailHog**: `localhost:1025`
   - **Xdebug Port**: `9003`

### Instalare Manuală

1. **Clonează și configurează:**
   ```bash
   git clone https://github.com/your-username/devpress-kit.git
   cd devpress-kit
   cp .env.example .env  # Editează după necesități
   ```

2. **Creează directoarele necesare:**
   ```bash
   mkdir -p src config/{apache,php,mysql,phpmyadmin,redis} logs/{apache,php,mysql,xdebug} backups sql/init scripts
   ```

3. **Pornește serviciile:**
   ```bash
   docker-compose up -d --build
   ```

4. **Inițializează WordPress:**
   ```bash
   ./scripts/init.sh
   ```

### ⚠️ Probleme Frecvente la Instalare

**Porturi ocupate:**
```bash
# Verifică ce folosește portul 80
sudo lsof -i :80
# Oprește Apache local (dacă este instalat)
sudo systemctl stop apache2
```

**Permisiuni:**
```bash
# Fix permisiuni pentru directorul src
chmod -R 755 src/
```

**Docker nu pornește:**
```bash
# Restart Docker daemon
sudo systemctl restart docker
```

## Utilizare

### Comenzi de Bază

#### Folosind Script-ul de Pornire
```bash
# Pornește totul (recomandat)
./start.sh

# Pornește fără să deschidă browser-ul
NO_BROWSER=1 ./start.sh
```

#### Folosind Comenzi Make
```bash
# Pornește toate serviciile
make up

# Oprește toate serviciile
make down

# Vizualizează log-urile
make logs

# Creează backup bază de date
make backup

# Resetează instalarea WordPress
make reset

# Acces la shell-ul containerului PHP
make shell-php

# Acces la shell-ul bazei de date
make shell-db
```

#### Folosind Docker Compose Direct
```bash
# Pornește serviciile
docker-compose up -d

# Oprește serviciile
docker-compose down

# Vizualizează log-urile
docker-compose logs -f

# Restart serviciu specific
docker-compose restart php-fpm

# Rebuild și pornește
docker-compose up -d --build
```

### Management WordPress

#### Folosind Wrapper-ul WP-CLI
```bash
# Afișează informații WordPress
./scripts/wp-cli.sh info

# Instalează WordPress (interactiv)
./scripts/wp-cli.sh install-wordpress

# Listează plugin-urile
./scripts/wp-cli.sh plugin list

# Instalează plugin
./scripts/wp-cli.sh plugin install contact-form-7 --activate

# Update WordPress core
./scripts/wp-cli.sh core update

# Căută și înlocuiește URL-uri
./scripts/wp-cli.sh search-replace 'old-domain.com' 'new-domain.com'

# Acces la shell-ul containerului
./scripts/wp-cli.sh shell
```

#### Operații pe Baza de Date
```bash
# Backup bază de date
./scripts/backup-db.sh

# Restaurează baza de date
./scripts/restore-db.sh backup_file.sql

# Export bază de date
docker-compose exec mariadb mysqldump -u root -p${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE} > backup.sql

# Import bază de date
docker-compose exec -T mariadb mysql -u root -p${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE} < backup.sql
```

## Configurare Debugging

### Configurarea Xdebug

DevPress-Kit vine cu Xdebug pre-configurat pentru debugging.

#### Activează/Dezactivează Xdebug
```bash
# Toggle Xdebug (activează/dezactivează)
./scripts/toggle-xdebug.sh

# Activează Xdebug
./scripts/toggle-xdebug.sh on

# Dezactivează Xdebug
./scripts/toggle-xdebug.sh off

# Verifică statusul Xdebug
./scripts/toggle-xdebug.sh status
```

#### Configurarea IDE

**VS Code (cu extensia PHP Debug):**

1. Instalează extensia PHP Debug
2. Creează `.vscode/launch.json`:
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Listen for Xdebug",
            "type": "php",
            "request": "launch",
            "port": 9003,
            "pathMappings": {
                "/var/www/html": "${workspaceFolder}/src"
            }
        }
    ]
}
```

**PhpStorm:**

1. File → Settings → Languages & Frameworks → PHP → Debug
2. Setează portul Xdebug la `9003`
3. Configurează maparea căilor:
   - Calea server: `/var/www/html`
   - Calea locală: `./src`
4. Activează "Start Listening for PHP Debug Connections"

**Setări Xdebug:**
- Host: `host.docker.internal` (macOS/Windows) sau `172.17.0.1` (Linux)
- Port: `9003`
- Cheia IDE: `PHPSTORM`

### Variabile de Mediu pentru Dezvoltare

Override-ul de dezvoltare (`docker-compose.override.yml`) include debugging îmbunătățit:

```bash
# Xdebug settings
XDEBUG_MODE=develop,debug,coverage
XDEBUG_START_WITH_REQUEST=yes
XDEBUG_CLIENT_HOST=host.docker.internal
XDEBUG_CLIENT_PORT=9003

# WordPress debugging
WP_DEBUG=true
WP_DEBUG_LOG=true
WP_DEBUG_DISPLAY=false
WP_DISABLE_FATAL_ERROR_HANDLER=true
SCRIPT_DEBUG=true

# PHP debugging
PHP_DISPLAY_ERRORS=On
PHP_ERROR_REPORTING=E_ALL
```

### Vizualizarea Log-urilor

```bash
# Vizualizează toate log-urile
./scripts/view-logs.sh

# Vizualizează log-urile serviciilor specifice
docker-compose logs -f apache
docker-compose logs -f php-fpm
docker-compose logs -f mariadb

# Vizualizează log-urile de eroare PHP
tail -f logs/php/error.log

# Vizualizează log-urile Xdebug
tail -f logs/xdebug/xdebug.log
```

## Optimizarea Performanței

### Dezvoltare vs Producție

Mediul se optimizează automat pe baza configurației:

#### Optimizări pentru Dezvoltare (`docker-compose.override.yml`)
- **Caching Volume-uri**: `:cached` mount pentru performanță mai bună pe macOS
- **Limite Memorie**: Limită de memorie PHP mărită (512M)
- **Timp Execuție**: Timp de execuție PHP extins (300s)
- **Rotația Log-urilor**: Rotație automată a log-urilor
- **Tuning Bază de Date**: Optimizat pentru viteza de dezvoltare

#### Optimizări pentru Producție
- **OPcache**: OPcache PHP activat
- **Caching Redis**: Caching complet de pagină și obiecte
- **Baza de Date**: Setări MySQL optimizate pentru producție
- **Logging Minimal**: Verbiozitatea log-urilor redusă
- **Securitate**: Header-e de securitate îmbunătățite

### Configurarea Caching-ului

#### Cache Redis (Dezvoltare)
```bash
# Verifică statusul Redis
docker-compose exec redis redis-cli info

# Monitorizează Redis
docker-compose exec redis redis-cli monitor

# Șterge cache-ul Redis
docker-compose exec redis redis-cli FLUSHALL
```

#### Cache pentru Obiecte WordPress
Adaugă în `wp-config.php`:
```php
// Cache Redis pentru Obiecte
define('WP_REDIS_HOST', 'redis');
define('WP_REDIS_PORT', 6379);
define('WP_REDIS_PASSWORD', 'your_redis_password');
define('WP_CACHE', true);
```

### Optimizarea Bazei de Date

#### Tuning Performanță MySQL (Dezvoltare)
```sql
-- Verifică setările curente
SHOW VARIABLES LIKE 'innodb_buffer_pool_size';
SHOW VARIABLES LIKE 'innodb_log_file_size';

-- Monitorizarea performanței
SHOW PROCESSLIST;
SHOW ENGINE INNODB STATUS;
```

#### Monitorizarea Query-urilor Lente
Query-urile lente sunt înregistrate în `logs/mysql/slow.log` pentru query-uri > 2 secunde.

### Optimizarea Sistemului de Fișiere

Pentru performanță mai bună pe macOS/Windows:
- Folosește `:cached` volume mounts pentru codul sursă
- Stochează baza de date pe volume-uri cu nume (nu bind mounts)
- Folosește `.dockerignore` pentru a exclude fișierele nenecesare

## Depanare

### Probleme Frecvente și Soluții

#### 1. Serviciile Nu Pornesc

**Problemă**: Container-ele Docker eșuează la pornire
```bash
# Verifică statusul Docker
docker info
docker-compose ps

# Vizualizează log-urile de eroare
docker-compose logs

# Verifică conflictele de porturi
netstat -tulpn | grep -E ":(80|443|3306|8080|8025|9000)"

# Restart serviciul Docker (Linux)
sudo systemctl restart docker
```

**Soluții**:
- Asigură-te că daemon-ul Docker rulează
- Verifică conflictele de porturi
- Verifică configurația fișierului `.env`
- Curăță cache-ul Docker: `docker system prune -a`

#### 2. Erori de Conexiune la Baza de Date

**Problemă**: WordPress nu se poate conecta la baza de date
```bash
# Testează conexiunea la baza de date
docker-compose exec php-fpm wp db check

# Verifică statusul MariaDB
docker-compose exec mariadb mysql -u root -p -e "SHOW DATABASES;"

# Verifică credențialele din fișierul .env
cat .env | grep -E "(DB_|MYSQL_)"
```

**Soluții**:
- Așteaptă inițializarea bazei de date (30-60 secunde)
- Verifică credențialele bazei de date din `.env`
- Verifică log-urile containerului bazei de date: `docker-compose logs mariadb`
- Resetează baza de date: `docker-compose down -v && docker-compose up -d`

#### 3. Probleme de Permisiuni

**Problemă**: Erori de permisiuni fișiere
```bash
# Reparați permisiunile WordPress
docker-compose exec php-fpm chown -R www-data:www-data /var/www/html
docker-compose exec php-fpm chmod -R 755 /var/www/html
docker-compose exec php-fpm chmod -R 777 /var/www/html/wp-content/uploads

# Reparați permisiunile locale (macOS/Linux)
sudo chown -R $(whoami):$(whoami) src/
chmod -R 755 src/
```

#### 4. Xdebug Nu Funcționează

**Problemă**: Xdebug nu se conectează la IDE
```bash
# Verifică statusul Xdebug
./scripts/toggle-xdebug.sh status

# Verifică configurația Xdebug
docker-compose exec php-fpm php -i | grep xdebug

# Verifică conectivitatea
telnet host.docker.internal 9003  # macOS/Windows
telnet 172.17.0.1 9003            # Linux
```

**Soluții**:
- Asigură-te că IDE-ul ascultă pe portul 9003
- Configurează corect maparea căilor
- Folosește host-ul corect: `host.docker.internal` sau `172.17.0.1`
- Restart PHP-FPM: `docker-compose restart php-fpm`

#### 5. Performanță Scăzută

**Problemă**: Încărcări lente ale paginilor și răspunsuri
```bash
# Verifică resursele container-elor
docker stats

# Monitorizează performanța bazei de date
docker-compose exec mariadb mysql -u root -p -e "SHOW PROCESSLIST;"

# Verifică log-ul query-urilor lente
tail -f logs/mysql/slow.log

# Monitorizează statusul PHP-FPM
docker-compose exec php-fpm /usr/local/sbin/php-fpm -t
```

**Soluții**:
- Mărește alocația de memorie Docker (4GB+)
- Folosește `:cached` volume mounts pe macOS
- Activează OPcache în producție
- Optimizează query-urile bazei de date
- Folosește Redis pentru object caching

#### 6. Email-urile Nu Funcționează

**Problemă**: Email-urile WordPress nu sunt trimise
```bash
# Verifică statusul MailHog
curl -f http://localhost:8025

# Testează conexiunea SMTP
docker-compose exec php-fpm wp eval "wp_mail('test@example.com', 'Test', 'Test message');"

# Verifică interfața MailHog
open http://localhost:8025  # macOS
```

**Soluții**:
- Verifică că MailHog rulează: `docker-compose ps mailhog`
- Verifică setările SMTP WordPress
- Instalează și configurează plugin-ul WP Mail SMTP
- Verifică setările SMTP: Host: `mailhog`, Port: `1025`

#### 7. Probleme SSL/HTTPS

**Problemă**: Ai nevoie de HTTPS pentru dezvoltare
```bash
# Generează certificat self-signed
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout config/apache/ssl/server.key \
  -out config/apache/ssl/server.crt

# Actualizează configurația Apache pentru a activa SSL
# Adaugă virtual host SSL în configurația Apache
```

### Logging și Monitorizare

#### Activează Debug Logging
```bash
# Log debug WordPress
tail -f src/wp-content/debug.log

# Log erori PHP
tail -f logs/php/error.log

# Log erori Apache
tail -f logs/apache/error.log

# Log erori MySQL
tail -f logs/mysql/error.log
```

#### Monitorizarea Performanței
```bash
# Monitorizează performanța container-elor
docker stats

# Verifică performanța bazei de date
docker-compose exec mariadb mysql -u root -p -e "SHOW ENGINE INNODB STATUS\G"

# Monitorizează statusul pool-ului PHP-FPM
docker-compose exec php-fpm curl -f http://localhost/status
```

## Maparea Porturilor

### Porturi Implicite

| Service | Internal Port | External Port | Description |
|---------|---------------|---------------|-------------|
| Apache | 80 | 80 | Web server (HTTP) |
| Apache | 443 | 443 | Web server (HTTPS) * |
| PHP-FPM | 9000 | 9000 | PHP FastCGI |
| MariaDB | 3306 | 3306 | Database server |
| phpMyAdmin | 80 | 8080 | Database management |
| MailHog SMTP | 1025 | 1025 | SMTP server |
| MailHog Web UI | 8025 | 8025 | Email web interface |
| Redis | 6379 | 6379 | Cache server |
| Xdebug | 9003 | 9003 | Debugging |

\* HTTPS requires SSL certificate configuration

### Configurarea Porturilor Personalizate

Editează fișierul `.env` pentru a personaliza porturile:
```bash
# Porturi personalizate
WP_PORT=8080                    # WordPress (implicit: 80)
DB_PORT=3307                    # Baza de date (implicit: 3306)
PHPMYADMIN_PORT=8081           # phpMyAdmin (implicit: 8080)
MAILHOG_WEB_PORT=8026          # MailHog Web UI (implicit: 8025)
MAILHOG_SMTP_PORT=1026         # MailHog SMTP (implicit: 1025)
REDIS_PORT=6380                # Redis (implicit: 6379)
```

### Rezolvarea Conflictelor de Porturi

Dacă întâlnești conflicte de porturi:

1. **Verifică ce folosește portul:**
   ```bash
   # macOS/Linux
   lsof -i :80
   netstat -tulpn | grep :80
   
   # Windows
   netstat -ano | findstr :80
   ```

2. **Oprește serviciile în conflict:**
   ```bash
   # Oprește Apache (dacă rulează local)
   sudo systemctl stop apache2    # Linux
   sudo service apache2 stop      # Ubuntu/Debian
   
   # Oprește MySQL (dacă rulează local)
   sudo systemctl stop mysql      # Linux
   brew services stop mysql       # macOS
   ```

3. **Folosește porturi alternative:**
   Actualizează fișierul `.env` cu porturi disponibile și restartează:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

## Instrumente de Dezvoltare

### Integrarea WP-CLI

Acces complet la interfața în linia de comandă WordPress:

```bash
# WordPress info
./scripts/wp-cli.sh info

# Core operations
./scripts/wp-cli.sh core update
./scripts/wp-cli.sh core version

# Plugin management
./scripts/wp-cli.sh plugin list
./scripts/wp-cli.sh plugin install woocommerce --activate
./scripts/wp-cli.sh plugin update --all

# Theme management
./scripts/wp-cli.sh theme list
./scripts/wp-cli.sh theme install twentytwentythree --activate

# Database operations
./scripts/wp-cli.sh db export backup.sql
./scripts/wp-cli.sh db import backup.sql
./scripts/wp-cli.sh search-replace 'old.com' 'new.com'

# User management
./scripts/wp-cli.sh user list
./scripts/wp-cli.sh user create newuser user@email.com --role=editor
```

### Compilarea Asset-urilor (Node.js)

Mediul include Node.js pentru compilarea asset-urilor:

```bash
# Pornește containerul Node.js (profilul tools)
docker-compose --profile tools up -d node

# Rulează comenzi npm
docker-compose exec node npm install
docker-compose exec node npm run build
docker-compose exec node npm run watch

# Instalează instrumente globale
docker-compose exec node npm install -g gulp-cli webpack-cli
```

### Managementul Bazei de Date

Înafara phpMyAdmin, acces direct la baza de date:

```bash
# Acces MySQL CLI
./scripts/wp-cli.sh shell
# sau
docker-compose exec mariadb mysql -u root -p

# Backup bază de date
./scripts/backup-db.sh

# Restaurarea bazei de date
./scripts/restore-db.sh path/to/backup.sql

# Backup rapid cu timestamp
docker-compose exec -T mariadb mysqldump -u root -p${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE} > "backup_$(date +%Y%m%d_%H%M%S).sql"
```

### Instrumente pentru Calitatea Codului

Integrare cu instrumente populare de dezvoltare PHP:

```bash
# Instalează dependențele Composer în container
docker-compose exec php-fpm composer install

# Rulează analiza PHPStan
docker-compose exec php-fpm vendor/bin/phpstan analyse

# Rulează PHP CodeSniffer
docker-compose exec php-fpm vendor/bin/phpcs

# Rulează testele PHPUnit
docker-compose exec php-fpm vendor/bin/phpunit
```

## Configurarea Mediului

### Variabile de Mediu

Opțiuni de configurare cheie în `.env`:

```bash
# Configurarea Bazei de Date
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_PASSWORD=wp_password
MYSQL_ROOT_PASSWORD=root_password

# Configurarea WordPress
WP_DEBUG=true
WP_HOME=http://localhost
WP_SITEURL=http://localhost

# Credențiale Admin
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=admin_password
WP_ADMIN_EMAIL=admin@localhost.local
WP_SITE_TITLE=WordPress Development Site

# Configurarea Xdebug
XDEBUG_ENABLE=true

# Maparea Porturilor
WP_PORT=80
DB_PORT=3306
PHPMYADMIN_PORT=8080

# Configurarea Redis (Dezvoltare)
REDIS_PASSWORD=dev_redis_pass
```

### Configurarea pentru Producție

Pentru deployment în producție, creează `.env.production`:

```bash
# Baza de Date Producție
MYSQL_DATABASE=prod_database
MYSQL_USER=prod_user
MYSQL_PASSWORD=secure_password
MYSQL_ROOT_PASSWORD=secure_root_password

# WordPress Producție
WP_DEBUG=false
WP_HOME=https://yourdomain.com
WP_SITEURL=https://yourdomain.com

# Securitate
WP_DISABLE_FILE_MODS=true
DISALLOW_FILE_EDIT=true

# Performanță
XDEBUG_ENABLE=false
```

Deployment cu:
```bash
docker-compose --env-file .env.production up -d
```

## Contribuire

### Ghiduri de Dezvoltare

1. **Fork repository-ul**
2. **Creează un branch pentru feature**: `git checkout -b feature/amazing-feature`
3. **Fă modificările** cu documentație corespunzătoare
4. **Testează în profunzime** în configurații de dezvoltare și producție
5. **Submită un pull request**

### Stilul Codului

- Folosește practici consistente de bash scripting
- Urmează best practices Docker pentru container-e
- Documentează toate opțiunile de configurare
- Include error handling în script-uri
- Testează pe multiple platforme (macOS, Linux, Windows)

### Testare

Înainte de a submite modificări:

```bash
# Testează procesul de startup
./start.sh

# Testează script-urile individuale
./scripts/init.sh
./scripts/wp-cli.sh info
./scripts/toggle-xdebug.sh

# Testează cu configurații diferite
docker-compose down -v
WP_PORT=8080 ./start.sh

# Testează configurația de producție
docker-compose --env-file .env.production up -d
```

### Raportarea Problemelor

Când raportezi probleme, includeți:

1. **Detalii mediu**: OS, versiunea Docker, versiunea Docker Compose
2. **Pașii pentru reproducere** a problemei
3. **Comportamentul așteptat** vs **comportamentul actual**
4. **Ieșirile log-urilor**: `docker-compose logs`
5. **Configurarea**: Părțile relevante din fișierul `.env`

## Licență

Acest proiect este licențiat sub Licența MIT - vezi fișierul [LICENSE](LICENSE) pentru detalii.

## Suport

- **Documentația**: Acest README și comentariile inline din script-uri
- **Issues**: GitHub Issues pentru rapoarte de bug-uri și cereri de feature-uri
- **Comunitate**: Discuții pentru întrebări generale și ajutor

## Recunoașteri

- Comunitatea WordPress pentru excelentul CMS
- Comunitatea Docker pentru best practices de containerizare
- Contributorii și testerii care au ajutat la îmbunătățirea acestui mediu

---

**Dezvoltare WordPress Fericită! 🚀**
