-- Criando tabelas de dimensão (tabelas de apoio sem foreign keys)

CREATE TABLE dim_categorias (
	product_category_name VARCHAR(100) PRIMARY KEY,
	product_category_name_english VARCHAR(100)
);

CREATE TABLE dim_clientes (
	customer_id VARCHAR(50) PRIMARY KEY,
	customer_unique_id VARCHAR(50),
	customer_zip_code_prefix VARCHAR(10),
	customer_city VARCHAR(100),
	customer_state CHAR(2)
);

CREATE TABLE dim_geolocalizacao (
	geolocation_zip_code_prefix VARCHAR(10),
	geolocation_lat DECIMAL(10,8),
	geolocation_lng DECIMAL(11,8),
	geolocation_city VARCHAR(100),
	geolocation_state CHAR(2)
);

CREATE TABLE dim_vendedores (
	seller_id VARCHAR(50) PRIMARY KEY,
	seller_zip_code_prefix VARCHAR(10),
	seller_city VARCHAR(100),
	seller_state CHAR(2)
);

CREATE TABLE dim_produtos (
	product_id VARCHAR(50) PRIMARY KEY,
	product_category_name VARCHAR(100),
	product_name_length INT,
	product_description_length INT,
	product_photos_qty INT,
	product_weigth_g INT,
	product_length_cm INT,
	product_heigth_cm INT,
	product_width_cm INT,
	FOREIGN KEY (product_category_name) REFERENCES dim_categorias(product_category_name)
);

-- Criando tabelas fato (tabelas principais com foreign keys)

CREATE TABLE fato_pedidos (
	order_id VARCHAR(50) PRIMARY KEY,
	customer_id VARCHAR(50),
	order_status VARCHAR(30),
	order_purchase_timestamp TIMESTAMP,
	order_approved_at TIMESTAMP,
	order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES dim_clientes(customer_id)
);

CREATE TABLE fato_itens_pedido (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2),
    PRIMARY KEY (order_id, order_item_id),
    FOREIGN KEY (order_id) REFERENCES fato_pedidos(order_id),
    FOREIGN KEY (product_id) REFERENCES dim_produtos(product_id),
    FOREIGN KEY (seller_id) REFERENCES dim_vendedores(seller_id)
);

CREATE TABLE fato_pagamentos (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value DECIMAL(10,2),
    PRIMARY KEY (order_id, payment_sequential),
    FOREIGN KEY (order_id) REFERENCES fato_pedidos(order_id)
);

CREATE TABLE fato_avaliacoes (
    review_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50),
    review_comment_title VARCHAR(100),
    review_comment_message TEXT,
    review_score INT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES fato_pedidos(order_id)
);

-- Importando dados CSVs (Dimensão primeiro e depois Fato - ORDEM DAS CHAVES)

COPY dim_categorias FROM 'C:\Users\ruanl\Desktop\DocsPessoais\Projeto Pessoal\Portifolio\SQL_Project_PostgreSQL\DataSet-Olist\product_category_name_translation.csv'
DELIMITER ',' CSV HEADER;

COPY dim_clientes FROM 'C:\Users\ruanl\Desktop\DocsPessoais\Projeto Pessoal\Portifolio\SQL_Project_PostgreSQL\DataSet-Olist\olist_customers_dataset.csv'
DELIMITER ',' CSV HEADER;

COPY dim_geolocalizacao FROM 'C:\Users\ruanl\Desktop\DocsPessoais\Projeto Pessoal\Portifolio\SQL_Project_PostgreSQL\DataSet-Olist\olist_geolocation_dataset.csv'
DELIMITER ',' CSV HEADER;

COPY dim_vendedores FROM 'C:\Users\ruanl\Desktop\DocsPessoais\Projeto Pessoal\Portifolio\SQL_Project_PostgreSQL\DataSet-Olist\olist_sellers_dataset.csv'
DELIMITER ',' CSV HEADER;

COPY dim_produtos FROM 'C:\Users\ruanl\Desktop\DocsPessoais\Projeto Pessoal\Portifolio\SQL_Project_PostgreSQL\DataSet-Olist\olist_products_dataset.csv'
DELIMITER ',' CSV HEADER;

COPY fato_pedidos FROM 'C:\Users\ruanl\Desktop\DocsPessoais\Projeto Pessoal\Portifolio\SQL_Project_PostgreSQL\DataSet-Olist\olist_orders_dataset.csv'
DELIMITER ',' CSV HEADER;

