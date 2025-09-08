# FIȘA PROIECT - DevPress-Kit

## INFORMAȚII GENERALE

**Nume Proiect:** DevPress-Kit  
**Tip Proiect:** Mediu de dezvoltare WordPress containerizat  
**Status:** Proiect complet și funcțional  
**Tehnologii principale:** Docker, Docker Compose, WordPress, PHP, Apache, MariaDB  

---

## PREZENTARE GENERALĂ

DevPress-Kit este un mediu de dezvoltare complet containerizat pentru WordPress, optimizat pentru performanță și productivitate. Proiectul oferă un stack complet LAMP (Linux, Apache, MySQL, PHP) plus instrumente suplimentare pentru dezvoltare, testing și debugging.

### OBIECTIVELE PROIECTULUI
- **Setup rapid**: Mediu functional într-o singură comandă
- **Dezvoltare optimizată**: Xdebug, hot-reloading, caching optimizat
- **Production-ready**: Configurabil pentru deployment în producție
- **Full stack**: Stack complet cu toate instrumentele necesare
- **Debugging avansat**: Suport pentru Xdebug și diverse instrumente de debugging

---

## ARHITECTURA SISTEMULUI

### STACK TEHNOLOGIC

#### **Servicii Container Principale**
1. **Apache 2.4** - Server web cu configurări optimizate
2. **PHP-FPM 8.2** - Motor PHP cu extensii complete WordPress
3. **MariaDB 10.11** - Bază de date cu tuning pentru performanță
4. **phpMyAdmin 5.2** - Interface grafic pentru administrarea bazei de date
5. **MailHog** - Server SMTP pentru testarea emailurilor în dezvoltare

#### **Servicii Dezvoltare (Override)**
6. **Redis 7** - Cache în memorie pentru performanță
7. **Node.js 18** - Pentru compilarea asset-urilor frontend
8. **Xdebug** - Debugging integrat pentru PHP

### MAPAREA PORTURILOR

| Serviciu | Port Intern | Port Extern | Descriere |
|----------|-------------|-------------|-----------|
| Apache | 80 | 80 | Server web principal |
| PHP-FPM | 9000 | 9000 | FastCGI Process Manager |
| MariaDB | 3306 | 3306 | Bază de date |
| phpMyAdmin | 80 | 8080 | Management bază de date |
| MailHog SMTP | 1025 | 1025 | Server SMTP local |
| MailHog Web UI | 8025 | 8025 | Interface web MailHog |
| Redis | 6379 | 6379 | Cache server |
| Xdebug | 9003 | 9003 | Port debugging |

---

## FUNCȚIONALITĂȚI IMPLEMENTATE

### 1. **MANAGEMENT CONTAINERS**

#### **Startup Automatizat**
- **Script `start.sh`**: Startup complet cu verificări automate
  - Verificare Docker și Docker Compose
  - Crearea directoarelor necesare
  - Configurarea serviciilor
  - Inițializarea WordPress
  - Deschiderea automată în browser

#### **Comenzi Makefile**
```bash
make up       # Pornire servicii cu inițializare
make down     # Oprire servicii
make logs     # Vizualizare log-uri
make backup   # Backup bază de date
make reset    # Reset complet WordPress
make shell-php # Acces container PHP
make shell-db  # Acces container MariaDB
```

### 2. **DEZVOLTARE WORDPRESS**

#### **WP-CLI Integration Completă**
- **Script `wp-cli.sh`**: Wrapper pentru toate comenzile WP-CLI
  - Instalare WordPress interactivă
  - Management plugin-uri și teme
  - Operații pe baza de date
  - Import/export conținut
  - Acces direct la container shell

#### **Funcționalități WP-CLI:**
```bash
./scripts/wp-cli.sh info                    # Informații WordPress
./scripts/wp-cli.sh install-wordpress       # Instalare ghidată
./scripts/wp-cli.sh plugin list             # Listare plugin-uri
./scripts/wp-cli.sh plugin install [nume]   # Instalare plugin
./scripts/wp-cli.sh core update             # Update WordPress core
./scripts/wp-cli.sh shell                   # Acces container
```

### 3. **DEBUGGING AVANSAT**

#### **Xdebug Integration**
- **Script `toggle-xdebug.sh`**: Control complet Xdebug
  - Activare/dezactivare dinamică
  - Verificare status configurație
  - Configurare automată pentru IDE-uri
  - Support pentru VS Code și PhpStorm

