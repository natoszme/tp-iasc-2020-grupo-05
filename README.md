## Levantar la aplicación
`PORT=9001 iex --sname test -S mix run lib/automaticAuctions.ex`

## Tests (sin Docker)
`PORT=9001 iex --sname test -S mix test`. Para correr un test en específico, correr `PORT=9001 iex --sname test -S mix test path_to_test.exs`

## Levantar una imagen de Docker con la aplicación
`make run PORT=9001`

# Subastas Automáticas
## TP Grupal - IASC 1C2020

- [Contexto](#contexto)
- [Las tecnologías](#las-tecnologías)
- [Formato de entrega y evaluación](#formato-de-entrega-y-evaluación)
- [Escenarios](#escenarios)
  - [Escenario 1: Adjudicación Simple](#escenario-1-adjudicación-simple)
  - [Escenario 2: Adjudicación con Competencia](#escenario-2-adjudicación-con-competencia)
  - [Escenario 3: Cancelación de la Subasta](#escenario-3-cancelación-de-la-subasta)
  - [Escenario 4: Registración en tiempo real](#escenario-4-registración-en-tiempo-real)
  - [Escenario 5: Subastas múltiples](#escenario-5-subastas-múltiples)
  - [Escenario 6: Caída del servidor](#escenario-6-caída-del-servidor)
  - [Escenario 7: Falta de memoria en el servidor](#escenario-7-falta-de-memoria-en-el-servidor)

### Contexto

Queremos implementar un servicio HTTP de subastas automáticas, en el cual:
* Se publicarán artículos (los cuales se representarán mediante un documento JSON sin esquema) bajo una lista de tags;
* Se notificará a todos los potenciales compradores;
* Y los compradores podrán ofertar y eventualmente adquirir el producto. 

Es importante notar que el servicio no es el backend de una aplicación de venta de productos para usuarios finales (como MercadoLibre), sino un servicio independiente en el que los compradores serán programas cliente que ofertarán según decisiones automatizadas, de forma similar a los un ATS. La lógica de compra que implementarán estos clientes está fuera del alcance del proyecto. 

En esta primera etapa vamos a construir una prueba de concepto de la arquitectura, con los siguientes requerimientos: 
* Debe soportar acceso concurrente de múltiples usuarios;
* Debe poder escalar horizontalmente de forma automática;
* Debe ser tolerante a fallos tanto de red como de implementación;
* Debe maximizar la disponibilidad de los datos y su velocidad de acceso;
* Toda la operatoria del servicio debe ocurrir en memoria y no se debe nunca persistir a disco, por cuestiones legales y de performance (o quizás sólo porque el arquitecto de turno se encaprichó :P).
* Es deseable que el despliegue se haga mediante contenedores Docker. 

En esta primera no se tendrán en cuenta cuestiones de seguridad; se asumirá que todos los clientes y servidores están dentro de una red segura. 

### Las tecnologías

Se podrá utilizar cualquier tecnología que aplique alguno de los siguientes conceptos vistos en la cursada:
* Paso de mensajes basado en actores
* Continuaciones explícitas (CPS)
* Promises## Levantar la aplicación
`PORT=9001 iex --sname test -S mix run lib/automaticAuctions.ex`

## Levantar una imagen de Docker con la aplicación
`make run PORT=9002`
* Memoria transaccional
* Corrutinas

Obviamente, lo más simple es basarse en Elixir/OTP, Haskell, o Node.js, que son las tecnologías principales que vimos en la materia. 

Otras opciones son tecnologías basadas en Scala/Akka, Go, Clojure y Rust, pero ahi te podremos dar menos soporte

### Formato de entrega y evaluación

Se deberá construir el sistema descrito, tanto el servidor como clientes de prueba. No es obligatoria la construcción de casos de prueba automatizados, pero constituye un gran plus. 

Se evaluará que:
* El sistema cumpla con los requerimientos planteados
* Haga un uso adecuado de la tecnología y los conceptos explicados en la materia
* La arquitectura sea distribuida

### Escenarios 

En lugar de describir el dominio, vamos a presentarlo a través de algunos escenarios.

#### Escenario 1: Adjudicación Simple

* Un comprador A se registra en el sistema mediante un POST a /buyers, expresando así su interés por participar en subastas, indicando: 
  * Un nombre lógico
  * Su ip
  * Los tags de su interés
* Otro comprador B se registra de igual forma en el sistema
* Un vendedor crea una subasta, mediante un POST a /bids con la siguiente información
  * Tags
  * Un precio base (que puede ser cero)
  * La duración máxima de la subasta
  * El JSON del artículo
* El sistema publica la subasta a todos los compradores (en este caso, a los compradores A y B). 
  * Esta y las demás a partir de este punto deben realizarse contra endpoints HTTP a criterio del equipo. 
* El comprador A publica un precio X
  * El sistema le notifica que su oferta fue aceptada
  * Los demás compradores (B en este caso) son notificados de un nuevo precio
* Al cumplirse el timeout:
  * La subasta cierra,
* Se adjudica a A como el comprador, y se le notifica apropiadamente
* B es notificado de la finalización de la subasta y de que no le fue adjudicada

#### Escenario 2: Adjudicación con Competencia

Similar al escenario anterior, pero antes de terminar la subasta, B oferta un precio mayor, y al cumplirse el plazo, se le adjudica a éste. 

Obviamente, este proceso de superar la oferta anterior puede repetirse indefinidamente mientras la subasta esté abierta. 

#### Escenario 3: Cancelación de la Subasta

Similar a los escenarios anteriores, pero el vendedor cancela la subasta antes de la expiración de la subasta y adjudicación del ganador. En este caso, obviamente, nadie gana la subasta, y todos los compradores son notificados.

#### Escenario 4: Registración en tiempo real

Similar a los escenarios anteriores, pero un tercer participante, C, se registra después de que la subasta inició y antes de que termine. C podrá hacer ofertas y ganar la subasta como cualquier otro participante (A y B, en este caso)

#### Escenario 5: Subastas múltiples

Mientras una subasta está en progreso, un vendedor (que puede ser el mismo de la anterior u otro) crea una nueva subasta, y las dos subastas estarán en progreso en simultáneo, funcionando cada una de ellas como siempre.  

#### Escenario 6: Caída del servidor

Con la subasta ya en progreso, el servidor abruptamente falla por un error de hardware. En no más de 5 segundos un segundo servidor debe levantarse y continuar con la subasta. 
Esto significa que de alguna forma los clientes tienen que dejar de hablar con el servidor caído, para empezar a hablar con el nuevo servidor.   

Vamos a considerar en el error kernel (es decir, los datos que no podemos perder) a:
* La existencia de la subasta y sus datos
* Si empezó
* Y si terminó, con qué precio y a quien se le adjudicó
* La mayor oferta aceptada hasta ahora dentro de la subasta

Cuando se produce una caída, se debería extender el plazo de la subasta en 5 segundos. 

#### Escenario 7: Falta de memoria en el servidor

Si al registrar una subasta, el servidor detecta que no entrará en la memoria, esta debe ser transferida al primer servidor con memoria suficiente para contenerla. Aunque es deseable que este proceso se transparente para los vendedores y vendedores, no es esencial en esta etapa.