COPY fato_itens_pedido FROM 'C:\Users\ruanl\Desktop\DocsPessoais\Projeto Pessoal\Portifolio\SQL_Project_PostgreSQL\DataSet-Olist\olist_order_items_dataset.csv'
DELIMITER ',' CSV HEADER;

COPY fato_pagamentos FROM 'C:\Users\ruanl\Desktop\DocsPessoais\Projeto Pessoal\Portifolio\SQL_Project_PostgreSQL\DataSet-Olist\olist_order_payments_dataset.csv'
DELIMITER ',' CSV HEADER;

COPY fato_avaliacoes FROM 'C:\Users\ruanl\Desktop\DocsPessoais\Projeto Pessoal\Portifolio\SQL_Project_PostgreSQL\DataSet-Olist\olist_order_reviews_dataset.csv'
DELIMITER ',' CSV HEADER;

-- Removendo a foreign key problematica 

ALTER TABLE dim_produtos
DROP CONSTRAINT dim_produtos_product_category_name_fkey;

-- Importando o csv problemático

COPY dim_produtos FROM 'C:\Users\ruanl\Desktop\DocsPessoais\Projeto Pessoal\Portifolio\SQL_Project_PostgreSQL\DataSet-Olist\olist_products_dataset.csv'
DELIMITER ',' CSV HEADER;

-- Verificação

SELECT 'dim_categorias' AS tabela, COUNT(*) AS total FROM dim_categorias
UNION ALL

SELECT 'dim_clientes', COUNT(*) FROM dim_clientes
UNION ALL

SELECT 'dim_geolocalizacao', COUNT(*) FROM dim_geolocalizacao
UNION ALL

SELECT 'dim_vendedores', COUNT(*) FROM dim_vendedores
UNION ALL

SELECT 'dim_produtos', COUNT(*) FROM dim_produtos
UNION ALL

SELECT 'fato_pedidos', COUNT(*) FROM fato_pedidos
UNION ALL

SELECT 'fato_itens_pedido', COUNT(*) FROM fato_itens_pedido
UNION ALL

SELECT 'fato_pagamentos', COUNT(*) FROM fato_pagamentos
UNION ALL

SELECT 'fato_avaliacoes', COUNT(*) FROM fato_avaliacoes;

-- Importando dados faltantes (importou somente dim_produtos)

COPY dim_categorias FROM 'C:\Users\ruanl\Desktop\DocsPessoais\Projeto Pessoal\Portifolio\SQL_Project_PostgreSQL\DataSet-Olist\product_category_name_translation.csv'
DELIMITER ',' CSV HEADER;

COPY dim_clientes FROM 'C:\Users\ruanl\Desktop\DocsPessoais\Projeto Pessoal\Portifolio\SQL_Project_PostgreSQL\DataSet-Olist\olist_customers_dataset.csv'
DELIMITER ',' CSV HEADER;

COPY dim_geolocalizacao FROM 'C:\Users\ruanl\Desktop\DocsPessoais\Projeto Pessoal\Portifolio\SQL_Project_PostgreSQL\DataSet-Olist\olist_geolocation_dataset.csv'
DELIMITER ',' CSV HEADER;

COPY dim_vendedores FROM 'C:\Users\ruanl\Desktop\DocsPessoais\Projeto Pessoal\Portifolio\SQL_Project_PostgreSQL\DataSet-Olist\olist_sellers_dataset.csv'
DELIMITER ',' CSV HEADER;

COPY fato_pedidos FROM 'C:\Users\ruanl\Desktop\DocsPessoais\Projeto Pessoal\Portifolio\SQL_Project_PostgreSQL\DataSet-Olist\olist_orders_dataset.csv'
DELIMITER ',' CSV HEADER;

COPY fato_itens_pedido FROM 'C:\Users\ruanl\Desktop\DocsPessoais\Projeto Pessoal\Portifolio\SQL_Project_PostgreSQL\DataSet-Olist\olist_order_items_dataset.csv'
DELIMITER ',' CSV HEADER;

COPY fato_pagamentos FROM 'C:\Users\ruanl\Desktop\DocsPessoais\Projeto Pessoal\Portifolio\SQL_Project_PostgreSQL\DataSet-Olist\olist_order_payments_dataset.csv'
DELIMITER ',' CSV HEADER;

