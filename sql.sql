drop table if exists geo.Gorod;
drop table if exists geo.Strana;
--tag::sql_script[]
create table geo.Strana (
	id int
	, naimenovaniye varchar(255)
	, primary key (id)
);
create table geo.Gorod (
	id int
	, naimenovaniye varchar(255)
	, strana_id int
	, constraint strana_gorod foreign key (strana_id)
		references geo.Strana(id)
);
--end::sql_script[]

--tag::get_model[]
drop table if exists fk;
select x.table_schema as table_schema
    , x.table_name
    , y.table_schema as foreign_table_schema
    , y.table_name as foreign_table_name
into temp fk
from information_schema.referential_constraints rc
join information_schema.key_column_usage x
    on x.constraint_name = rc.constraint_name
join information_schema.key_column_usage y
    on y.ordinal_position = x.position_in_unique_constraint
    and y.constraint_name = rc.unique_constraint_name;

select
	json_agg(json_build_object(
		'name', t.table_schema || '.' || t.table_name
		, 'columns'
		, (select
			json_agg(json_build_object (
				'name', column_name
				,'type', data_type
			))
			from information_schema.columns as c
			where c.table_name = t.table_name and c.table_schema = t.table_schema
		  )
		, 'fk'
		, (select
		  	json_agg(json_build_object (
				'fk_table'
				, fk.foreign_table_schema || '.' || fk.foreign_table_name
		  	))
		   from fk
		   where fk.table_name = t.table_name and fk.table_schema = t.table_schema
		  )
	))
from information_schema.tables as t
where table_schema = 'geo';
--end::get_model[]

--select * from fk




