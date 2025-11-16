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
    
    CONSTRAINT fk_cuenta_usuario_estudiante FOREIGN KEY (id_cu_est) REFERENCES CUENTAS_USUARIO(cu_id)
);

-- Tabla para PROFESORES
CREATE TABLE PROFESORES (
    prf_id SERIAL PRIMARY KEY,
    nombre_prf VARCHAR(50) NOT NULL,
    apellido_prf VARCHAR(50) NOT NULL,
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
    CONSTRAINT fk_mat_est_materias FOREIGN KEY (id_me_mat) REFERENCES MATERIAS(mat_id),
    CONSTRAINT fk_mat_est_estudiantes FOREIGN KEY (id_me_est) REFERENCES ESTUDIANTES(est_id)
);

-- Tabla de relación muchos a muchos: PROFESORES - MATERIAS
CREATE TABLE PROFESORES_MATERIAS (
    id_pm_mat INTEGER NOT NULL,
    id_pm_prof INTEGER NOT NULL,
    
    CONSTRAINT PK_PROFESORES_MATERIAS PRIMARY KEY (id_pm_mat, id_pm_prof),
    CONSTRAINT fk_prf_mat_materias FOREIGN KEY (id_pm_mat) REFERENCES MATERIAS(mat_id),
    CONSTRAINT fk_prf_mat_profesores FOREIGN KEY (id_pm_prof) REFERENCES PROFESORES(prf_id)
);

-- Tabla de relación muchos a muchos: Sección - ESTUDIANTES
CREATE TABLE SECCIONES_ESTUDIANTES (
    id_se_est INTEGER NOT NULL,
    id_se_sec INTEGER NOT NULL,
    
    CONSTRAINT PK_SECCIONES_ESTUDIANTES PRIMARY KEY (id_se_est, id_se_sec),
    CONSTRAINT fk_sec_est_estudiantes FOREIGN KEY (id_se_est) REFERENCES ESTUDIANTES(est_id),
    CONSTRAINT fk_sec_est_secciones FOREIGN KEY (id_se_sec) REFERENCES SECCIONES(sec_id)
);

-- Tabla de relación muchos a muchos: Sección - PROFESORES
CREATE TABLE SECCIONES_PROFESORES (
    id_sp_prof INTEGER NOT NULL,
    id_sp_sec INTEGER NOT NULL,
    
    CONSTRAINT PK_SECCIONES_PROFESORES PRIMARY KEY (id_sp_prof, id_sp_sec),
    CONSTRAINT fk_sec_prf_profesores FOREIGN KEY (id_sp_prof) REFERENCES PROFESORES(prf_id),
    CONSTRAINT fk_sec_prf_secciones FOREIGN KEY (id_sp_sec) REFERENCES SECCIONES(sec_id)
);

-- Tabla histórica de lapsos/clases
CREATE TABLE HISTORICO_LAPSO_CLASE (
    fecha_inicio_hlc DATE NOT NULL,
    fecha_fin DATE,
    nombre_lapso VARCHAR(50) NOT NULL,
    id_hlc_est INTEGER NOT NULL,
    id_hlc_prof INTEGER NOT NULL,
    
    CONSTRAINT PK_HISTORICO_LAPSO_CLASE PRIMARY KEY (fecha_inicio_hlc, id_hlc_est, id_hlc_prof),
    CONSTRAINT fk_his_lps_cls_estudiante FOREIGN KEY (id_hlc_est) REFERENCES ESTUDIANTES(est_id),
    CONSTRAINT fk_his_lps_cls_profesor FOREIGN KEY (id_hlc_prof) REFERENCES PROFESORES(prf_id)
);

-- Tabla de ENCUESTAS
CREATE TABLE ENCUESTAS (
    enc_id SERIAL PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    tipo_enc CHAR(1) NOT NULL DEFAULT 'p', 
    descripcion TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,

    CONSTRAINT check_tipo_encuesta CHECK(tipo_enc IN ('e', 'p')) --e = estudiante, p = profesor
);