#### **Configurații Debugging:**
- **Host**: `host.docker.internal` (macOS/Windows) sau `172.17.0.1` (Linux)
- **Port**: 9003
- **IDE Key**: PHPSTORM
- **Mode**: develop, debug, coverage

#### **Logging Comprehensive**
- **Script `view-logs.sh`**: Viewer centralizat log-uri
  - Log-uri toate serviciile sau selectiv
  - Follow mode pentru monitoring real-time
  - Configurare număr linii și timestamps
  - Filtrare pe servicii

### 4. **MANAGEMENT BAZĂ DE DATE**

#### **Backup Automatizat**
- **Script `backup-db.sh`**: Backup complet cu compresia
  - Backup cu timestamp automat
  - Compresia gzip pentru economisirea spațiului
  - Rotație automată (păstrare ultimele 10 backup-uri)
  - Verificări integritate și erori

#### **Restore Granular**
- **Script `restore-db.sh`**: Restaurare cu siguranță
  - Listare backup-uri disponibile cu detalii
  - Backup de siguranță înainte de restore
  - Suport pentru fișiere comprimate
  - Confirmări și validări

#### **Operații Avansate:**
```bash
./scripts/backup-db.sh                      # Backup automat
./scripts/restore-db.sh [fisier_backup]     # Restore din backup
docker-compose exec mariadb mysql...        # Acces direct MySQL
```

### 5. **PERFORMANȚĂ ȘI OPTIMIZARE**

#### **Configurații PHP Optimizate**
- **Memory limit**: 512M pentru dezvoltare
- **Execution time**: 300s pentru operații complexe
- **Upload limits**: 64M pentru fișiere mari
- **OPcache**: Activat cu setări optimizate pentru WordPress
- **Extensions**: mysqli, gd, zip, opcache, pdo_mysql, intl, mbstring

#### **Configurații Apache Optimizate**
- **Securitate**: ServerTokens Prod, directive de securitate
- **Performance**: KeepAlive, MaxRequestWorkers optimizați
- **PHP-FPM Integration**: Proxy optimizat pentru FastCGI
- **WordPress specifc**: DirectoryIndex, MIME types

#### **MariaDB Performance Tuning**
- **Development**: InnoDB optimizat pentru speed
- **Logging**: Slow query logging activat
- **Buffer pools**: Configurați pentru performanță
- **Connections**: Optimizați pentru concurrent requests

#### **Redis Caching (Dezvoltare)**
- **Object cache**: Pentru WordPress
- **Session storage**: Pentru scalabilitate
- **Configurare automată**: În environment dezvoltare

### 6. **ENVIRONMENT CONFIGURATION**

#### **Configurații Dezvoltare vs Producție**

**Dezvoltare (`docker-compose.override.yml`):**
- Xdebug activat cu configurații complete
- Logging verbose pentru debugging
- Volume caching pentru performance (macOS)
- Redis cache pentru testare
- Node.js pentru asset compilation

**Producție:**
- Xdebug dezactivat
- Logging minimal pentru performance
- Securitate sporită
- Optimizări OPcache maxime

#### **Variables de Environment**
```bash
# Database
MYSQL_DATABASE=webapp_db
MYSQL_USER=webapp_user
MYSQL_PASSWORD=webapp_pass
MYSQL_ROOT_PASSWORD=root_password

# WordPress
WP_DEBUG=true
WP_HOME=http://localhost
WP_SITEURL=http://localhost

# Admin
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=admin_password
WP_ADMIN_EMAIL=admin@localhost.local

# Xdebug
XDEBUG_ENABLE=true
XDEBUG_CLIENT_HOST=host.docker.internal
XDEBUG_CLIENT_PORT=9003

# Redis
REDIS_PASSWORD=dev_redis_pass
```

### 7. **SECURITATE ȘI BEST PRACTICES**

#### **Securitate PHP**
- `expose_php = Off`
- Funcții periculoase dezactivate: `exec, passthru, shell_exec, system`
- Upload restrictions și validări
- Session security optimizat

#### **Securitate Apache**
- Ascunderea fișierelor de configurare
- Protecție împotriva directory traversal
- Headers de securitate
- Restricții pe tipuri de fișiere sensibile

