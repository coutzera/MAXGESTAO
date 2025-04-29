-- Consulta de pedidos realizados pelo vendedor 215
-- no intervalo de 01/04/2025 a 29/04/2025

SELECT 
    fpr.numped AS numero_pedido,            -- Número do pedido realizado
    fpr.data_completa AS data_pedido,       -- Data em que o pedido foi feito
    fpr.codigo_vendedor,                    -- Código do vendedor responsável
    dv.nome_vendedor,                       -- Nome do vendedor (trazido da dimensão de vendedores)
    df.codigo_filial,                       -- Código da filial que emitiu o pedido
    df.razaosocial AS nome_filial,          -- Nome da filial (razão social)
    ds.codigo_supervisor,                   -- Código do supervisor responsável
    ds.nome_supervisor,                     -- Nome do supervisor
    dg.codigo_gerente,                      -- Código do gerente responsável
    dg.nome_gerente                         -- Nome do gerente
FROM fato_pedido_realizado fpr              -- Fato principal contendo os pedidos realizados

-- Junção com a dimensão de vendedores (relaciona o pedido ao nome do vendedor e ao gerente)
JOIN dim_vendedores dv 
    ON fpr.codigo_vendedor = dv.codigo_vendedor

-- Junção com a dimensão de supervisores (para obter nome e código do supervisor relacionado ao pedido)
JOIN dim_supervisores ds 
    ON fpr.codigo_supervisor = ds.codigo_supervisor

-- Junção com a dimensão de gerentes (relacionado ao vendedor)
JOIN dim_gerente dg 
    ON dv.codigo_gerente = dg.codigo_gerente

-- Junção com a dimensão de filiais (para trazer informações da filial que emitiu o pedido)
JOIN dim_filial df 
    ON fpr.codigo_filial = df.codigo_filial

-- Filtros aplicados para retornar apenas:
-- - Pedidos do vendedor 215
-- - Pedidos com data entre 01 e 29 de abril de 2025 (inclusive)
WHERE fpr.codigo_vendedor = '215'
  AND fpr.data_completa BETWEEN TO_DATE('01-04-2025', 'DD-MM-YYYY') 
                           AND TO_DATE('29-04-2025', 'DD-MM-YYYY');
