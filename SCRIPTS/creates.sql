-- Tabla principal de usuarios del sistema
CREATE TABLE CUENTAS_USUARIO (
    cu_id SERIAL PRIMARY KEY,
    username VARCHAR(30) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    rol VARCHAR(1) NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT check_rol CHECK(rol in ('e','p','a')), --estudiante, PROFESORES, autoridad
    CONSTRAINT check_username CHECK(char_length(username) between 2 and 30)
);

-- Tabla para AUTORIDADES educativas
CREATE TABLE AUTORIDADES (
    id SERIAL PRIMARY KEY,
    nombre_aut VARCHAR(50) NOT NULL,
    apellido_aut VARCHAR(50) NOT NULL,
    id_cu_aut INTEGER NOT NULL UNIQUE,
    
    CONSTRAINT fk_cuenta_usuario_autoridad FOREIGN KEY (id_cu_aut) REFERENCES CUENTAS_USUARIO(cu_id),
    CONSTRAINT check_nombre_autoridad CHECK(char_length(nombre_aut) between 2 and 50),
    CONSTRAINT check_apellido_autoridad CHECK(char_length(apellido_aut) between 2 and 50)
);

-- Tabla para ESTUDIANTES
CREATE TABLE ESTUDIANTES (
    est_id SERIAL PRIMARY KEY,
    id_cu_est INTEGER NOT NULL UNIQUE,
    password_random VARCHAR NOT NULL, --Revisar si borrar esta línea
    
    CONSTRAINT fk_cuenta_usuario_estudiante FOREIGN KEY (id_cu_est) REFERENCES CUENTAS_USUARIO(id)
);

-- Tabla para PROFESORES
CREATE TABLE PROFESORES (
    prf_id SERIAL PRIMARY KEY,
    nombre_prf VARCHAR(50) NOT NULL,
    apellido_prf VARCHAR(500) NOT NULL,
    id_aut_prf INTEGER NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT true,
    id_cu_prf INTEGER NOT NULL UNIQUE,
    
    CONSTRAINT fk_autoridad_profesor FOREIGN KEY (id_aut_prf) REFERENCES AUTORIDADES(id),
    CONSTRAINT fk_cuenta_usuario_profesor FOREIGN KEY (id_cu_prf) REFERENCES CUENTAS_USUARIO(id),
    CONSTRAINT check_nombre_profesor CHECK(char_length(nombre_prf) between 2 and 50),
    CONSTRAINT check_apellido_profesor CHECK(char_length(apellido_prf) between 2 and 50)
);

-- Tabla de MATERIAS/académicas
CREATE TABLE MATERIAS (
    mat_id SERIAL PRIMARY KEY,
    nombre_mat VARCHAR(100) NOT NULL,

    CONSTRAINT check_nombre_materia CHECK(char_length(nombre_mat) between 10 and 100)
);

-- Tabla de SECCIONES/grupos
CREATE TABLE SECCIONES (
    sec_id SERIAL PRIMARY KEY,
    nombre_sec VARCHAR(20) NOT NULL,
    capacidad NUMERIC NOT NULL DEFAULT 25,

    CONSTRAINT check_nombre_seccion CHECK(char_length(nombre_sec) between 2 and 20),
    CONSTRAINT check_capacidad_seccion CHECK(capacidad between 15 and 30)
);

-- Tabla de relación muchos a muchos: MATERIAS - ESTUDIANTES
CREATE TABLE MATERIAS_ESTUDIANTES (
    id_me_mat INTEGER NOT NULL,
    id_me_est INTEGER NOT NULL,
    
    CONSTRAINT PK_MATERIAS_ESTUDIANTES PRIMARY KEY (id_me_mat, id_me_est),
    CONSTRAINT fk_me_materias FOREIGN KEY (id_me_mat) REFERENCES MATERIAS(mat_id),
    CONSTRAINT fk_me_estudiantes FOREIGN KEY (id_me_est) REFERENCES ESTUDIANTES(est_id)
);

-- Tabla de relación muchos a muchos: PROFESORES - MATERIAS
CREATE TABLE PROFESORES_MATERIAS (
    id_pm_mat INTEGER NOT NULL,
    id_pm_prof INTEGER NOT NULL,
    
    CONSTRAINT PK_PROFESORES_MATERIAS PRIMARY KEY (id_pm_mat, id_pm_prof),
    CONSTRAINT fk_pm_materias FOREIGN KEY (id_pm_mat) REFERENCES MATERIAS(mat_id),
    CONSTRAINT fk_pm_profesores FOREIGN KEY (id_pm_prof) REFERENCES PROFESORES(prf_id)
);