COPY fato_avaliacoes FROM 'C:\Users\ruanl\Desktop\DocsPessoais\Projeto Pessoal\Portifolio\SQL_Project_PostgreSQL\DataSet-Olist\olist_order_reviews_dataset.csv'
DELIMITER ',' CSV HEADER;

-- fato_avaliacoes está com ordem de colunas diferentes (importando na ordem certa)

COPY fato_avaliacoes (review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp) FROM 'C:\Users\ruanl\Desktop\DocsPessoais\Projeto Pessoal\Portifolio\SQL_Project_PostgreSQL\DataSet-Olist\olist_order_reviews_dataset.csv'
DELIMITER ',' CSV HEADER;

-- review_id com valor duplicado (removendo primary key)

DROP TABLE fato_avaliacoes;

CREATE TABLE fato_avaliacoes (
	review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title VARCHAR(100),
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES fato_pedidos(order_id)
);

COPY fato_avaliacoes (review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp)
FROM 'C:\Users\ruanl\Desktop\DocsPessoais\Projeto Pessoal\Portifolio\SQL_Project_PostgreSQL\DataSet-Olist\olist_order_reviews_dataset.csv'
DELIMITER ',' CSV HEADER;

-- avaliações de pedidos que não existem na tabela de pedidos (removendo foreign key e primary key)

DROP TABLE fato_avaliacoes;

