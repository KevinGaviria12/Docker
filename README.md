# Proyecto ADSO - Spring Boot + JWT + PostgreSQL

Este proyecto es una API con autenticación JWT, migrada de repositorios en memoria a PostgreSQL usando Spring Data JPA y desplegada en Render.

## Características
- Registro y login con JWT.
- Roles `ADMIN` y `USER` protegidos vía Spring Security.
- Persistencia en PostgreSQL (entidades `User` y `Product`).
- Configuración externa por variables de entorno (puerto, credenciales DB, JWT secret).
- Dockerfile multi-stage y `docker-compose.yml` para desarrollo local.

## Despliegue público
- URL: https://docker-9qi0.onrender.com
- Nota: La instancia gratuita de Render se “duerme” por inactividad. La primera petición tras un rato puede tardar ~50 s en responder.

## Requisitos
- Java 17
- Maven Wrapper incluido (`mvnw`)
- Docker y Docker Compose

## Ejecutar local (sin Docker)
```bash
./mvnw spring-boot:run
```
La app por defecto corre en `http://localhost:8080`.

## Construir jar
```bash
./mvnw clean package -DskipTests
```

## Ejecutar con Docker Compose (app + PostgreSQL)
```bash
docker compose up --build
```
Endpoints disponibles (con prefijo `/api`):
- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/products` (público)
- `POST /api/products` (ADMIN)

## Pruebas rápidas (Render)
Puedes probar desde Postman o con PowerShell/cURL. No necesitas Docker local para probar el despliegue.

Credenciales iniciales:
- Administrador: `admin` / `admin123`

1) Login ADMIN (obtener token)
- URL: `POST https://docker-9qi0.onrender.com/api/auth/login`
- Body (JSON):
```json
{
   "username": "admin",
   "password": "admin123"
}
```
- Respuesta esperada: `{ "token": "eyJhbGciOi..." }`

2) Crear producto (requiere token ADMIN)
- URL: `POST https://docker-9qi0.onrender.com/api/products`
- Header: `Authorization: Bearer <pega-tu-token>`
- Body (JSON):
```json
{
   "name": "Laptop",
   "price": 1500.00,
   "stock": 10
}
```

3) Listar productos (público)
- URL: `GET https://docker-9qi0.onrender.com/api/products`

4) Registrar nuevo usuario (rol USER)
- URL: `POST https://docker-9qi0.onrender.com/api/auth/register`
- Body (JSON):
```json
{
   "username": "kevin",
   "password": "test123",
   "role": "USER"
}
```

5) Validar permisos
- Haz login con el usuario USER anterior y trata de crear un producto (paso 2). Debe responder `403 Forbidden` (solo ADMIN crea).

### Ejemplos en PowerShell
```pwsh
# Login admin
$resp = Invoke-WebRequest -Uri "https://docker-9qi0.onrender.com/api/auth/login" -Method POST -ContentType "application/json" -Body '{"username":"admin","password":"admin123"}' -UseBasicParsing
$token = ($resp.Content | ConvertFrom-Json).token

# Crear producto con token ADMIN
Invoke-WebRequest -Uri "https://docker-9qi0.onrender.com/api/products" -Method POST -ContentType "application/json" -Headers @{Authorization="Bearer $token"} -Body '{"name":"Laptop","price":1500.00,"stock":10}' -UseBasicParsing

# Listar productos (público)
Invoke-WebRequest -Uri "https://docker-9qi0.onrender.com/api/products" -Method GET -UseBasicParsing
```

### Problemas comunes
- 403 Forbidden en `/api/auth/login`: verificar que el body sea JSON y `Content-Type: application/json` (en Postman: Body → raw → JSON).
- 401/403 al crear productos: falta el header `Authorization: Bearer <token>` o el token es de un usuario `USER` (solo `ADMIN` puede crear).
- Respuesta lenta inicial: instancia suspendida en Render (franja gratuita). Esperar ~50 s la primera petición.

## Variables de entorno principales
| Variable | Descripción | Default |
|----------|-------------|---------|
| `SERVER_PORT` | Puerto HTTP interno | 8080 |
| `SPRING_DATASOURCE_URL` | JDBC URL | jdbc:postgresql://localhost:5432/adso |
| `SPRING_DATASOURCE_USERNAME` | Usuario DB | adso |
| `SPRING_DATASOURCE_PASSWORD` | Password DB | adso |
| `SPRING_JPA_HIBERNATE_DDL_AUTO` | Estrategia schema | update |
| `JWT_SECRET` | Clave Base64 JWT | valor de ejemplo |

## Despliegue en plataforma gratuita
Ejemplos de plataformas:
- **Render.com** (Web Service + PostgreSQL free tier limitado).
- **Railway.app** (PostgreSQL y servicio container con créditos mensuales).
- **Fly.io** (Deploy container + volumen PostgreSQL).
- **Koyeb.com** (Deploy container rápido, base de datos externa).

### Pasos generales (Render)
1. Crear cuenta en Render.
2. Crear servicio de PostgreSQL y copiar credenciales.
3. Crear Web Service desde el repo GitHub (asegúrate de publicar el repo). 
4. En "Environment Variables" agregar:
   - `SPRING_DATASOURCE_URL=jdbc:postgresql://<host>:5432/<db>`
   - `SPRING_DATASOURCE_USERNAME=...`
   - `SPRING_DATASOURCE_PASSWORD=...`
   - `SPRING_JPA_HIBERNATE_DDL_AUTO=update`
   - `JWT_SECRET=<clave Base64>`
   - `SERVER_PORT=8080`
5. Render detectará el Dockerfile automáticamente (o usar build command `./mvnw clean package -DskipTests` y start `java -jar target/*.jar`).

### Build & Run sin Dockerfile (alternativo)
Si la plataforma builda desde código fuente:
- Build command: `./mvnw clean package -DskipTests`
- Start command: `java -jar target/adso-0.0.1-SNAPSHOT.jar`

## Generar nueva clave JWT
Debe ser una cadena suficientemente larga (mínimo 256 bits para HS256), luego convertir a Base64.
```bash
# Ejemplo simple (Linux/Mac WSL):
openssl rand -base64 48
```

## Limpieza de datos
Para resetear datos locales:
```bash
docker compose down -v
```

## Próximos pasos sugeridos
- Añadir endpoints Actuator (`spring-boot-starter-actuator`) para health checks.
- Añadir validaciones con `spring-boot-starter-validation`.
- Configurar migraciones con Flyway o Liquibase.

## Licencia
Uso interno / educativo.