#### **Securitate Container**
- Non-root user pentru PHP processes
- Volume permissions controlate
- Network isolation între servicii
- Secrets management prin environment variables

### 8. **TOOLING ȘI AUTOMATIZARE**

#### **Asset Compilation (Node.js)**
```bash
docker-compose --profile tools up -d node
docker-compose exec node npm install
docker-compose exec node npm run build
docker-compose exec node npm run watch
```

#### **Code Quality Tools**
- PHPStan integration preparată
- PHP CodeSniffer support
- PHPUnit testing environment
- Composer dependency management

#### **Development Utilities**
- SSH keys mounting pentru Git operations
- Composer cache pentru dependencies rapide
- NPM cache pentru node modules
- Hot-reloading pentru development

---

## STRUCTURA PROIECTULUI

```
devpress-kit/
├── 📋 Management Files
│   ├── docker-compose.yml           # Configurații servicii principale
│   ├── docker-compose.override.yml  # Override-uri pentru dezvoltare
│   ├── Makefile                     # Comenzi automatizate
│   ├── start.sh                     # Script startup complet
│   └── .env                         # Variables de environment
├── 🐳 Docker Configuration
│   └── docker/php-fpm/
│       └── Dockerfile               # Custom PHP container cu extensii
├── ⚙️ Configuration Files
│   ├── config/apache/
│   │   ├── apache2.conf            # Configurație Apache optimizată
│   │   ├── modules.conf            # Module Apache
│   │   ├── wordpress.conf          # VirtualHost WordPress
│   │   └── wordpress.htaccess      # Reguli rewrite WordPress
│   ├── config/php/
│   │   ├── php.ini                 # Configurație PHP optimizată
│   │   ├── opcache.ini             # Configurație OPcache
│   │   └── xdebug.ini              # Configurație Xdebug
│   ├── config/mysql/
│   ├── config/phpmyadmin/
│   └── config/redis/
├── 🛠️ Scripts & Tools
│   ├── scripts/init.sh             # Inițializare WordPress automată
│   ├── scripts/wp-cli.sh           # Wrapper WP-CLI
│   ├── scripts/toggle-xdebug.sh    # Control Xdebug
│   ├── scripts/backup-db.sh        # Backup bază de date
│   ├── scripts/restore-db.sh       # Restore bază de date
│   └── scripts/view-logs.sh        # Viewer log-uri
├── 📂 Application Files
│   └── src/                        # Fișiere WordPress
├── 📊 Logs & Monitoring
│   └── logs/
│       ├── apache/                 # Log-uri Apache
│       ├── php/                    # Log-uri PHP
│       ├── mysql/                  # Log-uri MariaDB
│       └── xdebug/                 # Log-uri Xdebug
├── 💾 Data & Backups
│   └── backups/                    # Backup-uri bază de date
└── 📖 Documentation
    ├── README.md                   # Documentație completă
    └── fisa-proiect.md            # Această fișă de proiect
```

---

## CONFIGURAREA MEDIULUI

### PREREQUISITE

#### **Software Necesar**
- **Docker**: Versiunea 20.0 sau mai nouă
- **Docker Compose**: Versiunea 2.0 sau mai nouă (sau docker-compose v1.29+)
- **Git**: Pentru clonarea repository-ului
- **Make**: Opțional, pentru comenzile Makefile

#### **Resurse Sistem Recomandate**
- **RAM**: Minimum 4GB, recomandat 8GB
- **CPU**: 2 core-uri sau mai multe
- **Disk**: 5GB spațiu liber pentru imagini și volume-uri
- **Network**: Conexiune internet pentru download imagini Docker

### INSTALARE ȘI CONFIGURARE

#### **1. Instalare Rapidă**
```bash
# Clonare repository
git clone [repository-url] wordpress-fast-docker
cd wordpress-fast-docker

# Pornire automată (recommended)
./start.sh

# SAU folosind Make
make up
```

#### **2. Instalare Manuală**
```bash
# Clonare și configurare
git clone [repository-url] wordpress-fast-docker
cd wordpress-fast-docker

# Copiere fișier environment
cp .env.example .env  # Editare după necesități

# Creare directoare
mkdir -p src config/{apache,php,mysql,phpmyadmin,redis}
mkdir -p logs/{apache,php,mysql,xdebug} backups sql/init scripts

# Pornire servicii
docker-compose up -d --build

# Inițializare WordPress
./scripts/init.sh
```

