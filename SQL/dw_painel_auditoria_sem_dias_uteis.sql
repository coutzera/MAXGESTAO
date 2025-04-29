-- CTE: Clientes agendados no mês atual até a data de hoje
WITH agendados AS (
  SELECT 
    dataini::date AS data,           -- Extrai apenas a data do agendamento
    codigo_cliente
  FROM dim_eventos_qtde_agendamentos
  WHERE codigo_vendedor = '215'
    AND agendado = 'S'
    AND dataini >= DATE_TRUNC('month', CURRENT_DATE)  -- Início do mês
    AND dataini < CURRENT_DATE                        -- Exclui o dia atual
  GROUP BY dataini, codigo_cliente
),

-- CTE: Clientes que foram visitados (CHECKIN) no mesmo período
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

-- CTE: Clientes que fizeram pedido (PEDIDO) no mesmo período
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
)

-- União e análise dos dados por dia
SELECT
  -- Prioriza a data disponível entre os datasets
  COALESCE(a.data, v.data, p.data) AS data,

  -- Total de clientes agendados no dia
  COUNT(DISTINCT a.codigo_cliente) AS qtd_agendados,

  -- Clientes que foram visitados E estavam agendados
  COUNT(DISTINCT CASE 
    WHEN a.codigo_cliente IS NOT NULL AND v.codigo_cliente IS NOT NULL 
    THEN v.codigo_cliente 
  END) AS qtd_visitados_agendados,

  -- Clientes visitados que NÃO estavam na agenda
  COUNT(DISTINCT CASE 
    WHEN a.codigo_cliente IS NULL AND v.codigo_cliente IS NOT NULL 
    THEN v.codigo_cliente 
  END) AS qtd_visitados_fora_agenda,

  -- Total de clientes visitados no dia
  COUNT(DISTINCT v.codigo_cliente) AS qtd_total_visitados,

  -- Clientes que fizeram pedido E estavam agendados
  COUNT(DISTINCT CASE 
    WHEN a.codigo_cliente IS NOT NULL AND p.codigo_cliente IS NOT NULL 
    THEN p.codigo_cliente 
  END) AS qtd_positivados_agendados,

  -- Clientes que fizeram pedido mas NÃO estavam na agenda
  COUNT(DISTINCT CASE 
    WHEN a.codigo_cliente IS NULL AND p.codigo_cliente IS NOT NULL 
    THEN p.codigo_cliente 
  END) AS qtd_positivados_fora_agenda,

  -- Total de clientes que fizeram pedido no dia
  COUNT(DISTINCT p.codigo_cliente) AS qtd_total_positivados

FROM agendados a
FULL OUTER JOIN visitados v
  ON a.codigo_cliente = v.codigo_cliente 
  AND a.data = v.data

FULL OUTER JOIN positivados p
  ON COALESCE(a.data, v.data) = p.data 
  AND COALESCE(a.codigo_cliente, v.codigo_cliente) = p.codigo_cliente

-- Garante que pelo menos uma data está presente
WHERE COALESCE(a.data, v.data, p.data) IS NOT NULL

-- Agrupa por data final
GROUP BY COALESCE(a.data, v.data, p.data)
ORDER BY data;
