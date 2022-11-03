module SQLFluff

using PythonCall

import SQLStrings: parse_interpolations, allow_dollars_in_strings, Sql, process_args!, Literal

export sqlfluff, @sql_str, SQLParseError, dialect!, lintsql

const sql_dialect = Ref("ansi")
const sqlfluff = PythonCall.pynew() # initially NULL

function __init__()
    PythonCall.pycopy!(sqlfluff, pyimport("sqlfluff"))
end

const dialects = [
    "ansi",
    "bigquery",
    "db2",
    "exasol",
    "hive",
    "mysql",
    "oracle",
    "postgres",
    "redshift",
    "snowflake",
    "sparksql",
    "sqlite",
    "teradata",
    "tsql",
]

const ansi = Val(:ansi)
const bigquery = Val(:bigquery)
const db2 = Val(:db2)
const exasol = Val(:exasol)
const hive = Val(:hive)
const mysql = Val(:mysql)
const oracle = Val(:oracle)
const postgres = Val(:postgres)
const redshift = Val(:redshift)
const snowflake = Val(:snowflake)
const sparksql = Val(:sparksql)
const sqlite = Val(:sqlite)
const teradata = Val(:teradata)
const tsql = Val(:tsql)


function dialect!(s)
	if !(s in dialects)
		error("""Unsupported dialect. Supported ones are $(join(dialects, ", "))""")
	end
	sql_dialect[] = s
end

dialect!(::Val{T}) where T = dialect!(string(T))
dialect!(s::Symbol) = dialect!(string(s))

struct SQLParseError <: Exception
    line_no::String
    line_pos::String
    description::String
end

Base.showerror(io::IO, e::SQLParseError) = print(io, "SQLParseError($(e.description))")

function lintsql(str)
    lint_result = sqlfluff.lint(str, dialect=sql_dialect[])
    bools = map(x -> string(x["code"]) == "PRS", lint_result)
	errs = []
    for (i, b) in enumerate(bools)
        if b
            err = lint_result[i-1]
            e = SQLParseError(
                string(err["line_no"]),
                string(err["line_pos"]),
                string(err["description"]),
            )

			push!(errs, e)
        end
    end

	return errs
end


# Fallback formatters

format(x::AbstractString) = "'$x'"
format(x::Number) = "$x"
format(x) = error("Unhandled format for dialect $(sql_dialect[]) and $(typeof(x))")
formatter(dialect::Val, value)  = format

# Postgres Formattters
# https://www.postgresql.org/docs/current/datatype.html
function postgres_array(l::Vector)
    "ARRAY[" * join(map(format, l),",") * "]"
end

formatter(::Val{:postgres}, ::Vector) = postgres_array

function joinsql(sql::Sql)
    # TODO: this would need to provide the value in the correct string format 
    # for a given dialetc for this to work
    dialect = sql_dialect[] |> Symbol |> Val
    l = map(sql.args) do x
        if x isa Literal
            x.fragment
        else
            formatter(dialect, x)(x)
        end
    end
    join(l, "")
end

macro sql_str(str)
    args = parse_interpolations(str, allow_dollars_in_strings[])
    quote
        let 
            new_str = Sql(process_args!([], $(args...)))
            errs = lintsql(joinsql(new_str))
            if !isempty(errs)
                throw((errs[1]))
            end
            new_str
        end

    end
end

end # module