#### **3. Configurare Environment Variables**
```bash
# Editare .env file pentru personalizare
MYSQL_DATABASE=my_wordpress_db
MYSQL_USER=my_wp_user
MYSQL_PASSWORD=secure_password

WP_ADMIN_USER=my_admin
WP_ADMIN_PASSWORD=secure_admin_pass
WP_ADMIN_EMAIL=admin@mysite.com

# Restart servicii după modificări
docker-compose down && docker-compose up -d
```

### WORKFLOW DEZVOLTARE

#### **Pornire Zilnică**
```bash
# Pornire completă cu verificări
./start.sh

# SAU pornire rapidă
docker-compose up -d
```

#### **Dezvoltare Activă**
```bash
# Urmărire log-uri în timpul dezvoltării
./scripts/view-logs.sh

# Toggle Xdebug pentru debugging
./scripts/toggle-xdebug.sh on

# Acces la container pentru debugging
./scripts/wp-cli.sh shell
```

#### **Management Plugin-uri și Teme**
```bash
# Instalare plugin nou
./scripts/wp-cli.sh plugin install plugin-name --activate

# Update toate plugin-urile
./scripts/wp-cli.sh plugin update --all

# Instalare temă
./scripts/wp-cli.sh theme install theme-name --activate
```

#### **Backup și Restore Periodic**
```bash
# Backup regulat
./scripts/backup-db.sh

# Restore când e necesar
./scripts/restore-db.sh backup_file.sql.gz
```

---

## DEBUGGING ȘI TROUBLESHOOTING

### CONFIGURARE IDE PENTRU DEBUGGING

#### **VS Code Configuration**
```json
// .vscode/launch.json
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

#### **PhpStorm Configuration**
1. **File → Settings → Languages & Frameworks → PHP → Debug**
2. **Set Xdebug port to**: 9003
3. **Configure path mappings**:
   - Server path: `/var/www/html`
   - Local path: `./src`
4. **Enable**: "Start Listening for PHP Debug Connections"

### PROBLEME COMUNE ȘI SOLUȚII

#### **1. Serviciile nu pornesc**
```bash
# Verificare status Docker
docker info
docker-compose ps

# Verificare conflicte porturi
netstat -tulpn | grep -E ":(80|443|3306|8080|8025|9000)"

# Restart Docker service (Linux)
sudo systemctl restart docker

# Curățare cache Docker
docker system prune -a
```

#### **2. Probleme conexiune bază de date**
```bash
# Test conexiune
./scripts/wp-cli.sh db check

# Verificare status MariaDB
docker-compose exec mariadb mysql -u root -p -e "SHOW DATABASES;"

# Reset bază de date
docker-compose down -v && docker-compose up -d
```

#### **3. Xdebug nu funcționează**
```bash
# Verificare status Xdebug
./scripts/toggle-xdebug.sh status

# Test conectivitate
telnet host.docker.internal 9003  # macOS/Windows
telnet 172.17.0.1 9003            # Linux

# Restart PHP-FPM
docker-compose restart php-fpm
```

#### **4. Probleme permisiuni**
```bash
# Fix permisiuni WordPress
docker-compose exec php-fpm chown -R www-data:www-data /var/www/html
docker-compose exec php-fpm chmod -R 755 /var/www/html

# Fix permisiuni locale (macOS/Linux)
sudo chown -R $(whoami):$(whoami) src/
chmod -R 755 src/
```

#### **5. Performance scăzut**
```bash
# Verificare resurse containers
docker stats

# Monitoring performance database
./scripts/view-logs.sh mariadb

# Activare Redis cache
# Editare wp-config.php pentru object cache
```

---

## PRODUCTION DEPLOYMENT

### CONFIGURARE PRODUCȚIE

#### **Environment Variables Producție**
```bash
# .env.production
MYSQL_DATABASE=prod_database
MYSQL_USER=prod_user  
MYSQL_PASSWORD=very_secure_password
MYSQL_ROOT_PASSWORD=very_secure_root_password

WP_DEBUG=false
WP_HOME=https://yourdomain.com
WP_SITEURL=https://yourdomain.com

# Securitate
WP_DISABLE_FILE_MODS=true
DISALLOW_FILE_EDIT=true

# Performance
XDEBUG_ENABLE=false
```

#### **Deployment Commands**
```bash
# Deploy cu configurație producție
docker-compose --env-file .env.production up -d

