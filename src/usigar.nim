## USIGAr
## ======
##
## - API del `Normalizador de Direcciones de la Ciudad autonoma de Buenos Aires (CABA) y Area Metropolitana de Buenos Aires (AMBA). <http://servicios.usig.buenosaires.gob.ar/normalizar>`_ para `Nim. <https://nim-lang.org>`_
## .. raw:: html
##   <video src="argentina.mp4" muted autoplay loop width=300 height=400 ></video>
import asyncdispatch, httpclient, json, strformat, strutils, uri

const
  usigar_api_url* =
    when defined(ssl): "https://servicios.usig.buenosaires.gob.ar/normalizar/?" ## Base API URL for all API calls (SSL).
    else: "http://servicios.usig.buenosaires.gob.ar/normalizar/?" ## Base API URL for all API calls (No SSL).
  header_api_data = {"dnt": "1", "accept": "application/vnd.api+json", "content-type": "application/vnd.api+json"}
  valid_tipoResultado = ["calle_y_calle", "calle_altura", "calle_altura_calle_y_calle"]  ## Valores Validos para tipoResultado.
let json_api_headers = newHttpHeaders(header_api_data) ## HTTP Headers for JSON APIs.

type
  USIGArBase*[HttpType] = object  ## Base Object
    proxy*: Proxy  ## Network IPv4 / IPv6 Proxy support, Proxy type.
    timeout*: byte  ## Timeout Seconds for API Calls, byte type, 0~255.
  USIGAr* = USIGArBase[HttpClient]           ## USIGAr API  Sync Client.
  AsyncUSIGAr* = USIGArBase[AsyncHttpClient] ## USIGAr API Async Client.

template proxi(this: untyped): untyped =
  ## Template to use Proxy when its declared.
  when declared(this.proxy): this.proxy else: nil

proc apicall(this: USIGAr | AsyncUSIGAr, api_url: string): Future[JsonNode] {.multisync.} =
  let client =
    when this is AsyncUSIGAr: newAsyncHttpClient(proxy=proxi(this))
    else: newHttpClient(timeout=this.timeout.int * 1000, proxy=proxi(this))
  client.headers = json_api_headers
  let response =
    when this is AsyncUSIGAr: await client.get(api_url)
    else: client.get(api_url)
  result = parseJson(await response.body)

proc normalizar*(this: USIGAr | AsyncUSIGAr, direccion="", maxOptions=10,
                 geocodificar=false, srid=4326, lat=0.0, lng=0.0,
                 tipoResultado="calle_y_calle"): Future[JsonNode] {.multisync.} =
  ## Normaliza una direccion de la Ciudad autonoma de Buenos Aires (CABA) y Area Metropolitana de Buenos Aires (AMBA).
  assert tipoResultado in valid_tipoResultado, "tipoResultado must be one of " & $valid_tipoResultado
  let
    a = if direccion.len > 1: fmt"&direccion={encodeUrl(direccion.strip)}" else: ""
    b = fmt"&maxOptions={maxOptions}"
    c = fmt"&geocodificar={geocodificar}"
    d = if geocodificar: fmt"&srid={srid}" else: ""
    e = if lat != 0.0: fmt"&lat={lat}" else: ""
    f = if lng != 0.0: fmt"&lng={lng}" else: ""
    x = fmt"tipoResultado={tipoResultado}" # No & here, must be 1st
  result = await this.apicall(usigar_api_url & x & a & b & c & d & e & f)




# De aca para abajo ya es codigo opcional, es solo para ejemplos, doc, etc.
runnableExamples: # "nim doc usigar.nim" corre estos ejemplos y genera documentacion.
  import asyncdispatch, json
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


when is_main_module and defined(release):
  import parseopt, terminal, random
  var
    minusculas: bool  # API puede devolver un case raro,forzar todo lowercase.
    maxOptions = 10
    geocodificar = false
    srid = 4326
    lat = 0.0
    lng = 0.0
    tipoResultado = "calle_y_calle"
  for tipoDeClave, clave, valor in getopt():
    case tipoDeClave
    of cmdShortOption, cmdLongOption:
      case clave
      of "version":             quit("0.1.5", 0)
      of "license", "licencia": quit("MIT", 0)
      of "help", "ayuda":       quit("""./usigar --color --minusculas --maxOptions=9 --geocodificar=true --srid=4326 --tipoResultado="calle_altura" "callao y corrientes, caba" """, 0)
      of "maxOptions":          maxOptions = parseInt valor
      of "geocodificar":        geocodificar = parseBool valor
      of "srid":                srid = parseInt valor
      of "lat":                 lat = parseFloat valor
      of "lng":                 lng = parseFloat valor
      of "tipoResultado":       tipoResultado = valor.strip.toLowerAscii
      of "minusculas":          minusculas = true
      of "color":
        randomize()
        setBackgroundColor(bgBlack)
        setForegroundColor([fgRed, fgGreen, fgYellow, fgBlue, fgMagenta, fgCyan, fgWhite].rand)
    of cmdArgument:
      let
        clientito = USIGAr(timeout: 99)
        resultadito = clientito.normalizar(direccion=clave.strip.toLowerAscii,
        maxOptions=maxOptions, geocodificar=geocodificar, srid=srid,
        lat=lat, lng=lng, tipoResultado=tipoResultado).pretty
      if minusculas: echo resultadito.toLowerAscii else: echo resultadito
    of cmdEnd: quit("Los Parametros son incorrectos, ver Ayuda con --ayuda", 1)
