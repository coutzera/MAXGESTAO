WITH
-- Agendados
agendados AS (
  SELECT 
    dataini AS data,
    codigo_cliente
  FROM dim_eventos_qtde_agendamentos
  WHERE codigo_vendedor = '215'
    AND agendado = 'S'
    AND dataini >= DATE_TRUNC('month', CURRENT_DATE)
    AND dataini < CURRENT_DATE
  GROUP BY dataini, codigo_cliente
),

-- Visitados (CHECKIN)
visitados AS (
  SELECT 
    DATE(data_hora_evento) AS data,
    codigo_cliente
  FROM fato_eventos
  WHERE tipo_evento = 'CHECKIN'
    AND codigo_vendedor = '215'
    AND data_hora_evento >= DATE_TRUNC('month', CURRENT_DATE)
    AND data_hora_evento < CURRENT_DATE
  GROUP BY DATE(data_hora_evento), codigo_cliente
),

-- Positivados (PEDIDO)
positivados AS (
  SELECT 
    DATE(data_hora_evento) AS data,
    codigo_cliente
  FROM fato_eventos
  WHERE tipo_evento = 'PEDIDO'
    AND codigo_vendedor = '215'
    AND data_hora_evento >= DATE_TRUNC('month', CURRENT_DATE)
    AND data_hora_evento < CURRENT_DATE
  GROUP BY DATE(data_hora_evento), codigo_cliente
),

-- Consolida todas as datas possíveis
base_completa AS (
  SELECT
    COALESCE(a.data, v.data, p.data) AS data,
    a.codigo_cliente AS cli_agendado,
    v.codigo_cliente AS cli_visitado,
    p.codigo_cliente AS cli_positivado
  FROM agendados a
  FULL OUTER JOIN visitados v
    ON a.codigo_cliente = v.codigo_cliente AND a.data = v.data
  FULL OUTER JOIN positivados p
    ON COALESCE(a.data, v.data) = p.data AND COALESCE(a.codigo_cliente, v.codigo_cliente) = p.codigo_cliente
)

-- Final: agrega apenas nos dias úteis
SELECT 
  b.data,
  COUNT(DISTINCT b.cli_agendado) AS qtd_agendados,
  COUNT(DISTINCT CASE WHEN b.cli_agendado IS NOT NULL AND b.cli_visitado IS NOT NULL THEN b.cli_visitado END) AS qtd_visitados_agendados,
  COUNT(DISTINCT CASE WHEN b.cli_agendado IS NULL AND b.cli_visitado IS NOT NULL THEN b.cli_visitado END) AS qtd_visitados_fora_agenda,
  COUNT(DISTINCT b.cli_visitado) AS qtd_total_visitados,
  COUNT(DISTINCT CASE WHEN b.cli_agendado IS NOT NULL AND b.cli_positivado IS NOT NULL THEN b.cli_positivado END) AS qtd_positivados_agendados,
  COUNT(DISTINCT CASE WHEN b.cli_agendado IS NULL AND b.cli_positivado IS NOT NULL THEN b.cli_positivado END) AS qtd_positivados_fora_agenda,
  COUNT(DISTINCT b.cli_positivado) AS qtd_total_positivados
FROM base_completa b
JOIN fato_diasuteis d ON b.data = d.data
GROUP BY b.data
ORDER BY b.data;
