# CatOpt-Lean — Guía rápida en español

**Qué has recibido:** un repositorio de investigación preparado para publicarse,
con código Lean 4, una propuesta matemática rigurosa, un lenguaje de
composición de algoritmos, tres familias de búsqueda, un experimento TSP con
resultados reproducibles y un borrador de artículo técnico de nueve páginas.

## La idea científica esencial

La intuición `Shake → LocalSearch → Accept` no es suficiente si cada etapa
solo recibe una solución. Hay que distinguir la solución *incumbente* (la
mejor aceptada hasta ahora) de la *candidata* (que puede empeorar al
perturbarla).

CatOpt-Lean define:

1. Una categoría de espacios cuyos morfismos preservan factibilidad.
2. Un estado de búsqueda con incumbente y candidato factibles.
3. Un DSL indexado por fases: `ready → candidate → improved → ready`.
4. Una interpretación matemática que respeta composición, identidad y
   asociatividad a nivel semántico.
5. Un teorema general: el **coste del incumbente** no aumenta durante
   programas correctamente tipados con aceptación elitista.

Este teorema **no dice** que el candidato mejore siempre, ni que se alcance el
óptimo global. La categoría no se presenta como un resultado novedoso en sí.

## Estado real del proyecto

- **Python:** cinco tests ejecutados con éxito.
- **Experimentos:** 135 ejecuciones (15 semillas por algoritmo e instancia),
  tres instancias TSP pequeñas, óptimos exactos mediante Held–Karp.
- **Artículo:** PDF de nueve páginas y código fuente LaTeX incluidos.
- **Lean:** los archivos con declaraciones y pruebas están escritos, pero no
  se han podido comprobar con el compilador en este entorno. Antes de poner
  "formally verified" en GitHub, **ejecuta `lake build` y comprueba que
  pasa**. GitHub Actions está configurado precisamente para hacerlo.

## Instalar y ejecutar

1. Instala Git, VS Code y la extensión de Lean 4. Instala Lean mediante
   [elan](https://lean-lang.org/install/). Puedes trabajar en Windows
   directamente o en WSL2.
2. Descomprime el ZIP. Abre la carpeta `CatOpt-Lean` en VS Code.
3. Abre una terminal en esa carpeta y ejecuta:

```bash
lake update
lake exe cache get
lake build
lake exe catopt-demo
```

4. Para los experimentos (solo necesitas Python 3.11+):

```bash
python3 -m unittest discover -s experiments -p 'test_*.py' -v
python3 experiments/run_benchmark.py --runs 15 --budget 5000
```

En Windows, si `python3` no se reconoce, utiliza `py` o `python`. Después del
primer `lake update` correcto, añade al commit el `lake-manifest.json` que
se haya generado: es importante para fijar dependencias.

## Orden recomendado para aprender y revisar el código

- **Día 1:** `CatOpt/Basic.lean` y `CatOpt/Operators.lean`.
- **Día 2:** `CatOpt/Category.lean` y las leyes categóricas.
- **Día 3:** `CatOpt/Properties.lean`, especialmente la aceptación.
- **Día 4:** `CatOpt/DSL/Syntax.lean` y `CatOpt/DSL/Semantics.lean`.
- **Día 5:** `CatOpt/DSL/Search.lean`, `program_monotone`, `denote_run`.
- **Día 6:** las tres familias `CatOpt/Algorithms/` y el caso de estudio.
- **Día 7:** `docs/formulation.md`, `docs/related-work.md` y el artículo.

## Subir a GitHub

Desde la carpeta raíz y después de revisar que `lake build` pasa:

```bash
git init
git branch -M main
git add .
git commit -m "Initial CatOpt-Lean research prototype"
git remote add origin https://github.com/TU_USUARIO/CatOpt-Lean.git
git push -u origin main
```

Primero crea el repositorio vacío en GitHub. Si prefieres usar GitHub CLI,
consulta `docs/github.md`.

## Cómo contárselo a un investigador

> Estoy desarrollando un framework de optimización composicional en Lean 4.
> Formalizo una categoría de transformaciones que preservan factibilidad,
> un DSL tipado por fases y propiedades estructurales sobre incumbentes.
> Lo interesante no es que los algoritmos compongan funciones, sino imponer
> contratos que sobreviven a la composición y estudiar hasta qué punto
> permiten sintetizar algoritmos válidos automáticamente. Por ahora el
> modelo es un prototipo con aceptación elitista y las pruebas aún deben
> superar la verificación final del compilador.

**Para convertirlo en un resultado investigador serio:** terminar la
compilación Lean, ampliar a espacios heterogéneos, formalizar un funtor desde
la categoría libre de programas (no solo la interpretación), verificar 2-opt
y VND de forma fiel, y estudiar bibliografía de hiperheurísticas y diseño
automático de algoritmos.
