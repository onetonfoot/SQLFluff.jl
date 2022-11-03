# SQLFluff

To install run

```
]add SQLFluff.jl
```

This package is a thin wrapper around [SQLStrings](https://github.com/JuliaComputing/SQLStrings.jl) which adds linting via [sqlfluff](https://github.com/sqlfluff/sqlfluff), so that incorrect SQL should throw an informative error for example


```julia
sql"SELET * FROM table "
# ERROR: SQLParseError(Line 1, Position 1: Found unparsable section: 'SELET * FROM mytable')
```

You can configure a specific dialect with 

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

For SQL code that contains interpolated symbols, e.g `SELECT * FROM table WHERE x=$x` we need to know how to format the data types so the generated SQL can be linted. If your datatype is unsupported you can define

```julia
formatter(::Val{:dialect}, ::MyType) = x -> "$x my format"
```

It should return a function that is capable of correctly formatting your data type. Initial support will go into covering formatting for Postgres and Sqlite.