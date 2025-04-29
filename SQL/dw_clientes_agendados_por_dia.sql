SELECT 
  a.dataini AS data_agendamento,
  a.codigo_cliente,
  c.razaosocial,
  c.fantasia
FROM dim_eventos_qtde_agendamentos a
JOIN dim_cliente c
  ON a.codigo_cliente = c.codigo_cliente
WHERE a.codigo_vendedor = '215'
  AND a.agendado = 'S'
  AND a.dataini >= DATE_TRUNC('month', CURRENT_DATE)
  AND a.dataini < (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month')
ORDER BY a.dataini, a.codigo_cliente;