-- Tabla de categorías de PREGUNTAS
CREATE TABLE CATEGORIAS_PREGUNTAS (
    cat_prg_id SERIAL PRIMARY KEY,
    id_encuesta_cp INTEGER NOT NULL,
    titulo VARCHAR(255) NOT NULL,
    descripcion TEXT,
    orden INTEGER NOT NULL DEFAULT 0,
    
    CONSTRAINT fk_cat_prg_encuestas FOREIGN KEY (id_encuesta_cp) REFERENCES ENCUESTAS(enc_id)
);

-- Tabla de PREGUNTAS
CREATE TABLE PREGUNTAS (
    prg_id SERIAL PRIMARY KEY,
    id_encuesta_preg INTEGER NOT NULL,
    id_categoria_preg INTEGER,
    texto_preg TEXT NOT NULL,
    tipo_preg VARCHAR(1) NOT NULL,
    es_obligatoria BOOLEAN DEFAULT false,
    orden INTEGER NOT NULL DEFAULT 0,
    
    CONSTRAINT fk_prg_encuestas FOREIGN KEY (id_encuesta_preg) REFERENCES ENCUESTAS(enc_id),
    CONSTRAINT fk_prg_categorias_encuestas FOREIGN KEY (id_categoria_preg) REFERENCES CATEGORIAS_PREGUNTAS(cat_prg_id),
    CONSTRAINT check_tip_prg CHECK (tipo_preg IN ('m','t','e','s')) -- o = seleccion multiple, t = texto abierto, e = escala del 1-5, s = seleccion simple
);

-- Tabla de OPCIONES para PREGUNTASs de opción múltiple
CREATE TABLE OPCIONES (
    opn_id SERIAL PRIMARY KEY,
    id_pregunta_opn INTEGER NOT NULL,
    texto_opn VARCHAR(255) NOT NULL,
    valor_numerico NUMERIC(5,2) NOT NULL DEFAULT 0,
    
    CONSTRAINT fk_opn_preguntas FOREIGN KEY (id_pregunta_opn) REFERENCES PREGUNTAS(prg_id)
);

-- Tabla de períodos de evaluación
CREATE TABLE PERIODOS_EVALUACION (
    prd_evc_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    fecha_inicio_prd_evc DATE NOT NULL,
    fecha_fin_prd_evc DATE NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT false,
    
    CONSTRAINT check_fec_ini_fech_fin CHECK (fecha_inicio_prd_evc <= fecha_fin_prd_evc)
);

-- Tabla de envíos de ENCUESTAS
CREATE TABLE ENVIOS_ENCUESTAS (
    env_enc_id SERIAL,
    id_env_enc_encuesta INTEGER NOT NULL,
    id_env_enc_evaluado INTEGER NOT NULL,
    id_env_enc_materia INTEGER,
    id_env_enc_periodo_evaluado INTEGER NOT NULL,
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT PK_ENVIOS_ENCUESTAS PRIMARY KEY (env_enc_id, id_env_enc_encuesta, id_env_enc_evaluado, id_env_enc_materia, id_env_enc_periodo_evaluado),
    CONSTRAINT fk_env_enc_encuestas FOREIGN KEY (id_env_enc_encuesta) REFERENCES ENCUESTAS(enc_id),
    CONSTRAINT fk_env_enc_usuario_cuenta FOREIGN KEY (id_env_enc_evaluado) REFERENCES CUENTAS_USUARIO(cu_id),
    CONSTRAINT fk_env_enc_materias FOREIGN KEY (id_env_enc_materia) REFERENCES MATERIAS(mat_id),
    CONSTRAINT fk_env_enc_periodos_evaluacion FOREIGN KEY (id_env_enc_periodo_evaluado) REFERENCES PERIODOS_EVALUACION(prd_evc_id)
);

