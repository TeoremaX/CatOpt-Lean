# CatOpt-Lean v0.3 — guía en español

**Qué es:** proyecto de investigación experimental en Lean 4 + Mathlib sobre
lenguajes tipados para algoritmos de búsqueda, preservación de factibilidad,
aceptación elitista y síntesis de programas de optimización. Contiene además
un benchmark TSP independiente en Python y un manuscrito técnico anterior
que **todavía no** describe v0.3.

## Qué está verificado

- **v0.2:** el usuario ejecutó `lake build` en Windows (6013 trabajos),
  `lake exe catopt-demo` (cinco recetas), `check_no_sorry.py` y los cinco
  tests Python. Todo pasó el 15/11/2026.
- **v0.3:** los nuevos archivos están preparados y revisados como fuentes,
  pero **todavía no han pasado por un compilador Lean** en el entorno donde
  se han generado. La verificación nueva debe completarse en tu ordenador.

## Matemáticas fundamentales

Hay dos soluciones factibles en el estado: incumbente y candidato. Una
perturbación puede empeorar el candidato sin empeorar el incumbente. La
aceptación elitista elige la mejor de las dos según la función objetivo y
sincroniza los dos campos. `CatOpt/DSL/Search.lean` contiene el teorema
`program_monotone` para operadores que preservan factibilidad.

El DSL distingue tres etapas:

```text
ready → candidate → improved → ready
```

No pretendemos haber inventado la composición de algoritmos; el valor
investigador dependerá de propiedades nuevas, representaciones fieles y
experimentos rigurosos.

## Novedad en v0.3: qué mide el contador

`CatOpt/DSL/Resources.lean` define `probe P x`, que consulta explícitamente
`P.cost x` y registra una observación. `probeMany` es un cliente cerrado
que solo consulta el objetivo mediante `probe`: el teorema establece
`queries = xs.length` y los valores coinciden con `xs.map P.cost`.

`runMetered` interpreta el DSL preexistente y registra dos consultas por
`accept`. Los teoremas expresan que el resultado es el mismo que el del
intérprete anterior y que se conserva la monotonía del incumbente.

**Advertencia:** `construct`, `shake`, `destroyRepair` y `localSearch` aún son
funciones opacas que *pueden consultar el objetivo sin pasar por `probe`*.
El contador de `runMetered` registra únicamente las observaciones explícitas
de aceptación, **no el total de evaluaciones de la metaheurística**. No hay
prueba sobre tiempo real, RAM, evaluación total de TSP o refinamiento de Python.

## Novedad de v0.4: selección de vecinos con consultas medidas

El módulo `CatOpt/DSL/OracleLocalSearch.lean` recibe una lista de soluciones
factibles **ya construidas** y selecciona la mejor sin empeorar la solución
inicial. Cada comparación invoca dos veces `probe`; se han escrito teoremas
sobre la equivalencia con una selección pura y el número exacto de consultas
(`2 × número_de_vecinos`). La aceptación añade dos consultas más.

**Límite importante:** todavía no contabilizamos la generación de la lista de
vecinos, ni los algoritmos GRASP/GVNS/IG originales. La garantía corresponde
al selector cerrado y su aceptación, no al coste total de la metaheurística.
Consulta `docs/oracle-local-search.md`.

## Commits por fase

He preparado un parche v0.4 con `apply_v04.ps1` que distribuye los cambios en
**tres commits** y compila Lean antes de confirmar los cambios. Sigue
`docs/git-workflow.md`. No modifica ni publica tu repositorio remoto sin tu
acción. El historial de v0.3 debe estar confirmado primero (`git status`
limpio). El script se ejecuta desde la carpeta donde extraigas el parche.

## Archivos para leer

- `CatOpt/DSL/Resources.lean`: semántica de consultas y pruebas.
- `CatOpt/Tests/Resources.lean`: ejemplos comprobables por Lean.
- `CatOpt/Examples/Resources.lean`: ejemplos ejecutables.
- `docs/resources.md`: especificación de las garantías y límites.
- `docs/novelty-audit.md`: antecedentes y auditoría de originalidad.
- `docs/publication-plan.md`: plan científico y criterios de publicación.
- `docs/verification-status.md`: qué compilaciones realmente han ocurrido.

## Instalación del parche

Descomprime el ZIP `CatOpt-Lean-v0.4-parche-commits.zip` sobre la carpeta de tu
proyecto `C:\Users\User\Documents\CatOpt-Lean`, conservando `.git/`,
`.lake/` y `lake-manifest.json`. No es necesario reinstalar Mathlib.

Ejecuta desde PowerShell:

```powershell
lake build
lake exe catopt-demo
py tools/check_no_sorry.py
py -m unittest discover -s experiments -p "test_*.py" -v
```

Si falla la compilación, el módulo nuevo todavía no está verificado.
No publiques afirmaciones de verificación de v0.3 hasta que `lake build`
termine correctamente en la revisión exacta que vas a subir a GitHub.

## Qué hacer después

La siguiente fase (v0.5) deberá definir un lenguaje restringido de generación
de vecinos y un control adaptativo, para excluir llamadas opacas al objetivo y
obtener una cota de consultas de extremo a extremo en ese fragmento.

