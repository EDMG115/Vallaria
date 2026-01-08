# Arquitectura del Sistema

## 1. Visión general

La plataforma es un **sistema de aprendizaje de ciencias básicas** (Matemáticas, Física y Química) inspirado en el modelo de Duolingo. Está diseñada con una **arquitectura modular**, escalable y mantenible, separando claramente:

- Consumo de contenido (usuarios)
- Producción de contenido (editor/admin)
- Lógica de negocio (backend)
- Persistencia estructural (base de datos)
- Almacenamiento de contenido pesado (archivos)

El objetivo principal es permitir crecer el sistema sin reescrituras profundas.

---

## 2. Principios de diseño

- **Separación de responsabilidades**
- **Backend único, múltiples interfaces**
- **Base de datos para estructura y estado**
- **Sistema de archivos para contenido pesado (Lecciones con figuras, formulas, etc.)**
- **Frontend desacoplado del almacenamiento**

---

## 3. Arquitectura general

```
Vallaria
    Backend (API)
        Lógica de negocio
        Seguridad y permisos
        Acceso a BD
        Acceso a almacenamiento
    
    Frontend Usuario
        Aplicación de aprendizaje
    
    Frontend Admin
        Editor de cursos y lecciones

    Base de Datos
        Estructura, relaciones y progreso

    Almacenamiento
        Markdown, JSON, imágenes
```

---

## 4. Estructura del proyecto

```
Vallaria/
    backend/
        app/
            main.py
            config/
            core/
            api/
            services/
            repositories/
            models/
            security/
            utils/
        migrations/
        tests/
        requirements.txt
    frontend-user/
    frontend-admin/
    storage/
        lessons/
        images/
        exports/
    database/
        schema.sql
        seed.sql
        diagrams/
    scripts/
    docs/
    README.md
```

---

## 5. Backend

### 5.1 Responsabilidad

El backend es el **núcleo del sistema**. Expone una API REST que:

- Gestiona cursos, unidades, lecciones y ejercicios
- Controla permisos (usuario vs administrador)
- Controla el acceso a BD y almacenamiento
- Valida estructura y contenido

### 5.2 Capas internas

- **api/**: endpoints HTTP separados por rol
- **services/**: lógica de negocio
- **repositories/**: acceso a datos (SQL y storage)
- **models/**: modelos de dominio
- **security/**: autenticación y autorización

---

## 6. Base de Datos

### 6.1 Qué se guarda en la BD

La base de datos almacena **estructura y estado**, nunca contenido pesado.

Incluye:

- Materias
- Cursos
- Unidades
- Lecciones
- Usuarios
- Progreso del usuario

### 6.2 Ejemplo lógico

```
Materia -> Curso -> Unidad -> Lección -> Ejercicio
```

Ejemplo de tabla `lecciones`:

```
lecciones
- id
- unidad_id
- titulo
- teoria_path
- ejercicios_path
- soluciones_path
- dificultad
- orden
- xp

```

`teoria_path` referencia un archivo Markdown en `storage/`.
`ejercicios_path y soluciones_path` a diferencia de teoria_path que se trabaja como .md, los ejercicios y soluciones estaran dispuestos como archivos json, para facilitar su interpretación y evitar grandes cantidades de datos en la BD.

**Ejemplo:**

{
  "lesson_id": 42,
  "type": "algebra",
  "exercises": [
    {
      "ejercicio_uid": "ex_1",
      "kind": "multiple_choice",
      "question": "¿Cuál es la solución de $2x + 3 = 7$?", 
      "options": ["1", "2", "3", "4"],
      "answer": "2",
      "difficulty": 1,
      "xp": 10
    }
  ]
}

- $2x + 3 = 7$? Dadas las $, se puede interpretar como formula en LaTeX

---

## 7. Almacenamiento (storage/)

### 7.1 Propósito

El almacenamiento contiene **contenido pesado y estático**, separado de la BD:

- Texto largo
- Fórmulas
- Imágenes
- Archivos exportados

### 7.2 Estructura

```
storage/
    lessons/
        leccion_42/
            teoria.md
            ejercicios.json
            soluciones.json
        figuras/
            grafica.svg
    images/
        materias/
        cursos/
        shared/
```
Donde: 

figuras/

- Representa **imágenes exclusivas de la lección como por ejemplo gráficas, diagramas, esquemas**.

Y storage/images/

- Imágenes **reutilizables o globales**, no ligadas a una sola lección.

---

## 8. Frontend Usuario

### 8.1 Responsabilidad

- Consumir contenido
- Mostrar progreso
- Ejecutar ejercicios
- Gamificación

El frontend **no accede directamente** a la BD ni a archivos.

### 8.2 Estructura

frontend-user/
    index.html
    public/
        icons/
        images/
    src/
        pages/
            Home.html
            Course.html
            Lesson.html
            Exercise.html
            Profile.html
        components/
            CourseCard.html
            LessonPlayer.html
            ExerciseRenderer.html
            ProgressBar.html
            Navbar.html
        services/
            api.js
        utils/
        styles/

**Donde:**
    - **services/:** Es la capa que habla con el backend.
    - **utils/:** Cuenta con funciones auxiliares y reutilizables como interpretar la teoria (Latex probablemente).
    - **styles/:** Todo lo relacionado con estilos visuales (Usando tailwind probablemente).

---

## 9. Frontend Admin (Editor)

### Responsabilidad

- Crear y editar materias, cursos y lecciones
- Editor Markdown + LaTeX
- Subida de imágenes
- Gestión de ejercicios mediante formularios

Es una **interfaz avanzada**, separada del frontend de usuario, para poder subir, editar y eliminar contenido.

### 9.2 Estructura

frontend-admin/
    index.html
    public/
        icons/
    src/
        pages/
            Dashboard.html
            SubjectEditor.html
            CourseEditor.html
            LessonEditor.html
            ExerciseEditor.html 
        components/
            MarkdownEditor.html
            ImageUploader.html
            FormBuilder.html
            PreviewPane.html 
        services/
            api.js
        utils/
        styles/


**Donde:**
    - **services/:** Es la capa que habla con el backend.
    - **utils/:** Cuenta con funciones auxiliares y reutilizables como interpretar la teoria (Latex probablemente).
    - **styles/:** Todo lo relacionado con estilos visuales (Usando tailwind probablemente).


---

## 10. Scripts

La carpeta `scripts/` contiene utilidades fuera del flujo principal:

- Inicializar BD
- Poblar datos de prueba
- Validar contenido
- Importar/exportar cursos
- Backups

---

## 11. Documentación

La carpeta `docs/` contiene documentación técnica viva:

- Arquitectura
- Modelo de datos
- Formato de lecciones
- Convenciones
- API

---

## 12. Evolución futura

- Editor colaborativo
- App móvil
- Alojarlo en un servidor (Mi laptop)

---

## 13. Conclusión

Se busca definir una estructura clara y general para todos los miembros del proyecto y poderdesarrollar con un entendimiento mutuo de la estructura del proyecto

