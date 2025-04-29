WITH parametros AS (
  SELECT 
    NULL::varchar AS codigo_vendedor,
    NULL::varchar AS codigo_supervisor,
    NULL::varchar AS codigo_gerente
)

SELECT 
    fpr.numped AS numero_pedido,
    fpr.data_completa AS data_pedido,
    fpr.codigo_vendedor,
    dv.nome_vendedor,
    df.codigo_filial,
    df.razaosocial AS nome_filial,
    ds.codigo_supervisor,
    ds.nome_supervisor,
    dg.codigo_gerente,
    dg.nome_gerente
FROM fato_pedido_realizado fpr
JOIN dim_vendedores dv 
    ON fpr.codigo_vendedor = dv.codigo_vendedor
JOIN dim_supervisores ds 
    ON fpr.codigo_supervisor = ds.codigo_supervisor
JOIN dim_gerente dg 
    ON dv.codigo_gerente = dg.codigo_gerente
JOIN dim_filial df 
    ON fpr.codigo_filial = df.codigo_filial,
parametros p
WHERE
    (p.codigo_vendedor IS NULL OR fpr.codigo_vendedor = p.codigo_vendedor)
    AND (p.codigo_supervisor IS NULL OR fpr.codigo_supervisor = p.codigo_supervisor)
    AND (p.codigo_gerente IS NULL OR dg.codigo_gerente = p.codigo_gerente)
ORDER BY fpr.data_completa DESC
LIMIT 1;