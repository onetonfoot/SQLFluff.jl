module SQLFluff

using PythonCall

import SQLStrings: parse_interpolations, allow_dollars_in_strings, Sql, process_args!

export sqlfluff, @sql_str, SQLParseError, dialect!

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

function dialect!(s)
	if !(s in dialects)
		error("""Unsupported dialect. Supported ones are $(join(dialects, ", "))""")
	end
	sql_dialect[] = s
end


struct SQLParseError <: Exception
    line_no::String
    line_pos::String
    description::String
end

Base.showerror(io::IO, e::SQLParseError) = print(io, "SQLParseError($(e.description))")

macro sql_str(str)
    lint_result = sqlfluff.lint(str, dialect=sql_dialect[])
    bools = map(x -> string(x["code"]) == "PRS", lint_result)
    for (i, b) in enumerate(bools)
        if b
            err = lint_result[i-1]
			@info err
            e = SQLParseError(
                string(err["line_no"]),
                string(err["line_pos"]),
                string(err["description"]),
            )

            return quote
                throw($(e))
            end
        end
    end

    args = parse_interpolations(str, allow_dollars_in_strings[])
    quote
        Sql(process_args!([], $(args...)))
    end
end

end # module
