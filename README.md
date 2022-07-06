# SQLFluff

To install run

```
]add SQLFluff.jl
```

This package is a thin wrapper around [SQLStrings](https://github.com/JuliaComputing/SQLStrings.jl) which adds linting via [sqlfluff](https://github.com/sqlfluff/sqlfluff), so that incorrect SQL should throw a informative error for example


```julia
sql"SELET * FROM table "
# ERROR: SQLParseError(Line 1, Position 1: Found unparsable section: 'SELET * FROM mytable')
```

You can configure you specific dialect with 

```julia
dialect!("sqlite")
```

Where the supported dialects are 

```julia
[
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
```