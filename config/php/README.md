# PHP Configuration Files

This directory contains optimized PHP configuration files for WordPress development with Docker.

## Files Overview

- `php.ini` - Main PHP configuration optimized for WordPress
- `xdebug.ini` - Xdebug configuration with environment-based toggle
- `opcache.ini` - OPcache configuration for performance optimization

## Environment-Based Xdebug Toggle

The Xdebug configuration supports environment-based toggling without requiring container rebuilds. This allows you to enable/disable debugging on-the-fly.

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `XDEBUG_MODE` | `off` | Xdebug operation mode (`off`, `debug`, `develop`, `debug,develop`) |
| `XDEBUG_CLIENT_HOST` | `host.docker.internal` | Debugger client host |
| `XDEBUG_CLIENT_PORT` | `9003` | Debugger client port |
| `XDEBUG_START_WITH_REQUEST` | `yes` | Start debugging with request |
| `XDEBUG_IDEKEY` | `VSCODE` | IDE key for debugging sessions |

### Usage Examples

#### Enable Debugging
```bash
# Enable debugging mode
export XDEBUG_MODE=debug,develop

# Or set in docker-compose.yml
environment:
  - XDEBUG_MODE=debug,develop
  - XDEBUG_CLIENT_HOST=host.docker.internal
  - XDEBUG_CLIENT_PORT=9003
```

#### Disable Debugging (Production)
```bash
# Disable debugging (default)
export XDEBUG_MODE=off

# Or remove/comment environment variables in docker-compose.yml
```

#### Custom Configuration
```bash
# Use custom host and port
export XDEBUG_MODE=debug
export XDEBUG_CLIENT_HOST=192.168.1.100
export XDEBUG_CLIENT_PORT=9001
export XDEBUG_IDEKEY=PHPSTORM
```

### Docker Compose Integration

Add these environment variables to your `docker-compose.yml`:

```yaml
services:
  wordpress:
    environment:
      # Development mode - enable Xdebug
      - XDEBUG_MODE=debug,develop
      - XDEBUG_CLIENT_HOST=host.docker.internal
      - XDEBUG_CLIENT_PORT=9003
      - XDEBUG_IDEKEY=VSCODE
    volumes:
      - ./config/php/php.ini:/usr/local/etc/php/conf.d/php.ini
      - ./config/php/xdebug.ini:/usr/local/etc/php/conf.d/xdebug.ini
      - ./config/php/opcache.ini:/usr/local/etc/php/conf.d/opcache.ini
```

### PHP Configuration Highlights

#### php.ini Features
- Memory limit: 512MB
- Upload size: 64MB
- Max execution time: 300 seconds
- Max input vars: 3000 (for large forms/imports)
- Security hardening with disabled dangerous functions
- UTF-8 default charset
- Optimized session handling

#### opcache.ini Features
- 256MB memory consumption
- 20,000 max accelerated files
- 32MB interned strings buffer
- JIT configuration ready (PHP 8.0+)
- WordPress-specific optimizations
- Development/production mode comments

#### xdebug.ini Features
- Environment-controlled activation
- Remote debugging support
- IDE integration
- Performance-conscious defaults
- Comprehensive variable display settings

### Performance Notes

1. **Production**: Always set `XDEBUG_MODE=off` in production
2. **OPcache**: Adjust `opcache.revalidate_freq` based on environment
   - Development: `0` (always check for changes)
   - Production: `60` or higher (cache files longer)
3. **Memory**: Monitor memory usage and adjust limits as needed

### Troubleshooting

1. **Xdebug not connecting**: Check firewall and `XDEBUG_CLIENT_HOST`
2. **Performance issues**: Ensure Xdebug is disabled in production
3. **Memory errors**: Increase `memory_limit` in php.ini
4. **Upload issues**: Check both `upload_max_filesize` and `post_max_size`

### IDE Configuration

#### VS Code
1. Install PHP Debug extension
2. Configure launch.json:
```json
{
    "name": "Listen for Xdebug",
    "type": "php",
    "request": "launch",
    "port": 9003,
    "pathMappings": {
        "/var/www/html": "${workspaceFolder}"
    }
}
```

#### PhpStorm
1. Go to Settings → Languages & Frameworks → PHP → Debug
2. Set Xdebug port to 9003
3. Configure path mappings if needed
4. Set `XDEBUG_IDEKEY=PHPSTORM`
