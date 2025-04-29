SELECT
    fe.codigo_vendedor AS rca,
    dv.nome_vendedor,
    fe.codigo_cliente,
    dc.fantasia AS nome_cliente,

    MIN(CASE WHEN fe.tipo_evento = 'CHECKIN' THEN CAST(fe.data_hora_evento AS timestamp) END) AS checkin,
    MAX(CASE WHEN fe.tipo_evento = 'CHECKOUT' THEN CAST(fe.data_hora_evento AS timestamp) END) AS checkout,
    MIN(CASE WHEN fe.tipo_evento = 'PEDIDO' THEN CAST(fe.data_inicio_pedido AS timestamp) END) AS inicio_pedido,
    MAX(CASE WHEN fe.tipo_evento = 'PEDIDO' THEN CAST(fe.data_fim_pedido AS timestamp) END) AS fim_pedido,

    -- Tempo no cliente (hh:mm:ss)
    LPAD(CAST(
        (EXTRACT(EPOCH FROM MAX(CASE WHEN fe.tipo_evento = 'CHECKOUT' THEN CAST(fe.data_hora_evento AS timestamp) END)) 
        - EXTRACT(EPOCH FROM MIN(CASE WHEN fe.tipo_evento = 'CHECKIN' THEN CAST(fe.data_hora_evento AS timestamp) END))) / 3600 AS INT), 2, '0') 
    || ':' || 
    LPAD(CAST(
        ((EXTRACT(EPOCH FROM MAX(CASE WHEN fe.tipo_evento = 'CHECKOUT' THEN CAST(fe.data_hora_evento AS timestamp) END)) 
        - EXTRACT(EPOCH FROM MIN(CASE WHEN fe.tipo_evento = 'CHECKIN' THEN CAST(fe.data_hora_evento AS timestamp) END))) % 3600) / 60 AS INT), 2, '0') 
    || ':' || 
    LPAD(CAST(
        ((EXTRACT(EPOCH FROM MAX(CASE WHEN fe.tipo_evento = 'CHECKOUT' THEN CAST(fe.data_hora_evento AS timestamp) END)) 
        - EXTRACT(EPOCH FROM MIN(CASE WHEN fe.tipo_evento = 'CHECKIN' THEN CAST(fe.data_hora_evento AS timestamp) END))) % 60) AS INT), 2, '0') 
    AS tempo_no_cliente,

    -- Tempo para realizar o pedido (hh:mm:ss)
    LPAD(CAST(
        (EXTRACT(EPOCH FROM MAX(CASE WHEN fe.tipo_evento = 'PEDIDO' THEN CAST(fe.data_fim_pedido AS timestamp) END)) 
        - EXTRACT(EPOCH FROM MIN(CASE WHEN fe.tipo_evento = 'PEDIDO' THEN CAST(fe.data_inicio_pedido AS timestamp) END))) / 3600 AS INT), 2, '0') 
    || ':' || 
    LPAD(CAST(
        ((EXTRACT(EPOCH FROM MAX(CASE WHEN fe.tipo_evento = 'PEDIDO' THEN CAST(fe.data_fim_pedido AS timestamp) END)) 
        - EXTRACT(EPOCH FROM MIN(CASE WHEN fe.tipo_evento = 'PEDIDO' THEN CAST(fe.data_inicio_pedido AS timestamp) END))) % 3600) / 60 AS INT), 2, '0') 
    || ':' || 
    LPAD(CAST(
        ((EXTRACT(EPOCH FROM MAX(CASE WHEN fe.tipo_evento = 'PEDIDO' THEN CAST(fe.data_fim_pedido AS timestamp) END)) 
        - EXTRACT(EPOCH FROM MIN(CASE WHEN fe.tipo_evento = 'PEDIDO' THEN CAST(fe.data_inicio_pedido AS timestamp) END))) % 60) AS INT), 2, '0') 
    AS tempo_para_pedido

FROM
    fato_eventos fe
JOIN
    dim_vendedores dv ON fe.codigo_vendedor = dv.codigo_vendedor
JOIN
    dim_cliente dc ON fe.codigo_cliente = dc.codigo_cliente
WHERE
    fe.codigo_vendedor = '215'
    AND CAST(fe.data_hora_evento AS date) BETWEEN '2025-04-01' AND '2025-04-01'
GROUP BY
    fe.codigo_vendedor, dv.nome_vendedor, fe.codigo_cliente, dc.fantasia
ORDER BY
    checkin;