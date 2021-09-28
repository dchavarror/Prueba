--
-- PostgreSQL database dump
--

-- Dumped from database version 13.0
-- Dumped by pg_dump version 13.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

-- Role: bprueba
-- DROP ROLE bprueba;

CREATE ROLE bprueba WITH
  LOGIN
  SUPERUSER
  INHERIT
  CREATEDB
  CREATEROLE
  REPLICATION
  ENCRYPTED PASSWORD 'SCRAM-SHA-256$4096:BB2fIUicutNktY9KLfWAzQ==$bksY8qgV6faeOost9pEeWDuXU1uLB6PhJ9/aUqwKn90=:zimevqyZqF2jOkSqiYicG8eakbnUnBKLHQQ7xG67/qY=';

-- Database: bprueba

-- DROP DATABASE bprueba;

CREATE DATABASE bprueba
    WITH 
    OWNER = bprueba
    ENCODING = 'UTF8'
    LC_COLLATE = 'Spanish_Colombia.1252'
    LC_CTYPE = 'Spanish_Colombia.1252'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

GRANT ALL ON DATABASE bprueba TO bprueba;

GRANT TEMPORARY, CONNECT ON DATABASE bprueba TO PUBLIC;
--
-- Name: fn_actualizar_cliente(text, text, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_actualizar_cliente(p_nombre text, p_telefono text, p_direccion text, p_id integer, OUT out_tip_res text, OUT out_cod_error text, OUT out_desc_error text) RETURNS record
    LANGUAGE plpgsql
    AS $$
DECLARE
 v_id_cliente int;
begin
       UPDATE public."CLIENTE"
		SET "NOMBRE"=p_nombre, "TELEFONO"=p_telefono, "DIRECCION"=p_direccion
		WHERE "ID" = p_id; 
		out_tip_res = 'OK';
			out_desc_error     = 'ACTUALIZADO EXITOSAMENTE';
end;
$$;


ALTER FUNCTION public.fn_actualizar_cliente(p_nombre text, p_telefono text, p_direccion text, p_id integer, OUT out_tip_res text, OUT out_cod_error text, OUT out_desc_error text) OWNER TO postgres;

--
-- Name: fn_actualizar_cuenta(integer, numeric, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_actualizar_cuenta(p_id integer, p_num_cuenta numeric, p_saldo double precision, OUT out_tip_res text, OUT out_cod_error text, OUT out_desc_error text) RETURNS record
    LANGUAGE plpgsql
    AS $$
DECLARE
 v_id_cliente int;
begin

    UPDATE public."CUENTA"
	SET  "NUMERO"=p_num_cuenta, "SALDO"=p_saldo
	WHERE "ID" = p_id;
	
	out_tip_res = 'OK';
	out_desc_error     = 'ACTUALIZO CUENTA EXITOSAMENTE';
	exception when others then 
	out_tip_res = 'ER';
	get stacked diagnostics
		out_cod_error   = returned_sqlstate,
		out_desc_error     = message_text;
		--ROLLBACK;
end;
$$;


ALTER FUNCTION public.fn_actualizar_cuenta(p_id integer, p_num_cuenta numeric, p_saldo double precision, OUT out_tip_res text, OUT out_cod_error text, OUT out_desc_error text) OWNER TO postgres;

--
-- Name: fn_consultar_clientes(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_consultar_clientes(p_nombre text, OUT out_tip_res text, OUT out_cod_error text, OUT out_desc_error text, OUT ref refcursor) RETURNS record
    LANGUAGE plpgsql
    AS $$
begin
        IF p_nombre != '' THEN
	       open ref for SELECT * FROM public."CLIENTE" WHERE "NOMBRE" LIKE p_nombre;
		ELSE
		  open ref for SELECT * FROM public."CLIENTE";
		END IF;
		out_tip_res = 'OK';
		out_desc_error     = 'CONSULTADO EXITOSAMENTE';
		exception when others then 
		out_tip_res = 'ER';
		get stacked diagnostics
			out_cod_error   = returned_sqlstate,
			out_desc_error     = message_text;
			--ROLLBACK;
end;
$$;


ALTER FUNCTION public.fn_consultar_clientes(p_nombre text, OUT out_tip_res text, OUT out_cod_error text, OUT out_desc_error text, OUT ref refcursor) OWNER TO postgres;

--
-- Name: fn_consultar_cuentas(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_consultar_cuentas(p_id_cliente integer, OUT out_tip_res text, OUT out_cod_error text, OUT out_desc_error text, OUT ref refcursor) RETURNS record
    LANGUAGE plpgsql
    AS $$
DECLARE
 v_tiene_cuenta int;
begin
   
    open ref for SELECT * FROM public."CUENTA" WHERE "ID_CLIENTE" = p_id_cliente;
	out_tip_res = 'OK';
	out_desc_error     = 'CONSULTO CUENTAS EXITOSAMENTE';
	exception when others then 
	out_tip_res = 'ER';
	get stacked diagnostics
		out_cod_error   = returned_sqlstate,
		out_desc_error     = message_text;
		--ROLLBACK;
end;
$$;


ALTER FUNCTION public.fn_consultar_cuentas(p_id_cliente integer, OUT out_tip_res text, OUT out_cod_error text, OUT out_desc_error text, OUT ref refcursor) OWNER TO postgres;

--
-- Name: fn_consultar_movimientos(integer, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_consultar_movimientos(p_id_cliente integer, p_fec_inicio text, p_fec_fin text, OUT out_tip_res text, OUT out_cod_error text, OUT out_desc_error text, OUT ref refcursor) RETURNS record
    LANGUAGE plpgsql
    AS $$
begin
         open ref for 
		SELECT  TM."DESCRIPCION", MOV."FECHA", 
        MOV."VALOR", CUENT."NUMERO", CUENT."SALDO", CL."NOMBRE"
	    FROM public."MOVIMIENTO" MOV 
		INNER JOIN public."CUENTA" CUENT
		ON  CUENT."ID" = MOV."ID_CUENTA"
		INNER JOIN public."TIPO_MOVIMIENTO" TM
		ON TM."ID"=MOV."ID_TIPO"
		INNER JOIN public."CLIENTE" CL
		ON CL."ID" = CUENT."ID_CLIENTE"
		WHERE TO_CHAR(MOV."FECHA", 'yyyy-MM-dd')
		BETWEEN p_fec_inicio AND p_fec_fin
		AND "ID_CUENTA" IN (SELECT "ID" FROM public."CUENTA" CUENT 
							WHERE "ID_CLIENTE" = p_id_cliente);
		out_tip_res = 'OK';
		out_desc_error     = 'CONSULTADO EXITOSAMENTE';
		exception when others then 
		out_tip_res = 'ER';
		get stacked diagnostics
			out_cod_error   = returned_sqlstate,
			out_desc_error     = message_text;
			--ROLLBACK;
end;
$$;


ALTER FUNCTION public.fn_consultar_movimientos(p_id_cliente integer, p_fec_inicio text, p_fec_fin text, OUT out_tip_res text, OUT out_cod_error text, OUT out_desc_error text, OUT ref refcursor) OWNER TO postgres;

--
-- Name: fn_crear_cliente(text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_crear_cliente(p_nombre text, p_telefono text, p_direccion text, OUT out_tip_res text, OUT out_cod_error text, OUT out_desc_error text) RETURNS record
    LANGUAGE plpgsql
    AS $$
DECLARE
 v_cant_cliente int;
begin
       SELECT COUNT(*) INTO  v_cant_cliente FROM public."CLIENTE" WHERE "NOMBRE" = p_nombre;
       IF(v_cant_cliente > 0) THEN
			out_tip_res = 'ER';
			out_desc_error     = 'CLIENTE YA EXISTE';
		ELSE
		   INSERT INTO public."CLIENTE"(
		   "NOMBRE", "TELEFONO", "DIRECCION")
		   VALUES ( p_nombre, p_telefono, p_direccion);
		    out_tip_res = 'OK';
			out_desc_error     = 'GUARDADO EXITOSAMENTE';
	    END IF;
		exception when others then 
		out_tip_res = 'ER';
		get stacked diagnostics
			out_cod_error   = returned_sqlstate,
			out_desc_error     = message_text;
			--ROLLBACK;
		 
end;
$$;


ALTER FUNCTION public.fn_crear_cliente(p_nombre text, p_telefono text, p_direccion text, OUT out_tip_res text, OUT out_cod_error text, OUT out_desc_error text) OWNER TO postgres;

--
-- Name: fn_eliminar_cliente(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_eliminar_cliente(p_id integer, OUT out_tip_res text, OUT out_cod_error text, OUT out_desc_error text) RETURNS record
    LANGUAGE plpgsql
    AS $$
DECLARE
 v_id_cliente int;
begin

    DELETE FROM public."MOVIMIENTO"
	WHERE "ID_CUENTA" IN (SELECT "ID" FROM public."CUENTA"
	WHERE "ID_CLIENTE" = p_id);
	
	DELETE FROM public."CUENTA"
	WHERE "ID_CLIENTE" = p_id;
	
	DELETE FROM public."CLIENTE"
    WHERE "ID" = p_id;
	
	out_tip_res = 'OK';
	out_desc_error     = 'ELIMINADO EXITOSAMENTE';
	exception when others then 
	out_tip_res = 'ER';
	get stacked diagnostics
		out_cod_error   = returned_sqlstate,
		out_desc_error     = message_text;
		--ROLLBACK;
end;
$$;


ALTER FUNCTION public.fn_eliminar_cliente(p_id integer, OUT out_tip_res text, OUT out_cod_error text, OUT out_desc_error text) OWNER TO postgres;

--
-- Name: fn_eliminar_cuenta(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_eliminar_cuenta(p_id integer, OUT out_tip_res text, OUT out_cod_error text, OUT out_desc_error text) RETURNS record
    LANGUAGE plpgsql
    AS $$
DECLARE
 v_id_cliente int;
begin

    DELETE FROM public."MOVIMIENTO"
	WHERE "ID_CUENTA" = p_id;
	
	DELETE FROM public."CUENTA"
	WHERE "ID" = p_id;
	
	out_tip_res = 'OK';
	out_desc_error     = 'ELIMINADO EXITOSAMENTE';
	exception when others then 
	out_tip_res = 'ER';
	get stacked diagnostics
		out_cod_error   = returned_sqlstate,
		out_desc_error     = message_text;
		--ROLLBACK;
end;
$$;


ALTER FUNCTION public.fn_eliminar_cuenta(p_id integer, OUT out_tip_res text, OUT out_cod_error text, OUT out_desc_error text) OWNER TO postgres;

--
-- Name: fn_guardar_cuenta(integer, numeric, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_guardar_cuenta(p_id_cliente integer, p_num_cuenta numeric, p_saldo double precision, OUT out_tip_res text, OUT out_cod_error text, OUT out_desc_error text) RETURNS record
    LANGUAGE plpgsql
    AS $$
DECLARE
 v_tiene_cuenta int;
begin
    SELECT COUNT(*) INTO v_tiene_cuenta FROM public."CUENTA" WHERE "NUMERO" = p_num_cuenta;
	IF v_tiene_cuenta >0 THEN
	   out_tip_res = 'ER';
	   out_desc_error     = 'CUENTA YA EXISTE';
	ELSE
		INSERT INTO public."CUENTA"(
		"NUMERO", "SALDO", "ID_CLIENTE")
		VALUES ( p_num_cuenta, p_saldo, p_id_cliente);
	END IF;
	
	out_tip_res = 'OK';
	out_desc_error     = 'GUARDO CUENTA EXITOSAMENTE';
	exception when others then 
	out_tip_res = 'ER';
	get stacked diagnostics
		out_cod_error   = returned_sqlstate,
		out_desc_error     = message_text;
		--ROLLBACK;
end;
$$;


ALTER FUNCTION public.fn_guardar_cuenta(p_id_cliente integer, p_num_cuenta numeric, p_saldo double precision, OUT out_tip_res text, OUT out_cod_error text, OUT out_desc_error text) OWNER TO postgres;

--
-- Name: fn_guardar_movimiento(integer, double precision, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_guardar_movimiento(p_id_cuenta integer, p_valor double precision, p_id_tipo integer, OUT out_tip_res text, OUT out_cod_error text, OUT out_desc_error text) RETURNS record
    LANGUAGE plpgsql
    AS $$
DECLARE
 v_sal_insu int;
 v_saldo_cuenta double precision;
begin
    SELECT "SALDO" INTO v_saldo_cuenta FROM public."CUENTA" WHERE "ID" = p_id_cuenta;
	v_sal_insu = 0;
    IF p_id_tipo = 2 THEN
	   IF v_saldo_cuenta >= p_valor THEN
	    UPDATE public."CUENTA"
	    SET "SALDO"= (v_saldo_cuenta - p_valor)
	    WHERE "ID" = p_id_cuenta;
	   ELSE
	     v_sal_insu = 1;
	     out_tip_res = 'OK';
	     out_desc_error     = 'SALDO INSUFICIENTE';
	   END IF;
	ELSE
	  UPDATE public."CUENTA"
	  SET "SALDO"= (v_saldo_cuenta + p_valor)
	  WHERE "ID" = p_id_cuenta;
	END IF;
    IF v_sal_insu =0 THEN
		INSERT INTO public."MOVIMIENTO"(
		 "ID_TIPO", "FECHA", "VALOR", "ID_CUENTA")
		VALUES ( p_id_tipo, CURRENT_TIMESTAMP ,p_valor, p_id_cuenta);
		out_tip_res = 'OK';
		out_desc_error     = 'GUARDO MOVIMIENTO EXITOSAMENTE';
    END IF;
	exception when others then 
	out_tip_res = 'ER';
	get stacked diagnostics
		out_cod_error   = returned_sqlstate,
		out_desc_error     = message_text;
		--ROLLBACK;
end;
$$;


ALTER FUNCTION public.fn_guardar_movimiento(p_id_cuenta integer, p_valor double precision, p_id_tipo integer, OUT out_tip_res text, OUT out_cod_error text, OUT out_desc_error text) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: CLIENTE; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CLIENTE" (
    "ID" bigint NOT NULL,
    "NOMBRE" character varying(50) NOT NULL,
    "TELEFONO" character varying(10),
    "DIRECCION" character varying(200)
);


ALTER TABLE public."CLIENTE" OWNER TO postgres;

--
-- Name: CLIENTE_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."CLIENTE_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."CLIENTE_ID_seq" OWNER TO postgres;

--
-- Name: CLIENTE_ID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."CLIENTE_ID_seq" OWNED BY public."CLIENTE"."ID";


--
-- Name: CUENTE_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."CUENTE_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."CUENTE_ID_seq" OWNER TO postgres;

--
-- Name: CUENTA; Type: TABLE; Schema: public; Owner: bprueba
--

CREATE TABLE public."CUENTA" (
    "ID" bigint DEFAULT nextval('public."CUENTE_ID_seq"'::regclass) NOT NULL,
    "NUMERO" numeric NOT NULL,
    "SALDO" double precision NOT NULL,
    "ID_CLIENTE" integer NOT NULL
);


ALTER TABLE public."CUENTA" OWNER TO bprueba;

--
-- Name: MOVIMIENTO_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."MOVIMIENTO_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."MOVIMIENTO_ID_seq" OWNER TO postgres;

--
-- Name: MOVIMIENTO; Type: TABLE; Schema: public; Owner: bprueba
--

CREATE TABLE public."MOVIMIENTO" (
    "ID" bigint DEFAULT nextval('public."MOVIMIENTO_ID_seq"'::regclass) NOT NULL,
    "ID_TIPO" integer NOT NULL,
    "FECHA" timestamp with time zone NOT NULL,
    "VALOR" double precision NOT NULL,
    "ID_CUENTA" integer NOT NULL
);


ALTER TABLE public."MOVIMIENTO" OWNER TO bprueba;

--
-- Name: TIPO_MOVIMIENTO; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."TIPO_MOVIMIENTO" (
    "ID" bigint NOT NULL,
    "DESCRIPCION" character varying NOT NULL
);


ALTER TABLE public."TIPO_MOVIMIENTO" OWNER TO postgres;

--
-- Name: CLIENTE ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CLIENTE" ALTER COLUMN "ID" SET DEFAULT nextval('public."CLIENTE_ID_seq"'::regclass);


--
-- Data for Name: CLIENTE; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CLIENTE" ("ID", "NOMBRE", "TELEFONO", "DIRECCION") FROM stdin;
13	DEIBER CHAVARRO	313467878	CALLE 66A-#50B-11
\.


--
-- Data for Name: CUENTA; Type: TABLE DATA; Schema: public; Owner: bprueba
--

COPY public."CUENTA" ("ID", "NUMERO", "SALDO", "ID_CLIENTE") FROM stdin;
9	234867000	182000	13
\.


--
-- Data for Name: MOVIMIENTO; Type: TABLE DATA; Schema: public; Owner: bprueba
--

COPY public."MOVIMIENTO" ("ID", "ID_TIPO", "FECHA", "VALOR", "ID_CUENTA") FROM stdin;
10	1	2021-09-28 10:44:50.816944-05	200000	9
11	2	2021-09-28 10:46:20.430167-05	20000	9
\.


--
-- Data for Name: TIPO_MOVIMIENTO; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."TIPO_MOVIMIENTO" ("ID", "DESCRIPCION") FROM stdin;
1	DEBITO
2	CREDITO
\.


--
-- Name: CLIENTE_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."CLIENTE_ID_seq"', 14, true);


--
-- Name: CUENTE_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."CUENTE_ID_seq"', 9, true);


--
-- Name: MOVIMIENTO_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."MOVIMIENTO_ID_seq"', 11, true);


--
-- Name: CLIENTE CLIENTE_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CLIENTE"
    ADD CONSTRAINT "CLIENTE_pkey" PRIMARY KEY ("ID");


--
-- Name: CUENTA CUENTA_pkey; Type: CONSTRAINT; Schema: public; Owner: bprueba
--

ALTER TABLE ONLY public."CUENTA"
    ADD CONSTRAINT "CUENTA_pkey" PRIMARY KEY ("ID");


--
-- Name: MOVIMIENTO MOVIMIENTO_pkey; Type: CONSTRAINT; Schema: public; Owner: bprueba
--

ALTER TABLE ONLY public."MOVIMIENTO"
    ADD CONSTRAINT "MOVIMIENTO_pkey" PRIMARY KEY ("ID");


--
-- Name: TIPO_MOVIMIENTO TIPO_MOVIMIENTO_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TIPO_MOVIMIENTO"
    ADD CONSTRAINT "TIPO_MOVIMIENTO_pkey" PRIMARY KEY ("ID");


--
-- Name: CUENTA FK_CUENTA_CLIENTE; Type: FK CONSTRAINT; Schema: public; Owner: bprueba
--

ALTER TABLE ONLY public."CUENTA"
    ADD CONSTRAINT "FK_CUENTA_CLIENTE" FOREIGN KEY ("ID_CLIENTE") REFERENCES public."CLIENTE"("ID");


--
-- Name: MOVIMIENTO FK_MOV_CUENTA; Type: FK CONSTRAINT; Schema: public; Owner: bprueba
--

ALTER TABLE ONLY public."MOVIMIENTO"
    ADD CONSTRAINT "FK_MOV_CUENTA" FOREIGN KEY ("ID_CUENTA") REFERENCES public."CUENTA"("ID");


--
-- Name: MOVIMIENTO FK_MOV_TIPO_MOV; Type: FK CONSTRAINT; Schema: public; Owner: bprueba
--

ALTER TABLE ONLY public."MOVIMIENTO"
    ADD CONSTRAINT "FK_MOV_TIPO_MOV" FOREIGN KEY ("ID_TIPO") REFERENCES public."TIPO_MOVIMIENTO"("ID");


--
-- PostgreSQL database dump complete
--