-- Tabla de relación muchos a muchos: Sección - ESTUDIANTES
CREATE TABLE SECCIONES_ESTUDIANTES (
    id_se_est INTEGER NOT NULL,
    id_se_sec INTEGER NOT NULL,
    
    CONSTRAINT PK_SECCIONES_ESTUDIANTES PRIMARY KEY (id_se_est, id_se_sec),
    CONSTRAINT fk_se_estudiantes FOREIGN KEY (id_se_est) REFERENCES ESTUDIANTES(est_id),
    CONSTRAINT fk_se_secciones FOREIGN KEY (id_se_sec) REFERENCES SECCIONES(sec_id)
);

-- Tabla de relación muchos a muchos: Sección - PROFESORES
CREATE TABLE SECCIONES_PROFESORES (
    id_sp_prof INTEGER NOT NULL,
    id_sp_sec INTEGER NOT NULL,
    
    CONSTRAINT PK_SECCIONES_PROFESORES PRIMARY KEY (id_sp_prof, id_sp_sec),
    CONSTRAINT fk_sp_profesores FOREIGN KEY (id_sp_prof) REFERENCES PROFESORES(prf_id),
    CONSTRAINT fk_sp_secciones FOREIGN KEY (id_sp_sec) REFERENCES SECCIONES(sec_id)
);

-- Tabla histórica de lapsos/clases
CREATE TABLE historico_lapso_clase (
    id SERIAL PRIMARY KEY,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    nombre_lapso VARCHAR(50) NOT NULL,
    id_hlc_est INTEGER NOT NULL,
    id_hlc_prof INTEGER NOT NULL,
    UNIQUE (fecha_inicio, id_hlc_est, id_hlc_prof),
    FOREIGN KEY (id_hlc_est) REFERENCES ESTUDIANTES(est_id),
    FOREIGN KEY (id_hlc_prof) REFERENCES PROFESORES(id)
);

-- Tabla de encuestas
CREATE TABLE encuestas (
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    tipo CHAR(1) NOT NULL DEFAULT 'p' CHECK (tipo IN ('e', 'p')),
    descripcion TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON COLUMN encuestas.titulo IS 'Ej: Evaluación Docente 2025-Q1';
COMMENT ON COLUMN encuestas.tipo IS 'e = ESTUDIANTES y p = PROFESORES';

-- Tabla de categorías de preguntas
CREATE TABLE categoria_pregunta (
    id SERIAL PRIMARY KEY,
    id_encuesta_cp INTEGER NOT NULL,
    titulo VARCHAR(255) NOT NULL,
    descripcion TEXT,
    orden INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (id_encuesta_cp) REFERENCES encuestas(id)
);

COMMENT ON COLUMN categoria_pregunta.orden IS 'Para ordenar las categorías (0, 1, 2...)';

-- Tabla de preguntas
CREATE TABLE pregunta (
    id SERIAL PRIMARY KEY,
    id_encuesta_preg INTEGER NOT NULL,
    id_categoria_preg INTEGER,
    texto_pregunta TEXT NOT NULL,
    tipo_pregunta VARCHAR(50) NOT NULL CHECK (tipo_pregunta IN ('opcion_multiple', 'texto_abierto', 'escala_1_5')),
    es_obligatoria BOOLEAN DEFAULT false,
    orden INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (id_encuesta_preg) REFERENCES encuestas(id),
    FOREIGN KEY (id_categoria_preg) REFERENCES categoria_pregunta(id)
);

COMMENT ON COLUMN pregunta.tipo_pregunta IS 'Ej: opcion_multiple, texto_abierto, escala_1_5';
COMMENT ON COLUMN pregunta.orden IS 'Para ordenar las preguntas dentro de las encuestas';

-- Tabla de opciones para preguntas de opción múltiple
CREATE TABLE opcion (
    id SERIAL PRIMARY KEY,
    id_pregunta INTEGER NOT NULL,
    texto_opcion VARCHAR(255) NOT NULL,
    valor_numerico NUMERIC(5,2) NOT NULL DEFAULT 0,
    FOREIGN KEY (id_pregunta) REFERENCES pregunta(id)
);

-- Tabla de períodos de evaluación
CREATE TABLE periodo_evaluacion (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT false,
    CHECK (fecha_inicio <= fecha_fin)
);

COMMENT ON COLUMN periodo_evaluacion.nombre IS 'Ej: Año Escolar 2025 - Lapso 1';
COMMENT ON COLUMN periodo_evaluacion.activo IS 'activo = true significa que es el período donde se pueden generar tokens';

-- Tabla de envíos de encuestas
CREATE TABLE envio_encuesta (
    id SERIAL PRIMARY KEY,
    id_env_enc_encuesta INTEGER NOT NULL,
    id_env_enc_evaluado INTEGER NOT NULL,
    id_env_enc_mat INTEGER,
    id_env_enc_pe INTEGER NOT NULL,
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_env_enc_encuesta) REFERENCES encuestas(id),
    FOREIGN KEY (id_env_enc_evaluado) REFERENCES CUENTAS_USUARIO(id),
    FOREIGN KEY (id_env_enc_mat) REFERENCES MATERIAS(mat_id),
    FOREIGN KEY (id_env_enc_pe) REFERENCES periodo_evaluacion(id)
);