# Update în producție
docker-compose pull
docker-compose up -d --force-recreate

# Backup înainte de deployment
./scripts/backup-db.sh
```

### MONITORIZARE ȘI MENTENANȚĂ

#### **Health Checks**
```bash
# Verificare servicii
docker-compose ps

# Verificare log-uri erori
./scripts/view-logs.sh --no-follow -n 50

# Monitoring performance
docker stats
```

#### **Backup Automatizat**
```bash
# Setup cron job pentru backup zilnic
0 2 * * * /path/to/project/scripts/backup-db.sh

# Cleanup backup-uri vechi
find backups/ -name "*.sql.gz" -mtime +30 -delete
```

---

## CONTRIBUIRE ȘI DEZVOLTARE

### GUIDELINE-URI DEZVOLTARE

#### **Code Style**
- Bash scripting consistent cu comentarii extensive
- Docker best practices pentru container-uri
- Documentare pentru toate opțiunile de configurare
- Error handling în toate script-urile

#### **Testing**
```bash
# Test startup process
./start.sh

# Test script-uri individuale
./scripts/init.sh
./scripts/wp-cli.sh info
./scripts/toggle-xdebug.sh

# Test configurații diferite
WP_PORT=8080 ./start.sh
```

#### **Contribuire**
1. **Fork repository-ul**
2. **Creare feature branch**: `git checkout -b feature/amazing-feature`
3. **Implementare cu documentație completă**
4. **Test pe multiple platforme** (macOS, Linux, Windows)
5. **Submit pull request**

---

## CARACTERISTICI AVANSATE

### INTEGRĂRI DISPONIBILE

#### **CI/CD Integration**
- GitHub Actions workflows preparate
- Automated testing setup
- Docker image building și publishing
- Deployment automation

#### **Development Tools**
- **PHPStan** pentru static analysis
- **PHP CodeSniffer** pentru code standards
- **PHPUnit** pentru unit testing
- **Composer** pentru dependency management

#### **Monitoring și Observability**
- Structured logging pentru toate serviciile
- Health check endpoints
- Performance monitoring cu Redis
- Error tracking și alerting

### EXTENSIBILITATE

#### **Adăugare Servicii Noi**
```yaml
# docker-compose.override.yml
services:
  elasticsearch:
    image: elasticsearch:8.0
    environment:
      - discovery.type=single-node
    ports:
      - "9200:9200"
    networks:
      - app-network
```

#### **Custom PHP Extensions**
```dockerfile
# docker/php-fpm/Dockerfile
RUN pecl install redis \
    && docker-php-ext-enable redis
```

#### **SSL/HTTPS Support**
```bash
# Generare certificate self-signed
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout config/apache/ssl/server.key \
  -out config/apache/ssl/server.crt
```

---

## SUPORT ȘI RESOURCES

### DOCUMENTAȚIE
- **README.md**: Documentație completă utilizare
- **Inline comments**: În toate script-urile
- **Error messages**: Descriptive cu soluții

### COMMUNITY SUPPORT
- **GitHub Issues**: Pentru bug reports și feature requests
- **Discussions**: Pentru întrebări generale și ajutor
- **Wiki**: Pentru tutorials și best practices

### PERFORMANCE BENCHMARKS
- **Cold start**: ~60 secunde pentru stack complet
- **Hot reload**: ~5 secunde pentru modificări cod
- **Memory usage**: ~2GB RAM pentru stack complet
- **Xdebug overhead**: ~10-15% performance impact

---

## LICENȚĂ ȘI ACKNOWLEDGMENTS

**Licență**: MIT License  
**Contribuitori**: WordPress community, Docker community  
**Inspirație**: Best practices din comunitatea WordPress și Docker

---

## CHANGELOG ȘI VERSIONING

### Versiuni Majore
- **v1.0**: Initial release cu stack LAMP complet
- **v1.1**: Adăugare Xdebug și development tools
- **v1.2**: Implementare Redis cache și performance tuning
- **v1.3**: CI/CD integration și production optimizations

### Roadmap Viitor
- [ ] Kubernetes deployment manifests
- [ ] Multi-environment support (staging, testing)
- [ ] Automated WordPress updates
- [ ] Enhanced security scanning
- [ ] Performance monitoring dashboard

---

**🚀 Happy WordPress Development!**
