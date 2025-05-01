WITH pedidos_eventos AS (
    SELECT 
        fe.numero_pedido_rca,
        fe.codigo_vendedor,
        fe.codigo_cliente,
        v.nome_vendedor,
        v.codigo_filial,
        f.fantasia AS nome_filial,
        c.fantasia AS nome_cliente,
        
        -- Conversão e ajuste de fuso horário
        CAST(fe.data_inicio_pedido AS timestamp) AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo' AS horario_abertura,
        CAST(fe.data_fim_pedido AS timestamp) AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo' AS horario_fechamento,
        
        -- Duração bruta do pedido
        CAST(fe.data_fim_pedido AS timestamp) AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo'
        - CAST(fe.data_inicio_pedido AS timestamp) AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo' AS duracao_bruta
    FROM 
        fato_eventos fe
    LEFT JOIN dim_vendedores v 
        ON fe.codigo_vendedor = v.codigo_vendedor
    LEFT JOIN dim_cliente c 
        ON fe.codigo_cliente = c.codigo_cliente
    LEFT JOIN dim_filial f 
        ON v.codigo_filial = f.codigo_filial
    WHERE 
        fe.data_inicio_pedido IS NOT NULL
        AND fe.data_fim_pedido IS NOT NULL
        
        -- Filtro de período
        AND CAST(fe.data_inicio_pedido AS timestamp) 
            AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo'
            BETWEEN '2025-04-30 18:00:00' AND '2025-04-30 23:59:59'
        
        -- Filtro de filial visível e fácil de alterar
        AND v.codigo_filial = '01'  -- 👈 altere aqui para outra filial se quiser
),

duracao_formatada AS (
    SELECT 
        codigo_filial,
        nome_filial,
        numero_pedido_rca,
        nome_vendedor,
        nome_cliente,
        
        TO_CHAR(horario_abertura, 'DD-MM-YYYY') AS data_abertura,
        TO_CHAR(horario_abertura, 'HH24:MI:SS') AS hora_abertura,
        TO_CHAR(horario_fechamento, 'DD-MM-YYYY') AS data_fechamento,
        TO_CHAR(horario_fechamento, 'HH24:MI:SS') AS hora_fechamento,
        
        LPAD(EXTRACT(HOUR FROM duracao_bruta)::VARCHAR, 2, '0') || ':' ||
        LPAD(EXTRACT(MINUTE FROM duracao_bruta)::VARCHAR, 2, '0') || ':' ||
        LPAD(EXTRACT(SECOND FROM duracao_bruta)::VARCHAR, 2, '0') AS duracao_pedido
    FROM pedidos_eventos
)

SELECT *
FROM duracao_formatada
ORDER BY data_abertura DESC, hora_abertura DESC;