COMMENT ON COLUMN envio_encuesta.id_env_enc_MATERIAS IS 'Contexto de la MATERIAS evaluada';

-- Tabla de tokens para acceso a encuestas
CREATE TABLE token_encuesta (
    id SERIAL PRIMARY KEY,
    token_valor VARCHAR(50) UNIQUE NOT NULL,
    id_encuesta_te INTEGER NOT NULL,
    id_evaluado_prf INTEGER NOT NULL,
    id_mat_te INTEGER NOT NULL,
    id_pe_te INTEGER NOT NULL,
    fue_usado BOOLEAN NOT NULL DEFAULT false,
    id_envio_resultante INTEGER,
    FOREIGN KEY (id_encuesta_te) REFERENCES encuestas(id),
    FOREIGN KEY (id_evaluado_prf) REFERENCES CUENTAS_USUARIO(id),
    FOREIGN KEY (id_mat_te) REFERENCES MATERIAS(mat_id),
    FOREIGN KEY (id_pe_te) REFERENCES periodo_evaluacion(id),
    FOREIGN KEY (id_envio_resultante) REFERENCES envio_encuesta(id)
);

COMMENT ON COLUMN token_encuesta.token_valor IS 'La contraseña alfanumérica de un solo uso';
COMMENT ON COLUMN token_encuesta.id_evaluado_prf IS 'El PROFESORES que será evaluado';

-- Tabla de respuestas a las encuestas
CREATE TABLE respuesta (
    id SERIAL PRIMARY KEY,
    id_envio_resp INTEGER NOT NULL,
    id_pregunta_resp INTEGER NOT NULL,
    id_opcion_seleccionada_resp INTEGER,
    respuesta_abierta TEXT,
    UNIQUE (id_envio_resp, id_pregunta_resp),
    FOREIGN KEY (id_envio_resp) REFERENCES envio_encuesta(id),
    FOREIGN KEY (id_pregunta_resp) REFERENCES pregunta(id),
    FOREIGN KEY (id_opcion_seleccionada_resp) REFERENCES opcion(id),
    CHECK (
        (id_opcion_seleccionada_resp IS NOT NULL AND respuesta_abierta IS NULL) OR
        (id_opcion_seleccionada_resp IS NULL AND respuesta_abierta IS NOT NULL) OR
        (id_opcion_seleccionada_resp IS NULL AND respuesta_abierta IS NULL)
    )
);

COMMENT ON CONSTRAINT respuesta_id_envio_resp_id_pregunta_resp_key ON respuesta IS 'Evita respuestas duplicadas para la misma pregunta en el mismo envío';

-- Índices adicionales para mejorar el rendimiento
CREATE INDEX idx_cuenta_usuario_role ON CUENTAS_USUARIO(role);
CREATE INDEX idx_encuestas_tipo ON encuestas(tipo);
CREATE INDEX idx_pregunta_encuesta ON pregunta(id_encuesta_preg);
CREATE INDEX idx_pregunta_categoria ON pregunta(id_categoria_preg);
CREATE INDEX idx_opcion_pregunta ON opcion(id_pregunta);
CREATE INDEX idx_token_encuesta_usado ON token_encuesta(fue_usado);
CREATE INDEX idx_token_encuesta_valor ON token_encuesta(token_valor);
CREATE INDEX idx_periodo_evaluacion_activo ON periodo_evaluacion(activo);
CREATE INDEX idx_envio_encuesta_fecha ON envio_encuesta(fecha_envio);
CREATE INDEX idx_respuesta_envio ON respuesta(id_envio_resp);
CREATE INDEX idx_respuesta_pregunta ON respuesta(id_pregunta_resp);