CREATE TABLE fato_avaliacoes (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title VARCHAR(100),
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

COPY fato_avaliacoes (review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp)
FROM 'C:\Users\ruanl\Desktop\DocsPessoais\Projeto Pessoal\Portifolio\SQL_Project_PostgreSQL\DataSet-Olist\olist_order_reviews_dataset.csv'
DELIMITER ',' CSV HEADER;

-- Verificação

SELECT 'dim_categorias'    AS tabela, COUNT(*) AS total FROM dim_categorias
UNION ALL

SELECT 'dim_clientes',       COUNT(*) FROM dim_clientes
UNION ALL

SELECT 'dim_geolocalizacao', COUNT(*) FROM dim_geolocalizacao
UNION ALL

SELECT 'dim_vendedores',     COUNT(*) FROM dim_vendedores
UNION ALL

SELECT 'dim_produtos',       COUNT(*) FROM dim_produtos
UNION ALL

SELECT 'fato_pedidos',       COUNT(*) FROM fato_pedidos
UNION ALL

SELECT 'fato_itens_pedido',  COUNT(*) FROM fato_itens_pedido
UNION ALL

SELECT 'fato_pagamentos',    COUNT(*) FROM fato_pagamentos
UNION ALL

SELECT 'fato_avaliacoes',    COUNT(*) FROM fato_avaliacoes;

-- Tabelas retornando sem valores, importando uma por uma para verificar onde está o erro

COPY dim_categorias FROM 'C:\Users\ruanl\Desktop\DocsPessoais\Projeto Pessoal\Portifolio\SQL_Project_PostgreSQL\DataSet-Olist\product_category_name_translation.csv'
DELIMITER ',' CSV HEADER;

COPY dim_clientes FROM 'C:\Users\ruanl\Desktop\DocsPessoais\Projeto Pessoal\Portifolio\SQL_Project_PostgreSQL\DataSet-Olist\olist_customers_dataset.csv'
DELIMITER ',' CSV HEADER;

COPY dim_geolocalizacao FROM 'C:\Users\ruanl\Desktop\DocsPessoais\Projeto Pessoal\Portifolio\SQL_Project_PostgreSQL\DataSet-Olist\olist_geolocation_dataset.csv'
DELIMITER ',' CSV HEADER;

COPY dim_vendedores FROM 'C:\Users\ruanl\Desktop\DocsPessoais\Projeto Pessoal\Portifolio\SQL_Project_PostgreSQL\DataSet-Olist\olist_sellers_dataset.csv'
DELIMITER ',' CSV HEADER;

COPY fato_pedidos FROM 'C:\Users\ruanl\Desktop\DocsPessoais\Projeto Pessoal\Portifolio\SQL_Project_PostgreSQL\DataSet-Olist\olist_orders_dataset.csv'
DELIMITER ',' CSV HEADER;

COPY fato_itens_pedido FROM 'C:\Users\ruanl\Desktop\DocsPessoais\Projeto Pessoal\Portifolio\SQL_Project_PostgreSQL\DataSet-Olist\olist_order_items_dataset.csv'
DELIMITER ',' CSV HEADER;

COPY fato_pagamentos FROM 'C:\Users\ruanl\Desktop\DocsPessoais\Projeto Pessoal\Portifolio\SQL_Project_PostgreSQL\DataSet-Olist\olist_order_payments_dataset.csv'
DELIMITER ',' CSV HEADER;

-- Verificação

SELECT 'dim_categorias'    AS tabela, COUNT(*) AS total FROM dim_categorias
UNION ALL

SELECT 'dim_clientes',       COUNT(*) FROM dim_clientes
UNION ALL

SELECT 'dim_geolocalizacao', COUNT(*) FROM dim_geolocalizacao
UNION ALL

SELECT 'dim_vendedores',     COUNT(*) FROM dim_vendedores
UNION ALL

SELECT 'dim_produtos',       COUNT(*) FROM dim_produtos
UNION ALL

SELECT 'fato_pedidos',       COUNT(*) FROM fato_pedidos
UNION ALL

SELECT 'fato_itens_pedido',  COUNT(*) FROM fato_itens_pedido
UNION ALL

SELECT 'fato_pagamentos',    COUNT(*) FROM fato_pagamentos
UNION ALL

SELECT 'fato_avaliacoes',    COUNT(*) FROM fato_avaliacoes;

-- Iniciando análises exploratórias (Vendas) --
-- Receita Total e Ticket Médio

SELECT
    COUNT(DISTINCT f.order_id) AS total_pedidos,
    ROUND(SUM(i.price + i.freight_value)::NUMERIC, 2) AS receita_total,
    ROUND(AVG(i.price + i.freight_value)::NUMERIC, 2) AS ticket_medio
FROM fato_pedidos f
JOIN fato_itens_pedido i ON f.order_id = i.order_id
WHERE f.order_status = 'delivered';

-- Receita Mensal com crescimento MoM

WITH receita_mensal AS (
	SELECT
		DATE_TRUNC('month', f.order_purchase_timestamp) AS mes,
		ROUND(SUM(i.price + i.freight_value)::NUMERIC, 2) AS receita
	FROM fato_pedidos f
	JOIN fato_itens_pedido i ON f.order_id = i.order_id
	WHERE f.order_status = 'delivered'
	GROUP BY 1
)
SELECT
	mes,
	receita,
	LAG(receita) OVER (ORDER BY mes) AS receita_mes_anterior,
	ROUND(
		(receita - LAG(receita) OVER (ORDER BY mes))
		/ LAG(receita) OVER (ORDER BY mes) * 100, 2
	) AS crescimento_pct
FROM receita_mensal
ORDER BY mes;

-- Top 10 Categorias por Receita

SELECT
	COALESCE(c.product_category_name_english, p.product_category_name) AS categoria,
	COUNT(DISTINCT f.order_id) AS total_pedidos,
	ROUND(SUM(i.price)::NUMERIC, 2) AS receita_total
FROM fato_itens_pedido i
JOIN fato_pedidos f ON i.order_id = f.order_id
JOIN dim_produtos p ON i.product_id = p.product_id
LEFT JOIN dim_categorias c ON p.product_category_name = c.product_category_name
WHERE f.order_status = 'delivered'
GROUP BY 1 
ORDER BY receita_total DESC
LIMIT 10;

-- Receita por Estado

SELECT 
	cl.customer_state AS estado,
	COUNT(DISTINCT f.order_id) AS total_pedidos,
	ROUND(SUM(i.price + i.freight_value)::NUMERIC,2) AS receita_total
FROM fato_pedidos f
JOIN dim_clienteS cl ON f.customer_id = cl.customer_id
JOIN fato_itens_pedido i ON f.order_id = i.order_id
WHERE f.order_status = 'delivered'
GROUP BY 1
ORDER BY receita_total DESC;

-- Análise de Entregas

SELECT
    COUNT(*) AS total_pedidos,
    ROUND(AVG(EXTRACT(EPOCH FROM (order_delivered_customer_date - order_purchase_timestamp)) / 86400)::NUMERIC, 1) AS prazo_medio_dias,
    COUNT(*) FILTER (WHERE order_delivered_customer_date > order_estimated_delivery_date) AS entregues_atrasados,
    ROUND(COUNT(*) FILTER(WHERE order_delivered_customer_date > order_estimated_delivery_date) * 100.0 / COUNT(*), 2) AS pct_atraso
FROM fato_pedidos
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;

-- Clientes Novos X Recorrente

WITH compras_por_cliente AS (
    SELECT
        cl.customer_unique_id,
        COUNT(DISTINCT f.order_id) AS total_pedidos
    FROM fato_pedidos f
    JOIN dim_clientes cl ON f.customer_id = cl.customer_id
    WHERE f.order_status = 'delivered'
    GROUP BY 1
)
SELECT 
	CASE
		WHEN total_pedidos = 1 THEN 'Novo (1 compra)'
		WHEN total_pedidos = 2 THEN 'Recorrente (2 compras)'
		ELSE 'Fiel (3+ compras)'
	END AS perfil_cliente,
	COUNT(*) AS total_clientes,
	ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_total
FROM compras_por_cliente
GROUP BY 1
ORDER BY total_clientes DESC;

-- Top 10 Clientes por LTV

SELECT
    cl.customer_unique_id,
    COUNT(DISTINCT f.order_id) AS total_pedidos,
    ROUND(SUM(i.price + i.freight_value)::NUMERIC, 2) AS ltv,
    ROUND(AVG(i.price + i.freight_value)::NUMERIC, 2) AS ticket_medio
FROM fato_pedidos f
JOIN fato_itens_pedido i ON f.order_id = i.order_id
JOIN dim_clientes cl ON f.customer_id = cl.customer_id
WHERE f.order_status = 'delivered'
GROUP BY 1
ORDER BY ltv DESC
LIMIT 10;

-- Análise RFM(Recência, Frequência, Valor)

WITH rfm_base AS (
    SELECT
        cl.customer_unique_id,
        MAX(f.order_purchase_timestamp)::DATE AS ultima_compra,
        COUNT(DISTINCT f.order_id) AS frequencia,
        ROUND(SUM(i.price + i.freight_value)::NUMERIC, 2) AS valor_total
    FROM fato_pedidos f
    JOIN fato_itens_pedido i ON f.order_id = i.order_id
    JOIN dim_clientes cl ON f.customer_id = cl.customer_id
    WHERE f.order_status = 'delivered'
    GROUP BY 1
),
rfm_score AS (
    SELECT
        customer_unique_id,
        ultima_compra,
        frequencia,
        valor_total,
        CURRENT_DATE - ultima_compra AS recencia_dias,
        NTILE(5) OVER (ORDER BY CURRENT_DATE - ultima_compra ASC) AS r_score,
        NTILE(5) OVER (ORDER BY frequencia DESC) AS f_score,
        NTILE(5) OVER (ORDER BY valor_total DESC) AS m_score
    FROM rfm_base
)
SELECT
    customer_unique_id,
    recencia_dias,
    frequencia,
    valor_total,
    r_score,
    f_score,
    m_score,
    (r_score + f_score + m_score) AS rfm_total,
    CASE
        WHEN (r_score + f_score + m_score) >= 13 THEN 'Cliente VIP'
        WHEN (r_score + f_score + m_score) >= 10 THEN 'Cliente Fiel'
        WHEN (r_score + f_score + m_score) >= 7  THEN 'Cliente em Risco'
        ELSE 'Cliente Perdido'
    END AS segmento
FROM rfm_score
ORDER BY rfm_total DESC
LIMIT 20;

-- Resumo dos Segmentos RFM

WITH rfm_base AS (
    SELECT
        cl.customer_unique_id,
        MAX(f.order_purchase_timestamp)::DATE AS ultima_compra,
        COUNT(DISTINCT f.order_id) AS frequencia,
        ROUND(SUM(i.price + i.freight_value)::NUMERIC, 2) AS valor_total
    FROM fato_pedidos f
    JOIN fato_itens_pedido i ON f.order_id = i.order_id
    JOIN dim_clientes cl ON f.customer_id = cl.customer_id
    WHERE f.order_status = 'delivered'
    GROUP BY 1
),
rfm_score AS (
    SELECT
        customer_unique_id,
        NTILE(5) OVER (ORDER BY CURRENT_DATE - ultima_compra ASC) AS r_score,
        NTILE(5) OVER (ORDER BY frequencia DESC) AS f_score,
        NTILE(5) OVER (ORDER BY valor_total DESC) AS m_score
    FROM rfm_base
),
rfm_segmento AS (
    SELECT
        CASE
            WHEN (r_score + f_score + m_score) >= 13 THEN 'Cliente VIP'
            WHEN (r_score + f_score + m_score) >= 10 THEN 'Cliente Fiel'
            WHEN (r_score + f_score + m_score) >= 7  THEN 'Cliente em Risco'
            ELSE 'Cliente Perdido'
        END AS segmento
    FROM rfm_score
)
SELECT
    segmento,
    COUNT(*) AS total_clientes,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_total
FROM rfm_segmento
GROUP BY 1
ORDER BY total_clientes DESC;

-- Atrasos por Estado

SELECT
    cl.customer_state AS estado,
    COUNT(*) AS total_pedidos,
    COUNT(*) FILTER(
        WHERE f.order_delivered_customer_date > f.order_estimated_delivery_date) AS entregues_atrasados,
    ROUND(
        COUNT(*) FILTER(
			WHERE f.order_delivered_customer_date > f.order_estimated_delivery_date) * 100.0 / COUNT(*), 2) AS pct_atraso,
    ROUND(AVG(
        EXTRACT(EPOCH FROM (f.order_delivered_customer_date - f.order_purchase_timestamp)) / 86400)::NUMERIC, 1) AS prazo_medio_dias
FROM fato_pedidos f
JOIN dim_clientes cl ON f.customer_id = cl.customer_id
WHERE f.order_status = 'delivered'
  AND f.order_delivered_customer_date IS NOT NULL
GROUP BY 1
ORDER BY pct_atraso DESC;

-- Média de atraso por Estado

SELECT
    cl.customer_state AS estado,
    COUNT(*) AS total_avaliacoes,
    ROUND(AVG(a.review_score)::NUMERIC, 2) AS media_avaliacao,
    COUNT(*) FILTER (WHERE a.review_score = 5) AS notas_5,
    COUNT(*) FILTER (WHERE a.review_score = 1) AS notas_1
FROM fato_avaliacoes a
JOIN fato_pedidos f ON a.order_id = f.order_id
JOIN dim_clientes cl ON f.customer_id = cl.customer_id
GROUP BY 1
ORDER BY media_avaliacao DESC;

-- Atraso vs Avaliação

WITH pedidos_classificados AS (
    SELECT
        f.order_id,
        CASE
            WHEN f.order_delivered_customer_date <= f.order_estimated_delivery_date 
            THEN 'No Prazo'
            ELSE 'Atrasado'
        END AS status_entrega
    FROM fato_pedidos f
    WHERE f.order_status = 'delivered'
      AND f.order_delivered_customer_date IS NOT NULL
)
SELECT
    pc.status_entrega,
    COUNT(*) AS total_pedidos,
    ROUND(AVG(a.review_score)::NUMERIC, 2) AS media_avaliacao,
    COUNT(*) FILTER (WHERE a.review_score = 5) AS notas_5,
    COUNT(*) FILTER (WHERE a.review_score = 1) AS notas_1
FROM pedidos_classificados pc
JOIN fato_avaliacoes a ON pc.order_id = a.order_id
GROUP BY 1
ORDER BY media_avaliacao DESC;

-- Prazo médio de Entrega por Categoria

SELECT
    COALESCE(c.product_category_name_english, p.product_category_name) AS categoria,
    COUNT(DISTINCT f.order_id) AS total_pedidos,
    ROUND(AVG(
        EXTRACT(EPOCH FROM (f.order_delivered_customer_date - f.order_purchase_timestamp)) / 86400)::NUMERIC, 1) AS prazo_medio_dias,
    ROUND(AVG(a.review_score)::NUMERIC, 2) AS media_avaliacao
FROM fato_pedidos f
JOIN fato_itens_pedido i ON f.order_id = i.order_id
JOIN dim_produtos p ON i.product_id = p.product_id
LEFT JOIN dim_categorias c ON p.product_category_name = c.product_category_name
JOIN fato_avaliacoes a ON f.order_id = a.order_id
WHERE f.order_status = 'delivered'
  AND f.order_delivered_customer_date IS NOT NULL
GROUP BY 1
ORDER BY prazo_medio_dias DESC
LIMIT 15;