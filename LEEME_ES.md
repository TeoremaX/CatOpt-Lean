# CatOpt-Lean — guía breve

CatOpt-Lean es un prototipo de investigación desarrollado con **Lean 4 y Mathlib** para estudiar cómo describir, componer y verificar algoritmos de optimización. El repositorio incluye un lenguaje tipado para estrategias de búsqueda y un caso de estudio del problema del viajante (TSP).

La versión actual es **v0.10.0**. El código formal ha compilado y las pruebas de regresión han pasado, pero todavía no se trata de una herramienta de optimización de producción ni de una contribución científica publicada.

## Qué contiene

- Una representación de problemas de minimización con restricciones de factibilidad.
- Transformaciones que preservan soluciones factibles y un lenguaje de búsqueda cuyos tipos impiden determinadas combinaciones incorrectas.
- Pruebas de que una política de aceptación elitista no empeora la mejor solución conservada.
- Modelos finitos de VNS y GVNS con semillas deterministas, búsqueda local y un contador de consultas explícitas a la función objetivo.
- Rutas TSP representadas como permutaciones y movimientos de inversión de segmentos 2-opt.
- Un verificador que comprueba si una ruta es óptima **localmente** respecto a todos los segmentos considerados.
- Un ejecutable que recibe rutas y matrices externas, valida los datos y ejecuta esa comprobación en Lean.

## Cómo probarlo

Desde la carpeta del repositorio, con Lean 4.32.0 y Python instalados:

```powershell
lake exe cache get
lake build
lake exe catopt-demo
py -m unittest discover -s experiments -p "test_*.py" -v
py scripts/check_external_cli.py
```

Para verificar una ruta de ejemplo:

```powershell
lake exe catopt-certify experiments/fixtures/square-accepted.cert
```

El programa devuelve `ACCEPTED` cuando la ruta supera el comprobador, `REJECTED` si existe un movimiento 2-opt que la mejora e `INVALID` para entradas mal formadas. Los códigos de salida son 0, 1 y 2, respectivamente.

Los archivos de certificado usan una matriz cuadrada de distancias enteras no negativas y una permutación de ciudades. Se admiten distancias asimétricas. El límite actual es de 32 ciudades, porque se trata de un comprobador exhaustivo.

## Qué está demostrado y qué no

Las pruebas establecen propiedades del **modelo Lean**: factibilidad, conservación de permutaciones, no empeoramiento del incumbente bajo aceptación elitista y corrección de la comprobación de optimalidad local.

No demuestran que una ruta aceptada sea globalmente óptima ni que un algoritmo Python esté formalmente verificado. Los contadores registran consultas definidas dentro del modelo, no tiempo de procesador. Las semillas del modelo no constituyen una prueba de comportamiento probabilístico.

La versión v0.10 compiló con 17.376 trabajos Lean. También pasaron 24 tests Python y nueve casos de integración del comprobador de certificados. Son resultados de ejecución local, no una auditoría formal independiente del proyecto completo.

## Archivos principales

- [README principal](README.md): vista general en inglés.
- [Fundamentos matemáticos](docs/formulation.md): espacios, transformaciones y programas.
- [Síntesis tipada](docs/synthesis.md): generación de recetas de búsqueda.
- [TSP y 2-opt](docs/tsp-two-opt.md): rutas y operadores.
- [Certificados externos](docs/external-certificates-v10.md): formato y garantías.
- [Estado de verificación](docs/verification-status.md): comprobaciones realizadas.
- [Trabajo pendiente](docs/roadmap.md): objetivos de investigación.

El repositorio se mantendrá como prototipo mientras se trabaja en una posible contribución científica que pueda evaluarse frente a la literatura y reproducirse experimentalmente.
