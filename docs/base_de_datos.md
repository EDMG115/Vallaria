# Arquitectura de Base de Datos

Este documento describe la **estructura, proposito y principios** de la base de datos del Vallaria (sistema de aprendizaje de ciencias básicas (Matematicas, fsica y quimica)), inspirado en plataformas tipo Duolingo.

La base de datos **no almacena cosas pesadas** (teoria, ejercicios, imagenes), sino que se encarga de:
- usuarios
- progreso
- intentos y resultados

El contenido esta en el sistema de archivos y es referenciado desde la BD (en los campos *_path).

---

## 1. Entidades principales

### 1.1 Usuarios

```
usuarios (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(100),
  email VARCHAR(255) UNIQUE,
  fecha_registro TIMESTAMP
)
```

Representa a los usuarios finales de la plataforma.

---

### 1.2 Materias

```
materias (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(100),
  descripcion TEXT
)
```

Ejemplos: Matemáticas, Física, Química.

---

### 1.3 Cursos

```
cursos (
  id SERIAL PRIMARY KEY,
  materia_id INT REFERENCES materias(id),
  nombre VARCHAR(100),
  orden INT
)
```

Ejemplos: Álgebra I, Cálculo I, Mecánica Clásica.

---

### 1.4 Lecciones

```
lecciones (
  id SERIAL PRIMARY KEY,
  curso_id INT REFERENCES cursos(id),
  titulo VARCHAR(255),
  teoria_path TEXT,
  ejercicios_path TEXT,
  soluciones_path TEXT,
  orden INT,
  publicado BOOLEAN
)
```

Las rutas apuntan a archivos en `storage/`.

---

## 2. Progreso del usuario

### 2.1 Progreso por lección

```
progreso_usuario (
  usuario_id INT REFERENCES usuarios(id),
  leccion_id INT REFERENCES lecciones(id),
  vista BOOLEAN,
  completada BOOLEAN,
  fecha_actualizacion TIMESTAMP,
  PRIMARY KEY (usuario_id, leccion_id)
)
```

Indica si el usuario ha visto o completado una lección.

---

## 3. Intentos de ejercicios

### 3.1 Tabla `intentos_ejercicios`

```
intentos_ejercicios (
  id SERIAL PRIMARY KEY,
  usuario_id INT REFERENCES usuarios(id),
  leccion_id INT REFERENCES lecciones(id),
  ejercicio_uid VARCHAR(100),
  respuesta_usuario TEXT,
  es_correcta BOOLEAN,
  puntaje INT,
  fecha_intento TIMESTAMP DEFAULT NOW()
)
```

### Conceptos clave:

- **ejercicio_uid**: identificador logico del ejercicio definido en `ejercicios.json`, es un id, pero para las preguntas en el json. El backend debera buscar dentro del json la pregunta (Es decir, que no esta en la BD).
- Cada fila representa **un intento**, no un ejercicio.
- Los reintentos generan nuevas filas.

---

## 4. Relación con el sistema de archivos

La BD **no conoce el contenido**, solo referencias.

Ejemplo de estructura:

```
storage/
  leccion/
    leccion_42/
      teoria.md
      ejercicios.json
      soluciones.json
```

La BD guarda:

```
teoria_path = "lessons/leccion_42/teoria.md"
```

El backend resuelve la ruta física.

---

## 5. Flujo de datos 

1. El frontend solicita una leccion.
2. El backend consulta la BD.
3. El backend carga archivos desde `storage/`.
4. El usuario responde ejercicios.
5. Cada respuesta genera un registro en `intentos_ejercicios`.
6. El progreso se actualiza en `progreso_usuario`.

---

## 6. Qué NO se guarda en la BD

- Markdown de teoria (Que despues se interpreta como LaTeX en el front)
- Ejercicios completos
- Soluciones detalladas
- Imagenes
- Formulas LaTeX

---
