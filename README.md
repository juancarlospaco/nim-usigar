# Nim-USIGAr

[USIG Argentina](https://servicios.usig.buenosaires.gob.ar/normalizar) MultiSync API Lib for [Nim](https://nim-lang.org)
*(All Docs on Spanish because its for Argentina)*

Este Cliente es Async y Sync al mismo tiempo, es MultiPlataforma, MultiArquitectura,
0 Dependencias, 1 Archivo solo, ~250 Kilobytes Compilado, muy poco uso de RAM.
Soporta Proxy, IPv6, SSL y Timeout. Auto-Documentado.


# Uso

```nim
import usigar, asyncdispatch, json

## Sync client.
let usigar_client = USIGAr(timeout: 9)  # Timeout en Segundos.
## Las consultas son copiadas desde la Documentacion de la API.
echo usigar_client.normalizar(direccion="callao y corrientes, caba").pretty
echo usigar_client.normalizar(direccion="callao y corrientes, moron").pretty
echo usigar_client.normalizar(direccion="callao y corrientes").pretty
echo usigar_client.normalizar(direccion="santa", maxOptions=25).pretty
echo usigar_client.normalizar(direccion="corrientes y santa fe", geocodificar=true).pretty
echo usigar_client.normalizar(direccion="corrientes y santa fe, san isidro").pretty
echo usigar_client.normalizar(direccion="loria e italia").pretty
echo usigar_client.normalizar(direccion="loria 300, lomas").pretty
echo usigar_client.normalizar(direccion="loria 300").pretty
echo usigar_client.normalizar(lng= -58.490674, lat= -34.524909).pretty
echo usigar_client.normalizar(lng= -58.409039, lat= -34.601427).pretty
echo usigar_client.normalizar(lng= -58.402165, lat= -34.762920, tipoResultado="calle_y_calle").pretty
echo usigar_client.normalizar(lng= -58.402165, lat= -34.762920, tipoResultado="calle_altura").pretty

## Async client.
proc async_usigar() {.async.} =
  let
    async_usigar_client = AsyncUSIGAr(timeout: 9)
    async_response = await async_usigar_client.normalizar(direccion="loria 300")
  echo async_response.pretty

wait_for async_usigar()

# Ver la Doc para mas API Calls...
```


# API

- Todas las funciones retornan JSON, tipo `JsonNode`.
- Los nombres siguen los mismos nombres de la Documentacion.
- Los errores siguen los mismos errores de la Documentacion.
- Todas las API Calls son HTTP `GET`.
- El `timeout` es en Segundos.
- Para soporte de Proxy de red definir un `proxy` de tipo `Proxy`.
- No tiene codigo especifico a ningun Sistema Operativo, funciona en Linux, Windows, Mac, etc.


# FAQ

- Funciona sin SSL ?.

Si.

- Funciona con SSL ?.

Si.

- Funciona con codigo Asincrono ?.

Si.

- Funciona con codigo Sincrono ?.

Si.

- Requiere API Key ?.

No.

- Es Pago ?.

No.


# Requisites

- None.
