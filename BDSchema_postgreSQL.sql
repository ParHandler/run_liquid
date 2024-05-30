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
        , 'comment', obj_description((table_schema||'.'||table_name)::regclass)
        , 'columns'
        , (select
               json_agg(json_build_object (
                    'name', column_name
                   ,'type', data_type
                   ,'nullable', is_nullable
                   ,'comment', col_description((table_schema||'.'||table_name)::regclass::oid, ordinal_position)
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
        ) ORDER BY t.table_name)
from information_schema.tables as t
where table_schema = 'pfmhst'
;