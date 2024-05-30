-- Выгрузка в одно поле, она может не работать при попытке сохранить файл в IDE. 
SELECT JSON_arrayagg(JSON_OBJECT('name' value tab.TABLE_NAME
                         , 'comment' value tabc.COMMENTS
                         , 'columns' value json_arrayagg(JSON_OBJECT(
                                     'name' VALUE t.COLUMN_NAME,
                                     'type' value DECODE(t.DATA_TYPE, 'NUMBER',
                                                         t.DATA_TYPE || '(' || t.data_precision || ',' ||
                                                         t.data_scale || ')', 'NVARCHAR2',
                                                         t.DATA_TYPE || '(' || (t.DATA_LENGTH / 2) || ')', t.DATA_TYPE),
                                     'nullable' value case t.nullable
                                                          when 'N' then 'NO'
                                                          when 'Y' then 'YES'
                                         end,
                                     'comment' VALUE cc.COMMENTS)
                             ORDER BY t.COLUMN_ID RETURNING CLOB)
                                 RETURNING CLOB)
                     ORDER BY tab.TABLE_NAME RETURNING CLOB) as expr
from ALL_TABLES tab
         LEFT JOIN ALL_TAB_COLUMNS t
                on tab.OWNER = t.OWNER
                    and tab.TABLE_NAME = t.TABLE_NAME
         LEFT JOIN ALL_TAB_COMMENTS tabc
                   on tabc.OWNER = t.OWNER
                       and tabc.TABLE_NAME = t.TABLE_NAME
         LEFT JOIN ALL_COL_COMMENTS cc
                   ON t.OWNER = cc.OWNER
                       and t.TABLE_NAME = cc.TABLE_NAME
                       and t.COLUMN_NAME = cc.COLUMN_NAME
WHERE t.OWNER != 'HCFB_PMNTS_ADM'
GROUP BY tab.TABLE_NAME, tabc.COMMENTS;

-- Тот же запрос, но оформленный в WITH Clause
with schm as (select tc.table_name,
                       tabc.COMMENTS tabc_COMMENTS,
                       tc.column_name,
                       case tc.DATA_TYPE
                           when 'NUMBER'
                               then tc.DATA_TYPE || '(' || tc.data_precision || ',' || tc.data_scale || ')'
                           when 'NVARCHAR2'
                               then tc.DATA_TYPE || '(' || (tc.DATA_LENGTH / 2) || ')'
                           ELSE tc.DATA_TYPE
                           end as DATA_TYPE,
                       case nullable
                           when 'N' then 'NO'
                           when 'Y' then 'YES'
                           end as nullable,
                       cc.COMMENTS cc_COMMENTS
                from ALL_TAB_COLUMNS tc
                         LEFT JOIN ALL_COL_COMMENTS cc
                                   ON cc.OWNER = cc.OWNER
                                       and tc.TABLE_NAME = cc.TABLE_NAME
                                       and tc.COLUMN_NAME = cc.COLUMN_NAME
                         LEFT JOIN ALL_TAB_COMMENTS tabc
                                   on tabc.OWNER = tc.OWNER
                                       and tabc.TABLE_NAME = tc.TABLE_NAME
                WHERE tc.OWNER = 'HCFB_PMNTS_ADM'
                order by table_name
)
select JSON_arrayagg(JSON_OBJECT('name' value schm.TABLE_NAME
                         , 'comment' value tabc_COMMENTS
                         , 'columns' value json_arrayagg(JSON_OBJECT(
                                                                 'name' VALUE schm.COLUMN_NAME,
                                                                 'type' value schm.DATA_TYPE,
                                                                 'nullable' value schm.nullable,
                                                                 'comment' VALUE cc_COMMENTS)
                                                         RETURNING CLOB)
                                 RETURNING CLOB)
                     ORDER BY schm.TABLE_NAME RETURNING CLOB) as expr 
from schm
GROUP BY TABLE_NAME,tabc_COMMENTS;

-- Возвращает результат множеством строк, которые нужно сохранить как JSON, удалив знак ' и заключив текст в скобки []
SELECT  JSON_OBJECT('name' value tab.TABLE_NAME
            , 'comment' value tabc.COMMENTS
            , 'columns' value json_arrayagg(JSON_OBJECT(
                                                    'name' VALUE t.COLUMN_NAME,
                                                    'type' value DECODE(t.DATA_TYPE, 'NUMBER',
                                                                        t.DATA_TYPE || '(' || t.data_precision || ',' ||
                                                                        t.data_scale || ')', 'NVARCHAR2',
                                                                        t.DATA_TYPE || '(' || (t.DATA_LENGTH / 2) || ')', t.DATA_TYPE),
                                                    'nullable' value case t.nullable
                                                                         when 'N' then 'NO'
                                                                         when 'Y' then 'YES'
                                                        end,
                                                    'comment' VALUE cc.COMMENTS)
                                            ORDER BY t.COLUMN_ID RETURNING CLOB)
                    RETURNING CLOB) as expr 
from ALL_TABLES tab
         LEFT JOIN ALL_TAB_COLUMNS t
                   on tab.OWNER = t.OWNER
                       and tab.TABLE_NAME = t.TABLE_NAME
         LEFT JOIN ALL_TAB_COMMENTS tabc
                   on tabc.OWNER = t.OWNER
                       and tabc.TABLE_NAME = t.TABLE_NAME
         LEFT JOIN ALL_COL_COMMENTS cc
                   ON t.OWNER = cc.OWNER
                       and t.TABLE_NAME = cc.TABLE_NAME
                       and t.COLUMN_NAME = cc.COLUMN_NAME
WHERE t.OWNER != 'HCFB_PMNTS_ADM'
GROUP BY tab.TABLE_NAME, tabc.COMMENTS;