**Originalidad:** la síntesis guiada por recursos (ReSyn), las metaheurísticas
generadas por componentes (MORK) y la mónada de costes `TimeM` (CSLib) ya
existen. El hecho de combinarlas en Lean no basta por sí solo para publicar.

## Versión 0.5 — movimientos finitos y presupuesto de consultas

Se ha añadido `CatOpt/DSL/FiniteNeighborhood.lean`: un pequeño DSL sin funciones de callback para generar vecinos en `Fin (n + 1)`, seguido de selección y aceptación instrumentadas. La ejecución de `fuel` rondas demuestra, cuando Lean compile las nuevas pruebas, que el número de consultas registradas es `fuel * (2 * moves.length + 2)` y que el incumbente no empeora.

El ejemplo parte de 15, utiliza retrocesos 1 y 2, ejecuta 3 rondas y está diseñado para obtener 9 con 18 consultas de oráculo. Un certificado `FuelBudget 18` acepta el programa y uno de 17 lo rechaza.

**Límites:** no contamos tiempo de CPU, coste de aritmética, evaluaciones del TSP Python ni operadores antiguos opacos; el controlador no es GVNS adaptativo. Más detalles en `docs/finite-neighborhood.md`. La v0.4 ya compiló (6025 trabajos), pero **v0.5 requiere ejecutar `lake build` en tu equipo**. Para actualizar con commits, utiliza el script `apply_v05.ps1` del ZIP de parche.


## Versión 0.6 — controlador adaptativo de vecindarios

El módulo `CatOpt/DSL/AdaptiveVNS.lean` introduce un catálogo finito y
una política de cambio: ante mejora estricta del incumbente vuelve al primer
vecindario; sin mejora avanza al siguiente. Dos consultas `probe` adicionales
contabilizan esa decisión. Un catálogo con un máximo certificado de `m`
movimientos por vecindario y un `fuel = f` tiene una **cota de consultas
modeladas** de `f * (2*m+4)`. La ejecución conserva la factibilidad y no
empeora el incumbente.

**Precisión científica:** no es todavía un GVNS completo: falta la perturbación
aleatoria y la búsqueda VND interna. Tampoco se ha verificado el TSP de Python
ni hay una cota temporal real. La compilación Lean de v0.6 fue **confirmada** (6037 trabajos);
v0.5 sí compiló en el ordenador del usuario (6031 trabajos).

Para instalar v0.6 conservando los commits, utilizar el ZIP del parche y
`apply_v06.ps1`; véase `docs/git-workflow.md` y `docs/adaptive-vns.md`.


## v0.7 — Perturbación por semilla y búsqueda VND interna

El módulo `CatOpt/DSL/SeededGVNS.lean` compone una perturbación de primer orden
sin acceso a la función objetivo con un VND acotado y una aceptación elitista
externa. Demuestra, una vez compilado por Lean, monotonía y la cota de
consultas instrumentadas `f * (t*(2*m+4)+2)`. El ejemplo pasa de 15 a 15
y luego a 12, con 28 consultas registradas.

**La semilla es determinista, no una distribución aleatoria formal.**
Esta capa no verifica el TSP en Python ni el tiempo real. Consulta
`docs/seeded-gvns.md` y no anuncies una v0.7 verificada sin `lake build`.


## v0.8 — Rutas TSP como permutaciones verificables

La nueva representación `Tour n = Equiv.Perm (Fin (n+1))` garantiza que
una ruta contiene cada ciudad **exactamente una vez**. Los segmentos
contiguos `Segment n` se invierten mediante `twoOpt`, preservando la
permutación y cumpliendo `twoOpt (twoOpt t s) s = t`.

Hemos añadido una instancia de cuatro ciudades, una función de coste
cíclico que incluye el regreso al origen, selección elitista y un contador
exacto de consultas de la semántica Lean: `fuel*(2*m+2)` para una paleta
de `m` segmentos. El ejemplo previsto mejora el coste de 6 a 4.

**Aún no se ha compilado v0.8 en Lean.** El usuario sí ha validado v0.7
(6043 trabajos). El archivo Python solo es una referencia independiente:
no hemos demostrado que ambos programas sean equivalentes. Tampoco existe
una garantía de óptimo global o de tiempo real. Lee
`docs/tsp-two-opt.md` y verifica con `lake build` antes de publicar.

## v0.9 — Verificador formal de óptimo local 2-opt

Nuevo `CatOpt/TSP/LocalOptimality.lean`: comprueba exhaustivamente que ninguna
inversión de segmento reduce el coste de una ruta. Sus teoremas en Lean deben
pasar `lake build` antes de declararse verificados. Esto NO demuestra óptimo
global ni valida el ejecutable Python. La revisión bibliográfica y los
criterios para aspirar a un artículo están en `docs/research-positioning-v09.md`.

La fórmula rápida de cuatro aristas de 2-opt requiere simetría. El modelo
del TSP actual NO exige simetría, por lo que el nuevo comprobador evalúa
el coste cíclico completo y no utiliza esa fórmula.