-- Tabla de tokens para acceso a ENCUESTAS
CREATE TABLE TOKENS_ENCUESTAS (
    tk_enc_id SERIAL PRIMARY KEY,
    token_valor VARCHAR(50) UNIQUE NOT NULL,
    id_encuesta_tk_enc INTEGER NOT NULL,
    id_evaluado_prf_tk_enc INTEGER NOT NULL,
    id_mat_tk_enc INTEGER NOT NULL,
    id_prd_evn_tk_enc INTEGER NOT NULL,
    fue_usado BOOLEAN NOT NULL DEFAULT false,
    id_envio_resultante INTEGER,
    
    CONSTRAINT fk_tk_enc_encuestas FOREIGN KEY (id_encuesta_tk_enc) REFERENCES ENCUESTAS(enc_id),
    CONSTRAINT fk_tk_enc_cuentas_usuario FOREIGN KEY (id_evaluado_prf_tk_enc) REFERENCES CUENTAS_USUARIO(cu_id),
    CONSTRAINT fk_tk_enc_materias FOREIGN KEY (id_mat_tk_enc) REFERENCES MATERIAS(mat_id),
    CONSTRAINT fk_tk_enc_periodos_evaluacion FOREIGN KEY (id_prd_evn_tk_enc) REFERENCES PERIODOS_EVALUACION(prd_evc_id),
    CONSTRAINT fk_tk_enc_envios_encuestas FOREIGN KEY (id_envio_resultante) REFERENCES ENVIOS_ENCUESTAS(env_enc_id)
);

-- Tabla de RESPUESTAS a las ENCUESTAS
CREATE TABLE RESPUESTAS (
    rsp_id SERIAL,
    id_envio_respuesta_rsp INTEGER NOT NULL,
    id_pregunta_rsp INTEGER NOT NULL,
    id_opciones_seleccionada_rsp INTEGER,
    respuesta_abierta TEXT,
    
    CONSTRAINT FK_RESPUESTAS PRIMARY KEY (rsp_id, id_pregunta_rsp, id_opciones_seleccionada_rsp),
    CONSTRAINT fk_rps_envio_respuesta FOREIGN KEY (id_envio_respuesta_rsp) REFERENCES ENVIOS_ENCUESTAS(env_enc_id),
    CONSTRAINT fk_rps_preguntas FOREIGN KEY (id_pregunta_rsp) REFERENCES PREGUNTAS(prg_id),
    CONSTRAINT fk_rps_opciones FOREIGN KEY (id_opciones_seleccionada_rsp) REFERENCES OPCIONES(opn_id),
    CONSTRAINT check_opcion_seleccionada CHECK (
        (id_opciones_seleccionada_rsp IS NOT NULL AND respuesta_abierta IS NULL) OR
        (id_opciones_seleccionada_rsp IS NULL AND respuesta_abierta IS NOT NULL) OR
        (id_opciones_seleccionada_rsp IS NULL AND respuesta_abierta IS NULL)
    )
);

-- Índices adicionales para mejorar el rendimiento
CREATE INDEX idx_cuenta_usuario_role ON CUENTAS_USUARIO(rol);
CREATE INDEX idx_encuestas_tipo ON ENCUESTAS(tipo_enc);
CREATE INDEX idx_preguntas_encuesta ON PREGUNTAS(id_encuesta_preg);
CREATE INDEX idx_preguntas_categoria ON PREGUNTAS(id_categoria_preg);
CREATE INDEX idx_opciones_preguntas ON OPCIONES(id_pregunta_opn);
CREATE INDEX idx_tokens_encuestas_usado ON TOKENS_ENCUESTAS(fue_usado);
CREATE INDEX idx_tokens_encuestas_valor ON TOKENS_ENCUESTAS(token_valor);
CREATE INDEX idx_periodos_evaluacion_activo ON PERIODOS_EVALUACION(activo);
CREATE INDEX idx_envios_encuestas_fecha ON ENVIOS_ENCUESTAS(fecha_envio);
CREATE INDEX idx_respuestas_envio ON RESPUESTAS(id_envio_respuesta_rsp);
CREATE INDEX idx_respuestas_preguntas ON RESPUESTAS(id_pregunta_rsp);