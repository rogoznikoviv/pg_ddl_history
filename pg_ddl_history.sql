--drop table public.ddl_history;
create table public.ddl_history (
	username	varchar(64),
	database	varchar(64),
	schema	varchar(64),
	objid	oid,
	object_type	varchar(64),
	object_identity	text,
	ddl	text,
	ts timestamp not null default now());

-- drop event_trigger_ddl_commands;
create or replace function event_trigger_ddl_commands() returns event_trigger as $$
declare
    obj record;
begin
	select * into obj from pg_event_trigger_ddl_commands();
	if obj.objid is not null then
		--raise info '%', session_user || ' bd ' || current_database()|| ' objid ' || obj.objid || ' schema_name ' || obj.schema_name || ' object_type ' || obj.object_type || ' object_identity ' || obj.object_identity  || ' query ' || current_query();
		insert into public.ddl_history
			(username, "database", "schema", objid, object_type, object_identity, ddl)
			values(session_user, current_database(), obj.schema_name, obj.objid, obj.object_type, obj.object_identity, current_query());
	end if;
end;
$$ language plpgsql;

-- drop function event_trigger_for_drops;
create or replace function event_trigger_for_drops() returns event_trigger as $$
declare
    obj record;
begin
	select * into obj from pg_event_trigger_dropped_objects();
	if obj.objid is not null then
		--raise info '%', session_user || ' bd ' || current_database()|| ' objid ' || obj.objid || ' schema_name ' || obj.schema_name || ' object_type ' || obj.object_type || ' object_identity ' || obj.object_identity || ' query ' || current_query();
		insert into public.ddl_history
			(username, "database", "schema", objid, object_type, object_identity, ddl)
			values(session_user, current_database(), obj.schema_name, obj.objid, obj.object_type, obj.object_identity, current_query());
	end if;
end;
$$ language plpgsql;

--drop event trigger etdc;
create event trigger etdc on ddl_command_end execute procedure event_trigger_ddl_commands();
--drop event trigger etfd;
create event trigger etfd on sql_drop execute procedure event_trigger_for_drops();
