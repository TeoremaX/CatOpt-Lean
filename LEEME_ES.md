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
