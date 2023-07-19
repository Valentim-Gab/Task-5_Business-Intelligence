--CREATE TABLE

CREATE TABLE marca (
	id_marca SERIAL PRIMARY KEY,
	nome varchar(100)
);

CREATE TABLE categoria (
	id_categoria SERIAL PRIMARY KEY,
	nome varchar(100)
);

CREATE TABLE produto (
	id_produto SERIAL PRIMARY KEY,
	nome varchar(100),
	tipo varchar(100),
	preco float,
	id_marca int not null,
	id_categoria int not null,
	FOREIGN KEY (id_marca) REFERENCES marca (id_marca),
	FOREIGN KEY (id_categoria) REFERENCES categoria (id_categoria)
);

CREATE TABLE estoque (
	id_estoque SERIAL PRIMARY KEY,
	quantidade int not null,
	id_produto int not null,
	FOREIGN KEY (id_produto) REFERENCES produto (id_produto)
);

CREATE TABLE venda (
	id_venda SERIAL PRIMARY KEY,
	quantidade int not null,
	ano int not null, 
	id_produto int not null,
	FOREIGN KEY (id_produto) REFERENCES produto (id_produto)
);

--INSERT
insert into marca values
(default, 'seara'),
(default, 'perdigao'),
(default, 'custo beneficio'),
(default, 'luxo');

insert into categoria values
(default, 'mobilia'),
(default, 'materiais de construcao'),
(default, 'alimentos');

insert into produto values
(default, 'piso ceramica', 40.99, 3, 2),
(default, 'piso marmore', 210.00, 4, 2),
(default, 'pizza', 12.00, 1, 3),
(default, 'pizza', 12.00, 2, 3),
(default, 'cadeiras', 120.00, 3, 1),
(default, 'cama king size', 800.00, 4, 1),
(default, 'sofas', 500.00, 3, 1),
(default, 'sofa dourado', 1100.00, 4, 1);

insert into estoque values
(default, 9000, 1), 
(default, 7000, 2), 
(default, 600, 3), 
(default, 600, 4), 
(default, 500, 5), 
(default, 100, 6), 
(default, 200, 7),
(default, 150, 8);

insert into venda values
(default, 7845, 2013, 1), 
(default, 6582, 2019, 2),  
(default, 576, 2023, 3), 
(default, 599, 2023, 4), 
(default, 293, 2018, 5), 
(default, 39, 2018, 6), 
(default, 141, 2020, 7); 

--Listar o nome da marca e categoria de produtos e a soma do total no estoque destes produtos
SELECT
  m.nome AS marca,
  c.nome AS categoria,
  SUM(e.quantidade) AS estoque
FROM marca m, categoria c, estoque e, produto p
WHERE m.id_marca = p.id_marca
AND c.id_categoria = p.id_categoria
AND e.id_produto = p.id_produto
GROUP BY GROUPING SETS((m.nome, c.nome))


--Listar a quantidade de vendas que um produto de uma marca, preço e categoria que ocorreram entre 2016 e 2023.
SELECT
  p.nome as produto,
  p.preco as valor,
  m.nome as marca,
  c.nome as categoria,
  COUNT(v.id_venda) as quantidade_vendas
FROM marca m, categoria c, venda v, produto p
WHERE m.id_marca = p.id_marca
AND c.id_categoria = p.id_categoria
AND v.id_produto = p.id_produto
AND v.ano > 2015
AND v.ano <= 2023
GROUP BY ROLLUP((p.nome, p.preco, m.nome, c.nome))

-- A quantidade de produtos de uma marca e uma categoria que venderam mais de 200 unidades no ano 2023 com o preço maior que 10 R$
WITH qtd_venda AS (
	SELECT
		p.nome AS produto,
		p.preco AS preco,
		m.nome AS marca,
		c.nome AS categoria,
		(SELECT COUNT(*)
			 FROM venda v
			 WHERE m.id_marca = p.id_marca
			 AND c.id_categoria = p.id_categoria
			 AND v.id_produto = p.id_produto
			 AND v.ano = 2023
			 AND v.quantidade > 200
			 AND p.preco > 10
			GROUP BY GROUPING SETS((m.id_marca, p.id_marca, c.id_categoria, v.id_venda))
		) AS quantidade_venda
	FROM produto p, marca m, categoria c
)
SELECT
	produto,
	preco,
	marca,
	categoria,
	CASE
		WHEN quantidade_venda IS NULL THEN 0
		ELSE quantidade_venda
	END quantidade_venda
FROM qtd_venda